----------------------------------------------------------------------------
--  reg_lut5.vhd
--	AXI3 Lite CFGLUT5 Interface
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package lut5_pkg is

    type lut5_in_r is record
	I0	: std_logic;
	I1	: std_logic;
	I2	: std_logic;
	I3	: std_logic;
	I4	: std_logic;
    end record;

    type lut5_in_a is array (natural range <>) of
	lut5_in_r;

    type lut5_out_r is record
	O5	: std_logic;
	O6	: std_logic;
    end record;

    type lut5_out_a is array (natural range <>) of
	lut5_out_r;

end package;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.lut5_pkg.ALL;		-- LUT5 Record/Array
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity reg_lut5 is
    generic (
	REG_BASE : natural := 16#60000000#;
	LUT_COUNT : natural := 4
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
	lut_clk_in : in std_logic;
	--
	lut_in : in lut5_in_a (LUT_COUNT - 1 downto 0);
	lut_out : out lut5_out_a (LUT_COUNT - 1 downto 0)
    );
end entity reg_lut5;


architecture RTL of reg_lut5 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant INDEX_WIDTH : natural := 6;

	-- s_axi_aclk domain
    signal axi_lut_go : std_logic := '0';
    signal axi_lut_done : std_logic;
    signal axi_lut_active : std_logic;

    signal reg_ab_in : std_logic_vector (INDEX_WIDTH + 32 downto 0);
    signal reg_ba_out : std_logic_vector (31 downto 0);

    alias axi_lut_index : std_logic_vector (INDEX_WIDTH - 1 downto 0)
	is reg_ab_in(INDEX_WIDTH + 32 downto 33);

    alias axi_lut_write : std_logic is reg_ab_in(32);
    alias axi_lut_din : std_logic_vector (31 downto 0)
	is reg_ab_in(31 downto 0);

    alias axi_lut_dout : std_logic_vector (31 downto 0)
	is reg_ba_out(31 downto 0);

	-- lut_clk_in domain
    signal lut_go : std_logic;
    signal lut_done : std_logic := '0';
    signal lut_action : std_logic;

    signal lut_en : std_logic_vector (LUT_COUNT - 1 downto 0);
    signal lut_cdi : std_logic_vector (LUT_COUNT - 1 downto 0);
    signal lut_cdo : std_logic_vector (LUT_COUNT - 1 downto 0);

    signal reg_ba_in : std_logic_vector (31 downto 0);
    signal reg_ab_out : std_logic_vector (INDEX_WIDTH + 32 downto 0);

    alias lut_index : std_logic_vector (INDEX_WIDTH - 1 downto 0)
	is reg_ab_out(INDEX_WIDTH + 32 downto 33);

    alias lut_write : std_logic is reg_ab_out(32);
    alias lut_din : std_logic_vector (31 downto 0)
	is reg_ab_out(31 downto 0);

    alias lut_dout : std_logic_vector (31 downto 0)
	is reg_ba_in(31 downto 0);

	-- cfg lut_clk_in domain
    signal lut_clk : std_logic_vector (LUT_COUNT - 1 downto 0);

    type lut_val_a is array (natural range <>) of
	std_logic_vector (31 downto 0);

    signal cfg_lut_dout : lut_val_a (LUT_COUNT - 1 downto 0);
    signal cfg_lut_action : std_logic_vector (LUT_COUNT - 1 downto 0);
    signal cfg_lut_active : std_logic_vector (LUT_COUNT - 1 downto 0);
    signal cfg_lut_latch : std_logic_vector (LUT_COUNT - 1 downto 0);

