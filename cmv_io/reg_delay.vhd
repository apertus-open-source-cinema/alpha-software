----------------------------------------------------------------------------
--  reg_delay.vhd
--	ZedBoard simple VHDL example
--	Version 1.1
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

package val_array_pkg is
    type delay_val_array is array (natural range <>) of
	std_logic_vector (4 downto 0);
    type fail_cnt_array is array (natural range <>) of
	std_logic_vector (7 downto 0);
end val_array_pkg;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

use work.axi3ml_pkg.all;	-- AXI3 Lite Master
use work.val_array_pkg.ALL;


entity reg_delay is
    generic (
	REG_BASE : natural := 16#60000000#;
	CHANNELS : natural := 32
    );
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	delay_clk : in std_logic;
	delay_oval : in delay_val_array(CHANNELS - 1 downto 0);
	delay_val : out std_logic_vector(4 downto 0);
	delay_ld : out std_logic_vector(CHANNELS - 1 downto 0);
	--
	match : in std_logic_vector(CHANNELS - 1 downto 0);
	fail_cnt : in fail_cnt_array(CHANNELS - 1 downto 0);
	bitslip : out std_logic_vector(CHANNELS - 1 downto 0)
    );
end entity reg_delay;


architecture RTL of reg_delay is

    constant REG_END : natural := REG_BASE + (CHANNELS - 1) * 4;

    signal index : integer;

    signal load_go : std_logic;
    signal slip_go : std_logic;

    signal active : std_logic;

begin

    reg_rwseq_proc : process(
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, delay_oval )

	variable addr_v : integer := 0;
	variable index_v : natural range 0 to CHANNELS - 1 := 0;

	-- variable arid_v : std_logic_vector(11 downto 0);
	-- variable awid_v : std_logic_vector(11 downto 0);

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rdata_v : std_logic_vector(31 downto 0);
	variable rresp_v : std_logic_vector(1 downto 0) := "00";

	variable wdata_v : std_logic_vector(31 downto 0);
	variable wstrb_v : std_logic_vector(3 downto 0);
	variable bresp_v : std_logic_vector(1 downto 0) := "00";

	variable load_go_v : std_logic := '0';
	variable slip_go_v : std_logic := '0';

	type rw_state is (
	    idle,
	    r_addr, r_data, r_done,
	    w_addr, w_data, w_load, w_slip, w_wait, w_resp, w_done );

	variable state : rw_state := idle;

    begin

	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		-- arid_v := (others => '0');
		-- awid_v := (others => '0');
		addr_v := 0;

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		rdata_v := (others => '0');
		wdata_v := (others => '0');
		wstrb_v := (others => '0');

		state := idle;

	    else
		case state is
		    when idle =>
			if s_axi_ri.arvalid = '1' then	-- address _is_ valid
			    state := r_addr;

			elsif s_axi_wi.awvalid = '1' then -- address _is_ valid
			    state := w_addr;

			end if;

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when r_addr =>
			-- arid_v := s_axi_arid;
			addr_v := to_integer(
			    unsigned(s_axi_ri.araddr));
			arready_v := '1';		-- ready for transfer

			state := r_data;

		    when r_data =>
			arready_v := '0';		-- done with addr

			if addr_v < REG_BASE or
			    addr_v > REG_END then
			    rdata_v := x"BAD0BAD0";
			    rresp_v := "11";		-- decode error
			else
			    index_v := (addr_v - REG_BASE) / 4;
			    rdata_v(4 downto 0) := delay_oval(index_v);
			    rdata_v(23 downto 16) := fail_cnt(index_v);
			    rdata_v(28) := match(index_v);
			    rresp_v := "00";		-- okay
			end if;

			if s_axi_ri.rready = '1' then	-- master ready
			    rvalid_v := '1';		-- data is valid

			    state := r_done;
			end if;

		    when r_done =>
			rvalid_v := '0';

			state := idle;

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when w_addr =>
			-- awid_v := s_axi_awid;
			addr_v := to_integer(
			    unsigned(s_axi_wi.awaddr));
			awready_v := '1';		-- ready for transfer

			state := w_data;

		    when w_data =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    if addr_v < REG_BASE or
				addr_v > REG_END then
				bresp_v := "11";	-- decode error
				state := w_resp;

			    else
				index_v := (addr_v - REG_BASE) / 4;
				bresp_v := "00";	-- transfer OK

				if wdata_v(8) = '1' then
				    slip_go_v := '1';
				    state := w_slip;

				else
				    load_go_v := '1';
				    state := w_load;

				end if;
			    end if;
			end if;

		    when w_load =>
			if active = '1' then		-- wait for exec
			    load_go_v := '0';

			    state := w_wait;
			end if;

		    when w_slip =>
			if active = '1' then		-- wait for exec
			    slip_go_v := '0';

			    state := w_wait;
			end if;

		    when w_wait =>
			if active = '0' then	-- wait for finish
			    state := w_resp;
			end if;

		    when w_resp =>
			wready_v := '0';		-- done with write
			-- delay_rst(index) <= '1';

			if s_axi_wi.bready = '1' then	-- master ready
			    bvalid_v := '1';		-- response valid

			    state := w_done;
			end if;

		    when w_done =>
			bvalid_v := '0';

			state := idle;

		end case;
	    end if;
	end if;

	index <= index_v;

	s_axi_ro.arready <= arready_v;
	s_axi_ro.rvalid <= rvalid_v;

	s_axi_wo.awready <= awready_v;
	s_axi_wo.wready <= wready_v;
	s_axi_wo.bvalid <= bvalid_v;

	s_axi_ro.rdata <= rdata_v;
	s_axi_ro.rresp <= rresp_v;

	s_axi_wo.bresp <= bresp_v;

	delay_val <= wdata_v(4 downto 0);

	load_go <= load_go_v;
	slip_go <= slip_go_v;

	-- s_axi_ro.rid <= arid_v;
	-- s_axi_wo.bid <= awid_v;
	-- s_axi_wo.wid <= rwid;

    end process;

    reg_load_proc : process( delay_clk, index )

	variable active_v : std_logic := '0';

	variable delay_ld_v : std_logic := '0';
	variable bitslip_v : std_logic := '0';

	type load_state is (
	    idle_s, load_s, slip_s, wait_s );

	variable state : load_state := idle_s;

    begin
	
	delay_ld <= (others => 'L');
	bitslip <= (others => 'L');
	
	if falling_edge(delay_clk) then
	    case state is
		when idle_s =>
		    if load_go = '1' then	-- start load
			active_v := '1';
			delay_ld_v := '1';
			state := load_s;

		    elsif slip_go = '1' then	-- start bitslip
			active_v := '1';
			bitslip_v := '1';
			state := slip_s;

		    end if;

		when load_s =>			-- one cycle
		    delay_ld_v := '0';
		    state := wait_s;

		when slip_s =>			-- one cycle
		    bitslip_v := '0';
		    state := wait_s;

		when wait_s =>			-- wait for sync
		    if load_go = '0' and 
			slip_go = '0' then
			active_v := '0';
			state := idle_s;
		    end if;

	    end case;

	    delay_ld(index) <= delay_ld_v;
	    bitslip(index) <= bitslip_v;
	end if;

	active <= active_v;

    end process;

end RTL;
