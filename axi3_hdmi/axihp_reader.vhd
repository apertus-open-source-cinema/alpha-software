----------------------------------------------------------------------------
--  axihp_reader.vhd
--	AXIHP Reader (No In Flight)
--	Version 1.2
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unimacro;
use unimacro.VCOMPONENTS.all;

use work.axi3s_pkg.all;		-- AXI3 Slave Interface


entity axihp_reader is
    generic (
	DATA_WIDTH : natural := 64;
	DATA_COUNT : natural := 16;
	ADDR_MASK : std_logic_vector(31 downto 0) := x"00FFFFFF";
	ADDR_DATA : std_logic_vector(31 downto 0) := x"1B000000" );
    port (
	m_axi_aclk	: in std_logic;
	m_axi_areset_n	: in std_logic;
	enable		: in std_logic;
	--
	m_axi_ro	: out axi3s_read_in_r;
	m_axi_ri	: in axi3s_read_out_r;
	--
	data_clk	: out std_logic;
	data_enable	: out std_logic;
	data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
	data_full	: in std_logic;
	--
	addr_clk	: out std_logic;
	addr_enable	: out std_logic;
	addr_in		: in std_logic_vector(31 downto 0);
	addr_empty	: in std_logic;
	--
	reader_state	: out std_logic_vector(7 downto 0) );

    attribute DONT_TOUCH : string;
    attribute MARK_DEBUG : string;

    attribute DONT_TOUCH of data_clk : signal is "TRUE";
    attribute DONT_TOUCH of data_enable : signal is "TRUE";
    attribute DONT_TOUCH of data_out : signal is "TRUE";
    attribute DONT_TOUCH of data_full : signal is "TRUE";

    attribute DONT_TOUCH of addr_clk : signal is "TRUE";
    attribute DONT_TOUCH of addr_enable : signal is "TRUE";
    attribute DONT_TOUCH of addr_in : signal is "TRUE";
    attribute DONT_TOUCH of addr_empty : signal is "TRUE";

end entity axihp_reader;

architecture RTL of axihp_reader is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";
	
    signal sgn_data_enable  : std_logic;

begin

    read_proc : process (m_axi_aclk)

	constant dcnt_c : natural := DATA_COUNT - 1;
	variable dcnt_v : integer range DATA_COUNT - 1 downto -1;

	variable arvalid_v : std_logic := '0';
	variable rready_v : std_logic := '0';

	type r_state is (addr_s, data_s, hold_s, idle_s);

	variable state : r_state := idle_s;

    begin

	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then

		arvalid_v := '0';
		rready_v := '0';

		state := idle_s;

	    else

		addr_enable <= '0';
		sgn_data_enable <= '0';

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		case state is

		    when addr_s =>
			rready_v := '0';
			dcnt_v := dcnt_c;
			
			if arvalid_v = '0' then
			    if enable = '0' then		-- disable reader
				state := hold_s;

			    elsif addr_empty = '1' then		-- fifo empty
				state := idle_s;

			    elsif data_full = '1' then		-- not enough space
				state := idle_s;

			    else				-- go ahead
				arvalid_v := '1';
			    end if;
			end if;
			    
			if arvalid_v = '1' then
			    if m_axi_ri.arready = '1' then	-- slave ready
				state := data_s;
			    end if;
			end if;

		    when data_s =>
			arvalid_v := '0';
			rready_v := '1';

			if m_axi_ri.rvalid = '1' then		-- reader ready
			    dcnt_v := dcnt_v - 1;

			    if dcnt_v < 0 then			-- last read
				addr_enable <= '1';		-- fetch addr

				state := addr_s;
			    end if;

			    sgn_data_enable <= '1';			-- store data
			else
			    sgn_data_enable <= '0';			-- no data
			end if;

		    when hold_s =>
			if enable = '1' then
			    addr_enable <= '1';			-- fetch addr
			    state := addr_s;
			end if;

		    when idle_s =>
			if data_full = '0' and
			    addr_empty = '0' then
			    state := addr_s;
			end if;

		end case;
	    end if;

	    case state is
		when addr_s => reader_state(3 downto 0) <= "0001";
		when data_s => reader_state(3 downto 0) <= "0010";
		when hold_s => reader_state(3 downto 0) <= "0111";
		when idle_s => reader_state(3 downto 0) <= "1000";
	    end case;

	    reader_state(7 downto 4) <=
		std_logic_vector(to_unsigned(dcnt_v, 4));

	end if;

	m_axi_ro.arid <= (others => '0');

	m_axi_ro.arvalid <= arvalid_v;
	m_axi_ro.rready <= rready_v;

    end process;
    
    DELAY_WRITE_ENABLE_PROC:process(m_axi_aclk)
    begin
        if rising_edge(m_axi_aclk) then
			if m_axi_areset_n = '0' then
				data_enable <= '0';
			else
				data_enable <= sgn_data_enable;
			end if;
        end if;
    end process;


    data_out <= m_axi_ri.rdata(DATA_WIDTH - 1 downto 0);
    m_axi_ro.araddr <= (addr_in and ADDR_MASK) or ADDR_DATA;


    m_axi_ro.arlen <=
	std_logic_vector(to_unsigned(DATA_COUNT - 1, 4));

    m_axi_ro.arburst <= "01";
    m_axi_ro.arsize <= "11";

    m_axi_ro.arprot <= "000";


    data_clk <= m_axi_aclk;
    addr_clk <= m_axi_aclk;

end RTL;
