----------------------------------------------------------------------------
--  reg_delay.vhd
--	AXI3 Lite IDELAY/SERDES Interface
--	Version 1.3
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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;


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
	--
	delay_in : in std_logic_vector(CHANNELS - 1 downto 0);
	delay_out : out std_logic_vector(CHANNELS - 1 downto 0);
	--
	match : in std_logic_vector(CHANNELS - 1 downto 0);
	mismatch : in std_logic_vector(CHANNELS - 1 downto 0);
	--
	bitslip : out std_logic_vector(CHANNELS - 1 downto 0)
    );
end entity reg_delay;


architecture RTL of reg_delay is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

	-- s_axi_aclk domain
    signal axi_dly_ld : std_logic := '0';
    signal axi_dly_ld_done : std_logic;
    signal axi_dly_ld_active : std_logic;

    signal axi_dly_rd : std_logic := '0';
    signal axi_dly_rd_done : std_logic;
    signal axi_dly_rd_active : std_logic;

	-- delay_clk domain
    signal dly_ld : std_logic;
    signal dly_ld_done : std_logic := '0';
    signal dly_ld_action : std_logic;

    signal dly_rd : std_logic;
    signal dly_rd_done : std_logic := '0';
    signal dly_rd_action : std_logic;

    signal delay_ld : std_logic_vector(CHANNELS - 1 downto 0);

    type delay_val_t is array (natural range <>) of
	std_logic_vector (4 downto 0);
    signal delay_oval : delay_val_t(CHANNELS - 1 downto 0);

	-- mixed domain
    signal index : integer := 1;
    signal delay_val : std_logic_vector(4 downto 0);
    signal delay_val_out : std_logic_vector(4 downto 0);

    signal match_out : std_logic;
    signal mismatch_out : std_logic;
    signal bitslip_in : std_logic;

begin

    ping_pong_inst0 : entity work.ping_pong
	port map (
	    clk_a => s_axi_aclk,
	    ping_a => axi_dly_ld,		-- in,  toggle
	    pong_a => axi_dly_ld_done,		-- out, toggle
	    active => axi_dly_ld_active,	-- out
	    --
	    clk_b => delay_clk,
	    ping_b => dly_ld,			-- out, toggle
	    pong_b => dly_ld_done,		-- in,  toggle
	    action => dly_ld_action );		-- out

    ping_pong_inst1 : entity work.ping_pong
	port map (
	    clk_a => s_axi_aclk,
	    ping_a => axi_dly_rd,		-- in,  toggle
	    pong_a => axi_dly_rd_done,		-- out, toggle
	    active => axi_dly_rd_active,	-- out
	    --
	    clk_b => delay_clk,
	    ping_b => dly_rd,			-- out, toggle
	    pong_b => dly_rd_done,		-- in,  toggle
	    action => dly_rd_action );		-- out

    GEN_DELAY: for I in CHANNELS - 1 downto 0 generate
	IDELAY_inst : IDELAYE2
	    generic map (
		HIGH_PERFORMANCE_MODE => "TRUE",
		IDELAY_TYPE	      => "VAR_LOAD",
		IDELAY_VALUE	      => 0,
		REFCLK_FREQUENCY      => 200.0,
		SIGNAL_PATTERN        => "DATA" )
	    port map (
		IDATAIN     => delay_in(I),
		DATAIN      => '0',
		DATAOUT     => delay_out(I),
		CINVCTRL    => '0',
		CNTVALUEIN  => delay_val,
		CNTVALUEOUT => delay_oval(I),
		LD	    => delay_ld(I),
		LDPIPEEN    => '0',
		C	    => delay_clk,
		CE	    => '0',
		INC	    => '0',
		REGRST      => '0' );

    end generate;

    --------------------------------------------------------------------
    -- Load Action and Reply
    --------------------------------------------------------------------

    ld_action_proc : process (delay_clk, dly_ld_action)
    begin
	if rising_edge(delay_clk) then
	    if dly_ld_action = '1' then
		dly_ld_done <= dly_ld;	-- turn around
		delay_ld(index) <= '1';
		bitslip(index) <= bitslip_in;
	    else
		delay_ld(index) <= '0';
		bitslip(index) <= '0';
	    end if;
	end if;
    end process;

    --------------------------------------------------------------------
    -- Read Action and Reply
    --------------------------------------------------------------------

    rd_action_proc : process (delay_clk, dly_rd_action)
    begin
	if rising_edge(delay_clk) then
	    if dly_rd_action = '1' then
		delay_val_out <= delay_oval(index);
		match_out <= match(index);
		mismatch_out <= mismatch(index);
		dly_rd_done <= dly_rd;	-- turn around
	    end if;
	end if;
    end process;

    --------------------------------------------------------------------
    -- AXI Read/Write
    --------------------------------------------------------------------

    reg_rwseq_proc : process(
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, delay_val_out )

	variable addr_v : std_logic_vector(31 downto 0);
	variable index_v : integer := 0;

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rresp_v : std_logic_vector(1 downto 0) := "00";

	variable wdata_v : std_logic_vector(31 downto 0);
	variable wstrb_v : std_logic_vector(3 downto 0);
	variable bresp_v : std_logic_vector(1 downto 0) := "00";

	type rw_state is (
	    idle,
	    r_addr, r_go, r_dly, r_data, r_done,
	    w_addr, w_data, w_go, w_dly, w_resp, w_done );

	variable state : rw_state := idle;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

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
			addr_v := s_axi_ri.araddr;
			index_v :=
			    to_integer(unsigned(addr_v) - REG_BASE) / 4;

			if index_v >= 0 and
			    index_v < CHANNELS then
			    index <= index_v;
			    rresp_v := "00";		-- okay
			else
			    rresp_v := "11";		-- decode error
			end if;

			arready_v := '1';		-- ready for transfer
			state := r_go;

		    when r_go =>			-- trigger rd action
			arready_v := '0';		-- done with addr

			axi_dly_rd <= not axi_dly_rd;	-- toggle trigger
			state := r_dly;

		    when r_dly =>			-- wait for delay
			if axi_dly_rd_active = '0' then
			    state := r_data;
			end if;

		    when r_data =>
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
			addr_v := s_axi_wi.awaddr;
			index_v :=
			    to_integer(unsigned(addr_v) - REG_BASE) / 4;

			if index_v >= 0 and
			    index_v < CHANNELS then
			    index <= index_v;
			    bresp_v := "00";		-- okay
			else
			    bresp_v := "11";		-- decode error
			end if;

			awready_v := '1';		-- ready for transfer
			state := w_data;

		    when w_data =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    state := w_go;
			end if;

		    when w_go =>
			wready_v := '0';		-- done with write

			axi_dly_ld <= not axi_dly_ld;	-- toggle trigger
			state := w_dly;

		    when w_dly =>			-- wait for delay
			if axi_dly_ld_active = '0' then
			    state := w_resp;
			end if;

		    when w_resp =>
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

	s_axi_ro.arready <= arready_v;
	s_axi_ro.rvalid <= rvalid_v;

	s_axi_wo.awready <= awready_v;
	s_axi_wo.wready <= wready_v;
	s_axi_wo.bvalid <= bvalid_v;

	s_axi_ro.rresp <= rresp_v;

	s_axi_wo.bresp <= bresp_v;

	bitslip_in <= wdata_v(31);
	delay_val <= wdata_v(4 downto 0);

	s_axi_ro.rdata(29) <= match_out;
	s_axi_ro.rdata(28) <= mismatch_out;
	s_axi_ro.rdata(4 downto 0) <= delay_val_out;

    end process;

end RTL;
