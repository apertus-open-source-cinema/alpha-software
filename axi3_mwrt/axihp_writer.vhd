----------------------------------------------------------------------------
--  axihp_writer.vhd
--	AXIHP Writer (No In Flight)
--	Version 1.4
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


entity axihp_writer is
    generic (
	DATA_WIDTH : natural := 64;
	DATA_COUNT : natural := 16;
	ADDR_MASK : std_logic_vector(31 downto 0) := x"00FFFFFF";
	ADDR_DATA : std_logic_vector(31 downto 0) := x"1B000000" );
    port (
	m_axi_aclk	: in std_ulogic;
	m_axi_areset_n	: in std_ulogic;
	enable		: in std_ulogic;
	--
	m_axi_wo	: out axi3s_write_in_r;
	m_axi_wi	: in axi3s_write_out_r;
	--
	data_clk	: out std_ulogic;
	data_enable	: out std_ulogic;
	data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
	data_empty	: in std_ulogic;
	--
	addr_clk	: out std_ulogic;
	addr_enable	: out std_ulogic;
	addr_in		: in std_logic_vector(31 downto 0);
	addr_empty	: in std_ulogic;
	--
	writer_state	: out std_logic_vector(7 downto 0) );

end entity axihp_writer;

architecture RTL of axihp_writer is
begin

    write_proc : process(m_axi_aclk, m_axi_wi)

	constant dcnt_c : natural := DATA_COUNT - 1;
	variable dcnt_v : integer range DATA_COUNT - 1 downto -1;

	variable awvalid_v : std_logic := '0';
	variable wvalid_v : std_logic := '0';
	variable wlast_v : std_logic := '0';

	variable addr_v : std_logic_vector(31 downto 0);

	type w_state is (addr_s, data_s, hold_s, idle_s);

	variable state : w_state := idle_s;

    begin

	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then
		awvalid_v := '0';
		wvalid_v := '0';
		wlast_v := '0';

		state := idle_s;

	    else
		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		case state is
		    when addr_s =>
			wvalid_v := '0';
			wlast_v := '0';
			dcnt_v := dcnt_c;
			addr_v := (addr_in and ADDR_MASK) or ADDR_DATA;

			if awvalid_v = '0' then
			    if enable = '0' then		-- disable writer
				state := hold_s;

			    elsif addr_empty = '1' then		-- fifo empty
				state := idle_s;

			    elsif data_empty = '1' then		-- fifo empty
				state := idle_s;

			    else				-- go ahead
				awvalid_v := '1';

			    end if;
			end if;
			
			if awvalid_v = '1' then
			    if m_axi_wi.awready = '1' then	-- slave ready
				state := data_s;
			    end if;
			end if;

		    when data_s =>
			awvalid_v := '0';
			wvalid_v := '1';

			if m_axi_wi.wready = '1' then		-- write ready
			    dcnt_v := dcnt_v - 1;

			    if dcnt_v < 0 then			-- last write
				wlast_v := '1';

				state := addr_s;
			    end if;
			end if;

		    when hold_s =>
			if enable = '1' then
			    state := addr_s;
			end if;

		    when idle_s =>
			if data_empty = '0' and 
			    addr_empty = '0' then
			    state := addr_s;
			end if;

		end case;
	    end if;

	    case state is
		when addr_s => writer_state(3 downto 0) <= "0001";
		when data_s => writer_state(3 downto 0) <= "0010";
		when hold_s => writer_state(3 downto 0) <= "0111";
		when idle_s => writer_state(3 downto 0) <= "1000";
	    end case;

	    writer_state(7 downto 4) <=
		std_logic_vector(to_unsigned(dcnt_v, 4));

	end if;

	m_axi_wo.awid <= (others => '0');
	m_axi_wo.wid <= (others => '0');
	m_axi_wo.awaddr <= addr_v;

	m_axi_wo.awvalid <= awvalid_v;
	m_axi_wo.wvalid <= wvalid_v;

	m_axi_wo.wlast <= wlast_v;

	data_enable <= wvalid_v and m_axi_wi.wready;
	addr_enable <= awvalid_v and m_axi_wi.awready;

    end process;

    m_axi_wo.wdata(DATA_WIDTH - 1 downto 0) <= data_in;


    bresp_proc : process(m_axi_aclk)

	variable bready_v : std_logic := '0';

    begin

	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then
		bready_v := '0';

	    else
		bready_v := '1';

		if m_axi_wi.bvalid = '1' then
		    null;
		end if;
	    end if;
	end if;

	m_axi_wo.bready <= bready_v;

    end process;

    m_axi_wo.awlen <=
	std_logic_vector(to_unsigned(DATA_COUNT - 1, 4));

    m_axi_wo.awburst <= "01";
    m_axi_wo.awsize <= "11";
    m_axi_wo.wstrb <= x"FF";

    m_axi_wo.awprot <= "000";

    data_clk <= m_axi_aclk;
    addr_clk <= m_axi_aclk;

end RTL;