begin

    pp_reg_sync_inst : entity work.pp_reg_sync
	generic map (
	    AB_WIDTH => INDEX_WIDTH + 33,
	    BA_WIDTH => 32 )
	port map (
	    clk_a => s_axi_aclk,
	    ping_a => axi_lut_go,		-- in,  toggle
	    pong_a => axi_lut_done,		-- out, toggle
	    active => axi_lut_active,		-- out
	    --
	    reg_ab_in => reg_ab_in,
	    reg_ba_out => reg_ba_out,
	    --
	    clk_b => lut_clk_in,
	    ping_b => lut_go,			-- out, toggle
	    pong_b => lut_done,			-- in,  toggle
	    action => lut_action,		-- out
	    --
	    reg_ba_in => reg_ba_in,
	    reg_ab_out => reg_ab_out );


    GEN_LUT5: for I in LUT_COUNT - 1 downto 0 generate
	CFGLUT5_inst : CFGLUT5
	    generic map (
		INIT => x"00000000" )
	    port map (
		CLK => lut_clk(I),
		CE  => lut_en(I),
		CDI => lut_cdi(I),
		CDO => lut_cdo(I),
		--
		I0  => lut_in(I).I0,
		I1  => lut_in(I).I1,
		I2  => lut_in(I).I2,
		I3  => lut_in(I).I3,
		I4  => lut_in(I).I4,
		--
		O5  => lut_out(I).O5,
		O6  => lut_out(I).O6 );

	cfg_lut5_inst : entity work.cfg_lut5
	    port map (
		lut_clk_in => lut_clk_in,
		--
		lut_action => cfg_lut_action(I),
		lut_active => cfg_lut_active(I),
		--
		lut_write => lut_write,
		lut_din => lut_din,
		--
		lut_dout => cfg_lut_dout(I),
		lut_latch => cfg_lut_latch(I),
		--
		lut_clk => lut_clk(I),		-- out
		lut_en => lut_en(I),		-- out
		lut_cdi => lut_cdi(I),		-- out
		lut_cdo => lut_cdo(I) );	-- in

    end generate;

    --------------------------------------------------------------------
    -- One Clock Cycle Trigger
    --------------------------------------------------------------------

    action_proc : process (lut_clk_in, lut_action)
	variable lut_action_v : std_logic := '0';
	variable index_v : natural;
    begin
	if rising_edge(lut_clk_in) then
	    index_v := to_integer(unsigned(lut_index));
	    cfg_lut_action <= (others => '0');

	    if lut_action = '1' and
		lut_action_v = '0' then
		cfg_lut_action(index_v) <= '1';
	    end if;

	    lut_action_v := lut_action;
	end if;
    end process;

    --------------------------------------------------------------------
    -- Falling Edge on Active
    --------------------------------------------------------------------

    done_proc : process (lut_clk_in, cfg_lut_latch)
	variable lut_active_v : std_logic := '0';
	variable index_v : natural;
    begin
	if rising_edge(lut_clk_in) then
	    index_v := to_integer(unsigned(lut_index));

	    if cfg_lut_active(index_v) = '0' and
		lut_active_v = '1' then
		lut_dout <= cfg_lut_dout(index_v);
		lut_done <= lut_go;	-- turn around
	    end if;

	    lut_active_v := cfg_lut_active(index_v);
	end if;
    end process;

    --------------------------------------------------------------------
    -- AXI Read/Write
    --------------------------------------------------------------------

    reg_rwseq_proc : process(
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, axi_lut_dout )

	variable addr_v : std_logic_vector (31 downto 0);
	variable index_v : integer := 0;

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rresp_v : std_logic_vector (1 downto 0) := "00";

	variable wdata_v : std_logic_vector (31 downto 0);
	variable wstrb_v : std_logic_vector (3 downto 0);
	variable bresp_v : std_logic_vector (1 downto 0) := "00";

	type rw_state is (
	    idle_s,
	    r_addr_s, r_lut_s, r_data_s,
	    w_addr_s, w_data_s, w_lut_s, w_resp_s );

	variable state : rw_state := idle_s;

	function index_func ( val : integer )
	    return std_logic_vector is
	begin
	    return std_logic_vector (to_unsigned(val, INDEX_WIDTH));
	end function;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		state := idle_s;

	    else
		case state is
		    when idle_s =>
			rvalid_v := '0';
			bvalid_v := '0';

			if s_axi_ri.arvalid = '1' then	-- address _is_ valid
			    state := r_addr_s;

			elsif s_axi_wi.awvalid = '1' then -- address _is_ valid
			    state := w_addr_s;

			end if;

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when r_addr_s =>
			addr_v := s_axi_ri.araddr;
			index_v :=
			    to_integer(unsigned(addr_v) - REG_BASE) / 4;

			if index_v >= 0 and
			    index_v < LUT_COUNT then
			    axi_lut_index <= index_func(index_v);
			    rresp_v := "00";		-- okay
			else
			    rresp_v := "11";		-- decode error
			end if;

			axi_lut_write <= '0';
			axi_lut_go <= not axi_lut_go;	-- toggle trigger

			arready_v := '1';		-- ready for transfer
			state := r_lut_s;

		    when r_lut_s =>			-- wait for delay
			arready_v := '0';		-- done with addr

			if axi_lut_active = '0' then
			    state := r_data_s;
			end if;

		    when r_data_s =>
			if s_axi_ri.rready = '1' then	-- master ready
			    rvalid_v := '1';		-- data is valid

			    state := idle_s;
			end if;

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when w_addr_s =>
			addr_v := s_axi_wi.awaddr;
			index_v :=
			    to_integer(unsigned(addr_v) - REG_BASE) / 4;

			if index_v >= 0 and
			    index_v < LUT_COUNT then
			    axi_lut_index <= index_func(index_v);
			    bresp_v := "00";		-- okay
			else
			    bresp_v := "11";		-- decode error
			end if;

			awready_v := '1';		-- ready for transfer
			state := w_data_s;

		    when w_data_s =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    axi_lut_write <= '1';
			    axi_lut_go <= not axi_lut_go;

			    state := w_lut_s;
			end if;

		    when w_lut_s =>			-- wait for delay
			wready_v := '0';		-- done with write

			if axi_lut_active = '0' then
			    state := w_resp_s;
			end if;

		    when w_resp_s =>
			if s_axi_wi.bready = '1' then	-- master ready
			    bvalid_v := '1';		-- response valid

			    state := idle_s;
			end if;

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

	axi_lut_din <= wdata_v;

	s_axi_ro.rdata <= axi_lut_dout;

    end process;

end RTL;
