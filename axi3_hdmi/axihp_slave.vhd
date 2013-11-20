----------------------------------------------------------------------------
--  axihp_slave.vhd
--	AXIHP Slave (for simulation)
--	Version 1.0
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

use work.axi3s_pkg.all;		-- AXI3 Slave


entity axihp_slave is
    generic (
	DATA_WIDTH : natural := 64;
	DATA_COUNT : natural := 16 );
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset : in std_logic;
	--
	s_axi_ro : out axi3s_read_out_r;
	s_axi_ri : in axi3s_read_in_r;
	s_axi_wo : out axi3s_write_out_r;
	s_axi_wi : in axi3s_write_in_r
    );
end entity axihp_slave;


architecture RTL of axihp_slave is

    function data_at(
	addr : in std_logic_vector(31 downto 0) )
	return std_logic_vector is

	variable addr_v : unsigned(addr'range);
	variable data_v : unsigned(63 downto 0);
    begin
	addr_v := unsigned(addr);
	data_v := addr_v(27 downto 24) & addr_v(12 downto 3) & "00" &
		  addr_v(27 downto 24) & addr_v(12 downto 3) & "01" &
		  addr_v(27 downto 24) & addr_v(12 downto 3) & "10" &
		  addr_v(27 downto 24) & addr_v(12 downto 3) & "11";
	return std_logic_vector(data_v);
	
    end function;


    function addr_next(
	addr : in std_logic_vector(31 downto 0) )
	return std_logic_vector is

	variable addr_v : unsigned(addr'range);
    begin
	addr_v := unsigned(addr);
	addr_v := addr_v + "1000";
	return std_logic_vector(addr_v);
    end function;

begin

    read_proc : process (
	s_axi_aclk, s_axi_areset, s_axi_ri )

	constant dcnt_c : natural := DATA_COUNT - 1;
	variable dcnt_v : integer range DATA_COUNT - 1 downto -1;

	variable addr_v : std_logic_vector(31 downto 0)
	    := (others => '0');

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';
	variable rlast_v : std_logic := '0';

	variable rdata_v : std_logic_vector(63 downto 0);
	variable rresp_v : std_logic_vector(1 downto 0) := "00";

	type r_state is (addr_s, data_s, busy_s);

	variable state : r_state := addr_s;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset = '1' then
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';
		rlast_v := '0';

		rdata_v := (others => '0');

		state := addr_s;

	    else
		case state is

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when addr_s =>
			arready_v := '1';		-- ready for transfer
			rlast_v := '0';

			if s_axi_ri.arvalid = '1' then	-- address _is_ valid
			    addr_v := s_axi_ri.araddr;
			    dcnt_v := dcnt_c;

			    state := data_s;
			end if;

		    when data_s =>
			arready_v := '0';		-- done with addr

			rdata_v := data_at(addr_v);	-- map func
			rvalid_v := '1';		-- data is valid

			if s_axi_ri.rready = '1' then	-- master ready
			    dcnt_v := dcnt_v - 1;

			    if dcnt_v < 0 then		-- last read
				rlast_v := '1';
				rresp_v := "00";	-- okay
				-- rresp_v := "11";	-- decode error

				state := addr_s;
			    else
				addr_v := addr_next(addr_v);

				state := data_s;
			    end if;
			end if;

		    when busy_s =>
			state := addr_s;

		end case;
	    end if;
	end if;

	s_axi_ro.arready <= arready_v;
	s_axi_ro.rvalid <= rvalid_v;
	s_axi_ro.rlast <= rlast_v;

	s_axi_ro.rdata <= rdata_v;
	s_axi_ro.rresp <= rresp_v;

    end process;


    write_proc : process (
	s_axi_aclk, s_axi_areset, s_axi_wi )

	constant dcnt_c : natural := DATA_COUNT - 1;
	variable dcnt_v : integer range DATA_COUNT - 1 downto -1;
	variable addr_v : std_logic_vector(31 downto 0)
	    := (others => '0');

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable wdata_v : std_logic_vector(63 downto 0);
	variable wstrb_v : std_logic_vector(7 downto 0);
	variable bresp_v : std_logic_vector(1 downto 0) := "00";

	type w_state is (addr_s, data_s, resp_s, busy_s);

	variable state : w_state := addr_s;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset = '1' then
		addr_v := (others => '0');

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		wdata_v := (others => '0');
		wstrb_v := (others => '0');

		state := addr_s;

	    else
		case state is

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when addr_s =>
			awready_v := '1';		-- ready for transfer
			bvalid_v := '0';

			if s_axi_wi.awvalid = '1' then	-- address _is_ valid
			    addr_v := s_axi_wi.awaddr;
			    dcnt_v := dcnt_c;

			    state := data_s;
			end if;

		    when data_s =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    dcnt_v := dcnt_v - 1;

			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    if dcnt_v < 0 then		-- last read
				state := resp_s;
			    else
				addr_v := addr_v;	-- use wrap/inc

				state := data_s;
			    end if;
			end if;

		    when resp_s =>
			wready_v := '0';		-- done with write

			if s_axi_wi.bready = '1' then	-- master ready
			    bresp_v := "00";		-- transfer OK
			    -- bresp_v := "10";		-- slave error
			    -- bresp_v := "11";		-- decode error
			    bvalid_v := '1';		-- response valid

			    state := addr_s;
			end if;

		    when busy_s =>
			state := addr_s;

		end case;
	    end if;
	end if;

	s_axi_wo.awready <= awready_v;
	s_axi_wo.wready <= wready_v;
	s_axi_wo.bvalid <= bvalid_v;

	s_axi_wo.bresp <= bresp_v;

    end process;

end RTL;
