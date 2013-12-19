----------------------------------------------------------------------------
--  top.vhd (for cmv_des)
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
--  Vivado 2013.4:
--    mkdir -p build.vivado
--    (cd build.vivado && vivado -mode tcl -source ../vivado.tcl)
--    (cd build.vivado && promgen -w -b -p bin -u 0 cmv_des.bit -data_width 32)
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3m_pkg.ALL;		-- AXI3 Master
use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master

use work.reduce_pkg.ALL;	-- Logic Reduction
use work.vivado_pkg.ALL;	-- Vivado Attributes



entity top is
    port (
	clk_100 : in std_logic;			-- input clock to FPGA
	--
	i2c0_sda : inout std_ulogic;
	i2c0_scl : inout std_ulogic;
	--
	i2c1_sda : inout std_ulogic;
	i2c1_scl : inout std_ulogic;
	--
	spi_en : out std_ulogic;
	spi_clk : out std_ulogic;
	spi_in : out std_ulogic;
	spi_out : in std_ulogic;
	--
	cmv_clk_in : out std_ulogic;
	cmv_t_exp1 : out std_ulogic;
	cmv_t_exp2 : out std_ulogic;
	cmv_frame_req : out std_ulogic;
	--
	cmv_lvds_clk_p : out std_logic;
	cmv_lvds_clk_n : out std_logic;
	--
	cmv_lvds_outclk_p : in std_logic;
	cmv_lvds_outclk_n : in std_logic;
	--
	cmv_lvds_data_p : in unsigned(31 downto 0);
	cmv_lvds_data_n : in unsigned(31 downto 0);
	--
	cmv_lvds_ctrl_p : in std_logic;
	cmv_lvds_ctrl_n : in std_logic;
	--
	pmod_jcm : out std_logic_vector(3 downto 0);
	pmod_jca : out std_logic_vector(3 downto 0);
	--
	pmod_jdm : out std_logic_vector(3 downto 0);
	pmod_jda : out std_logic_vector(3 downto 0);
	--
	btn_c : in std_logic;	-- Button: '1' is pressed
	btn_l : in std_logic;	-- Button: '1' is pressed
	btn_r : in std_logic;	-- Button: '1' is pressed
	btn_u : in std_logic;	-- Button: '1' is pressed
	btn_d : in std_logic;	-- Button: '1' is pressed
	--
	swi : in std_logic_vector(7 downto 0);
	led : out std_logic_vector(7 downto 0)
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    --------------------------------------------------------------------
    -- PS7 AXI Master Signals
    --------------------------------------------------------------------

    signal m_axi0_aclk : std_logic;
    signal m_axi0_areset_n : std_logic;

    signal m_axi0_ri : axi3m_read_in_r;
    signal m_axi0_ro : axi3m_read_out_r;
    signal m_axi0_wi : axi3m_write_in_r;
    signal m_axi0_wo : axi3m_write_out_r;

    signal m_axi0l_ri : axi3ml_read_in_r;
    signal m_axi0l_ro : axi3ml_read_out_r;
    signal m_axi0l_wi : axi3ml_write_in_r;
    signal m_axi0l_wo : axi3ml_write_out_r;

    signal m_axi00_aclk : std_logic;
    signal m_axi00_areset_n : std_logic;

    signal m_axi00_ri : axi3ml_read_in_r;
    signal m_axi00_ro : axi3ml_read_out_r;
    signal m_axi00_wi : axi3ml_write_in_r;
    signal m_axi00_wo : axi3ml_write_out_r;

    signal m_axi01_aclk : std_logic;
    signal m_axi01_areset_n : std_logic;

    signal m_axi01_ri : axi3ml_read_in_r;
    signal m_axi01_ro : axi3ml_read_out_r;
    signal m_axi01_wi : axi3ml_write_in_r;
    signal m_axi01_wo : axi3ml_write_out_r;

    --------------------------------------------------------------------
    -- I2C0 Signals
    --------------------------------------------------------------------

    signal i2c0_sda_i : std_ulogic;
    signal i2c0_sda_o : std_ulogic;
    signal i2c0_sda_t : std_ulogic;
    signal i2c0_sda_t_n : std_ulogic;

    signal i2c0_scl_i : std_ulogic;
    signal i2c0_scl_o : std_ulogic;
    signal i2c0_scl_t : std_ulogic;
    signal i2c0_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- I2C1 Signals
    --------------------------------------------------------------------

    signal i2c1_sda_i : std_ulogic;
    signal i2c1_sda_o : std_ulogic;
    signal i2c1_sda_t : std_ulogic;
    signal i2c1_sda_t_n : std_ulogic;

    signal i2c1_scl_i : std_ulogic;
    signal i2c1_scl_o : std_ulogic;
    signal i2c1_scl_t : std_ulogic;
    signal i2c1_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- CMV PLL Signals
    --------------------------------------------------------------------

    signal cmv_pll_locked : std_ulogic;

    signal cmv_lvds_clk : std_ulogic;
    signal cmv_dly_clk : std_ulogic;
    signal cmv_spi_clk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS MMCM Signals
    --------------------------------------------------------------------

    signal lvds_pll_locked : std_ulogic;

    signal hdmi_clk : std_ulogic;
    signal lvds_clk : std_ulogic;
    signal word_clk : std_ulogic;

    signal cmv_outclk : std_ulogic;

    --------------------------------------------------------------------
    -- CMV Serdes Signals
    --------------------------------------------------------------------

    constant CHANNELS : natural := 32;

    signal iserdes_clk : std_logic;
    signal iserdes_clkdiv : std_logic;
    signal iserdes_toggle : std_logic;
    signal iserdes_bitslip : std_logic_vector (CHANNELS + 1 downto 0);

    type data_par_t is array (natural range <>) of
	std_logic_vector (11 downto 0);

    signal cmv_data_par : data_par_t (CHANNELS downto 0)
	:= (others => (others => '0'));
    signal cmv_data_push : std_logic_vector (CHANNELS downto 0);

    signal cmv_rst_sys : std_logic;

    signal cmv_pattern : std_logic_vector (11 downto 0);
    signal cmv_match : std_logic_vector (CHANNELS + 1 downto 0);
    signal cmv_mismatch : std_logic_vector (CHANNELS + 1 downto 0);

    type data_t is array (natural range <>) of
	std_logic_vector (15 downto 0);

    signal cmv_data : data_t (CHANNELS - 1 downto 0)
	:= (others => (others => '0'));

    signal cmv_capture : std_logic;
    signal cmv_trigger : std_logic;

    --------------------------------------------------------------------
    -- LVDS IDELAY Signals
    --------------------------------------------------------------------

    signal idelay_valid : std_logic;

    signal idelay_in : std_logic_vector (CHANNELS + 1 downto 0);
    signal idelay_out : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- Protocol Checker Signals
    --------------------------------------------------------------------

    type status_t is array (natural range <>) of
	std_logic_vector (96 downto 0);

    signal pc_status : std_logic_vector (96 downto 0);
    signal pc_asserted : std_logic;

    component checker
	port (
	    system_resetn : in std_logic;
	    --
	    aclk : in std_logic;
	    aresetn : in std_logic;
	    --
	    pc_axi_awaddr : in std_logic_vector(31 downto 0);
	    pc_axi_awlen : in std_logic_vector(3 downto 0);
	    pc_axi_awsize : in std_logic_vector(2 downto 0);
	    pc_axi_awburst : in std_logic_vector(1 downto 0);
	    pc_axi_awlock : in std_logic_vector(1 downto 0);
	    pc_axi_awcache : in std_logic_vector(3 downto 0);
	    pc_axi_awprot : in std_logic_vector(2 downto 0);
	    pc_axi_awqos : in std_logic_vector(3 downto 0);
	    pc_axi_awvalid : in std_logic;
	    pc_axi_awready : in std_logic;
	    --
	    pc_axi_wlast : in std_logic;
	    pc_axi_wdata : in std_logic_vector(31 downto 0);
	    pc_axi_wstrb : in std_logic_vector(3 downto 0);
	    pc_axi_wvalid : in std_logic;
	    pc_axi_wready : in std_logic;
	    --
	    pc_axi_bresp : in std_logic_vector(1 downto 0);
	    pc_axi_bvalid : in std_logic;
	    pc_axi_bready : in std_logic;
	    --
	    pc_axi_araddr : in std_logic_vector(31 downto 0);
	    pc_axi_arlen : in std_logic_vector(3 downto 0);
	    pc_axi_arsize : in std_logic_vector(2 downto 0);
	    pc_axi_arburst : in std_logic_vector(1 downto 0);
	    pc_axi_arlock : in std_logic_vector(1 downto 0);
	    pc_axi_arcache : in std_logic_vector(3 downto 0);
	    pc_axi_arprot : in std_logic_vector(2 downto 0);
	    pc_axi_arqos : in std_logic_vector(3 downto 0);
	    pc_axi_arvalid : in std_logic;
	    pc_axi_arready : in std_logic;
	    --
	    pc_axi_rlast : in std_logic;
	    pc_axi_rdata : in std_logic_vector(31 downto 0);
	    pc_axi_rresp : in std_logic_vector(1 downto 0);
	    pc_axi_rvalid : in std_logic;
	    pc_axi_rready : in std_logic;
	    --
	    pc_status : out std_logic_vector(96 downto 0);
	    pc_asserted : out std_logic
	);
    end component checker;

    signal system_reset_n : std_logic := '0';

    --------------------------------------------------------------------
    -- Debug Signals
    --------------------------------------------------------------------

    signal pmod_clk : std_ulogic;

    attribute DONT_TOUCH of pmod_clk : signal is "TRUE";

    signal pmod_v0 : std_logic_vector(63 downto 0);

    attribute DONT_TOUCH of pmod_dbg_jc_inst : label is "TRUE";
    attribute MARK_DEBUG of pmod_v0 : signal is "TRUE";

    signal pmod_v1 : std_logic_vector(63 downto 0);

    attribute DONT_TOUCH of pmod_dbg_jd_inst : label is "TRUE";
    attribute MARK_DEBUG of pmod_v1 : signal is "TRUE";

begin
    --------------------------------------------------------------------
    -- PS7 Interface
    --------------------------------------------------------------------

    ps7_stub_inst : entity work.ps7_stub
	port map (
	    i2c0_sda_i => i2c0_sda_i,
	    i2c0_sda_o => i2c0_sda_o,
	    i2c0_sda_t_n => i2c0_sda_t_n,
	    --
	    i2c0_scl_i => i2c0_scl_i,
	    i2c0_scl_o => i2c0_scl_o,
	    i2c0_scl_t_n => i2c0_scl_t_n,
	    --
	    i2c1_sda_i => i2c1_sda_i,
	    i2c1_sda_o => i2c1_sda_o,
	    i2c1_sda_t_n => i2c1_sda_t_n,
	    --
	    i2c1_scl_i => i2c1_scl_i,
	    i2c1_scl_o => i2c1_scl_o,
	    i2c1_scl_t_n => i2c1_scl_t_n,
	    --
	    m_axi0_aclk => m_axi0_aclk,
	    m_axi0_areset_n => m_axi0_areset_n,
	    --
	    m_axi0_arid => m_axi0_ro.arid,
	    m_axi0_araddr => m_axi0_ro.araddr,
	    m_axi0_arburst => m_axi0_ro.arburst,
	    m_axi0_arlen => m_axi0_ro.arlen,
	    m_axi0_arsize => m_axi0_ro.arsize,
	    m_axi0_arprot => m_axi0_ro.arprot,
	    m_axi0_arvalid => m_axi0_ro.arvalid,
	    m_axi0_arready => m_axi0_ri.arready,
	    --
	    m_axi0_rid => m_axi0_ri.rid,
	    m_axi0_rdata => m_axi0_ri.rdata,
	    m_axi0_rlast => m_axi0_ri.rlast,
	    m_axi0_rresp => m_axi0_ri.rresp,
	    m_axi0_rvalid => m_axi0_ri.rvalid,
	    m_axi0_rready => m_axi0_ro.rready,
	    --
	    m_axi0_awid => m_axi0_wo.awid,
	    m_axi0_awaddr => m_axi0_wo.awaddr,
	    m_axi0_awburst => m_axi0_wo.awburst,
	    m_axi0_awlen => m_axi0_wo.awlen,
	    m_axi0_awsize => m_axi0_wo.awsize,
	    m_axi0_awprot => m_axi0_wo.awprot,
	    m_axi0_awvalid => m_axi0_wo.awvalid,
	    m_axi0_awready => m_axi0_wi.wready,
	    --
	    m_axi0_wid => m_axi0_wo.wid,
	    m_axi0_wdata => m_axi0_wo.wdata,
	    m_axi0_wstrb => m_axi0_wo.wstrb,
	    m_axi0_wlast => m_axi0_wo.wlast,
	    m_axi0_wvalid => m_axi0_wo.wvalid,
	    m_axi0_wready => m_axi0_wi.wready,
	    --
	    m_axi0_bid => m_axi0_wi.bid,
	    m_axi0_bresp => m_axi0_wi.bresp,
	    m_axi0_bvalid => m_axi0_wi.bvalid,
	    m_axi0_bready => m_axi0_wo.bready );

    AXI_check_inst : checker
	port map (
	    system_resetn => system_reset_n,
	    --
	    aclk => m_axi0_aclk,
	    aresetn => m_axi0_areset_n,
	    --
	    pc_axi_awaddr => m_axi0_wo.awaddr,
	    pc_axi_awlen => m_axi0_wo.awlen,
	    pc_axi_awsize => "011",
	    pc_axi_awburst => m_axi0_wo.awburst,
	    pc_axi_awlock => (others => '0'),
	    pc_axi_awcache => (others => '0'),
	    pc_axi_awprot => m_axi0_wo.awprot,
	    pc_axi_awqos => (others => '0'),
	    pc_axi_awvalid => m_axi0_wo.awvalid,
	    pc_axi_awready => m_axi0_wi.awready,
	    --
	    pc_axi_wlast => m_axi0_wo.wlast,
	    pc_axi_wdata => m_axi0_wo.wdata,
	    pc_axi_wstrb => m_axi0_wo.wstrb,
	    pc_axi_wvalid => m_axi0_wo.wvalid,
	    pc_axi_wready => m_axi0_wi.wready,
	    --
	    pc_axi_bresp => m_axi0_wi.bresp,
	    pc_axi_bvalid => m_axi0_wi.bvalid,
	    pc_axi_bready => m_axi0_wo.bready,
	    --
	    pc_axi_araddr => m_axi0_ro.araddr,
	    pc_axi_arlen => m_axi0_ro.arlen,
	    pc_axi_arsize => "011",
	    pc_axi_arburst => m_axi0_ro.arburst,
	    pc_axi_arlock => (others => '0'),
	    pc_axi_arcache => (others => '0'),
	    pc_axi_arprot => m_axi0_ro.arprot,
	    pc_axi_arqos => (others => '0'),
	    pc_axi_arvalid => m_axi0_ro.arvalid,
	    pc_axi_arready => m_axi0_ri.arready,
	    --
	    pc_axi_rlast => m_axi0_ri.rlast,
	    pc_axi_rdata => m_axi0_ri.rdata,
	    pc_axi_rresp => m_axi0_ri.rresp,
	    pc_axi_rvalid => m_axi0_ri.rvalid,
	    pc_axi_rready => m_axi0_ro.rready,
	    --
	    pc_status => pc_status,
	    pc_asserted => pc_asserted );

    --------------------------------------------------------------------
    -- I2C bus #0
    --------------------------------------------------------------------

    i2c0_sda_t <= not i2c0_sda_t_n;

    IOBUF_sda_inst0 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c0_sda_o, O => i2c0_sda_i,
	    T => i2c0_sda_t, IO => i2c0_sda );

    i2c0_scl_t <= not i2c0_scl_t_n;

    IOBUF_scl_inst0 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c0_scl_o, O => i2c0_scl_i,
	    T => i2c0_scl_t, IO => i2c0_scl );

    --------------------------------------------------------------------
    -- I2C bus #1
    --------------------------------------------------------------------

    i2c1_sda_t <= not i2c1_sda_t_n;

    IOBUF_sda_inst1 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c1_sda_o, O => i2c1_sda_i,
	    T => i2c1_sda_t, IO => i2c1_sda );

    i2c1_scl_t <= not i2c1_scl_t_n;

    IOBUF_scl_inst1 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c1_scl_o, O => i2c1_scl_i,
	    T => i2c1_scl_t, IO => i2c1_scl );

    --------------------------------------------------------------------
    -- CMV PLL/LVDS MMCM
    --------------------------------------------------------------------

    cmv_pll_inst : entity work.cmv_pll
	port map (
	    ref_clk_in => clk_100,
	    --
	    pll_locked => cmv_pll_locked,
	    --
	    lvds_clk => cmv_lvds_clk,
	    dly_clk => cmv_dly_clk,
	    cmv_clk => cmv_clk_in,
	    spi_clk => cmv_spi_clk );

    lvds_pll_inst : entity work.lvds_pll
	port map (
	    ref_clk_in => cmv_outclk,
	    --
	    pll_locked => lvds_pll_locked,
	    --
	    hdmi_clk => hdmi_clk,
	    lvds_clk => lvds_clk,
	    word_clk => word_clk );

    --------------------------------------------------------------------
    -- AXI3 Interconnect
    --------------------------------------------------------------------

    axi_lite_inst0 : entity work.axi_lite
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,

	    s_axi_ro => m_axi0_ri,
	    s_axi_ri => m_axi0_ro,
	    s_axi_wo => m_axi0_wi,
	    s_axi_wi => m_axi0_wo,

	    m_axi_ro => m_axi0l_ro,
	    m_axi_ri => m_axi0l_ri,
	    m_axi_wo => m_axi0l_wo,
	    m_axi_wi => m_axi0l_wi );

    axi_split_inst : entity work.axi_split
	generic map (
	    SPLIT_BIT => 16 )
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,
	    --
	    s_axi_ro => m_axi0l_ri,
	    s_axi_ri => m_axi0l_ro,
	    s_axi_wo => m_axi0l_wi,
	    s_axi_wi => m_axi0l_wo,
	    --
	    m_axi0_aclk => m_axi00_aclk,
	    m_axi0_areset_n => m_axi00_areset_n,
	    --
	    m_axi0_ri => m_axi00_ri,
	    m_axi0_ro => m_axi00_ro,
	    m_axi0_wi => m_axi00_wi,
	    m_axi0_wo => m_axi00_wo,
	    --
	    m_axi1_aclk => m_axi01_aclk,
	    m_axi1_areset_n => m_axi01_areset_n,
	    --
	    m_axi1_ri => m_axi01_ri,
	    m_axi1_ro => m_axi01_ro,
	    m_axi1_wi => m_axi01_wi,
	    m_axi1_wo => m_axi01_wo );

    --------------------------------------------------------------------
    -- CMV SPI Interface
    --------------------------------------------------------------------

    reg_spi_inst : entity work.reg_spi
	port map (
	    s_axi_aclk => m_axi00_aclk,
	    s_axi_areset_n => m_axi00_areset_n,
	    --
	    s_axi_ro => m_axi00_ri,
	    s_axi_ri => m_axi00_ro,
	    s_axi_wo => m_axi00_wi,
	    s_axi_wi => m_axi00_wo,
	    --
	    spi_clk_in => cmv_spi_clk,
	    --
	    spi_clk => spi_clk,
	    spi_in => spi_in,
	    spi_out => spi_out,
	    spi_en => spi_en );

    m_axi0_aclk <= clk_100;

    --------------------------------------------------------------------
    -- Delay Control
    --------------------------------------------------------------------

    IDELAYCTRL_inst : IDELAYCTRL
	port map (
	    RDY => idelay_valid,	-- 1-bit output indicates validity of the REFCLK
	    REFCLK => cmv_dly_clk,	-- 1-bit reference clock input
	    RST => '0' );		-- 1-bit reset input

    --------------------------------------------------------------------
    -- Delay Register File
    --------------------------------------------------------------------

    reg_delay_inst : entity work.reg_delay
	generic map (
	    REG_BASE => 16#60000000#,
	    CHANNELS => CHANNELS + 2 )
	port map (
	    s_axi_aclk => m_axi01_aclk,
	    s_axi_areset_n => m_axi01_areset_n,
	    --
	    s_axi_ro => m_axi01_ri,
	    s_axi_ri => m_axi01_ro,
	    s_axi_wo => m_axi01_wi,
	    s_axi_wi => m_axi01_wo,
	    --
	    delay_clk => iserdes_clkdiv,	-- in
	    --
	    delay_in => idelay_in,		-- in
	    delay_out => idelay_out,		-- out
	    --
	    match => cmv_match,			-- in
	    mismatch => cmv_mismatch,		-- in
	    bitslip => iserdes_bitslip );	-- out

    --------------------------------------------------------------------
    -- LVDS Input and Deserializer
    --------------------------------------------------------------------

    cmv_frame_req <= btn_c;
    cmv_t_exp1 <= btn_l;
    cmv_t_exp2 <= btn_r;

    OBUFDS_inst : OBUFDS
	generic map (
	    IOSTANDARD => "LVDS_25",
	    SLEW => "SLOW" )
	port map (
	    O => cmv_lvds_clk_p,
	    OB => cmv_lvds_clk_n,
	    I => cmv_lvds_clk );

    IBUFDS_inst : IBUFDS
	generic map (
	    DIFF_TERM => TRUE,
	    IBUF_LOW_PWR => TRUE,
	    IOSTANDARD => "LVDS_25" )
	port map (
	    O => idelay_in(CHANNELS + 1),
	    I => cmv_lvds_outclk_p,
	    IB => cmv_lvds_outclk_n );

    GEN_LVDS: for I in CHANNELS downto 0 generate
    begin
	CTRL : if I = CHANNELS generate
	    IBUFDS_i : IBUFDS
		generic map (
		    DIFF_TERM => TRUE,
		    IBUF_LOW_PWR => TRUE,
		    IOSTANDARD => "LVDS_25" )
		port map (
		    O => idelay_in(I),
		    I => cmv_lvds_ctrl_p,
		    IB => cmv_lvds_ctrl_n );

	    cmv_serdes_inst : entity work.cmv_serdes
		port map (
		    serdes_clk	  => iserdes_clk,
		    serdes_clkdiv => iserdes_clkdiv,
		    serdes_toggle => iserdes_toggle,
		    serdes_rst	  => cmv_rst_sys,
		    --
		    data_ser	  => idelay_out(I),
		    data_par	  => cmv_data_par(I),
		    data_push	  => cmv_data_push(I),
		    --
		    pattern	  => x"080",
		    match	  => cmv_match(I),
		    mismatch	  => cmv_mismatch(I),
		    --
		    bitslip	  => iserdes_bitslip(I) );

	end generate;

	DATA : if I < CHANNELS generate
	    IBUFDS_i : IBUFDS
		generic map (
		    DIFF_TERM => TRUE,
		    IBUF_LOW_PWR => TRUE,
		    IOSTANDARD => "LVDS_25" )
		port map (
		    O => idelay_in(I),
		    I => cmv_lvds_data_p(I),
		    IB => cmv_lvds_data_n(I) );

	    cmv_data(I) <=
		cmv_data_par(CHANNELS)(3 downto 0) &
		cmv_data_par(I)(11 downto 0);

	    cmv_serdes_inst : entity work.cmv_serdes
		port map (
		    serdes_clk	  => iserdes_clk,
		    serdes_clkdiv => iserdes_clkdiv,
		    serdes_toggle => iserdes_toggle,
		    serdes_rst	  => cmv_rst_sys,
		    --
		    data_ser	  => idelay_out(I),
		    data_par	  => cmv_data_par(I),
		    data_push	  => cmv_data_push(I),
		    --
		    pattern	  => cmv_pattern,
		    match	  => cmv_match(I),
		    mismatch	  => cmv_mismatch(I),
		    --
		    bitslip	  => iserdes_bitslip(I) );

	end generate;
    end generate;

    cmv_outclk <= idelay_out(CHANNELS + 1);

    iserdes_clk <= lvds_clk;
    iserdes_clkdiv <= word_clk;

    toggle_proc : process (iserdes_clkdiv)
    begin
	if rising_edge(iserdes_clkdiv) then
	    if iserdes_bitslip(CHANNELS + 1) = '0' then
		iserdes_toggle <= not iserdes_toggle;
	    end if;
	end if;
    end process;

    -- iserdes_clk <= cmv_outclk;

    cmv_rst_sys <= '0';
    cmv_pattern <= "101010010101";

    --------------------------------------------------------------------
    -- LED Status output
    --------------------------------------------------------------------

    led(0) <= cmv_pll_locked;
    led(1) <= lvds_pll_locked;
    led(2) <= idelay_valid;

    div_lvds_inst0 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => cmv_lvds_clk,
	    clk_out => led(6) );

    div_lvds_inst1 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => lvds_clk,
	    clk_out => led(7) );

    led(5 downto 3) <= (others => '0');

    --------------------------------------------------------------------
    -- PMOD Debug
    --------------------------------------------------------------------

    pmod_clk <= clk_100;

    pmod_dbg_jd_inst : entity work.pmod_debug
	generic map (
	    PRESCALE => 12 )
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v0,
	    --
	    jxm => pmod_jdm,
	    jxa => pmod_jda );

    pmod_dbg_jc_inst : entity work.pmod_debug
	generic map (
	    PRESCALE => 12 )
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v1,
	    --
	    jxm => pmod_jcm,
	    jxa => pmod_jca );

    pmod_proc : process (
	pmod_clk, swi,
	cmv_match, cmv_mismatch, cmv_data_par,
	m_axi0_wo, m_axi0_wi, m_axi0_ro, m_axi0_ri )
    begin
	case swi(3 downto 0) is
	    when "0000" =>
		pmod_v0 <= cmv_match(0)	 & cmv_mismatch(0)  & "00" & cmv_data_par(0) &
			   cmv_match(1)	 & cmv_mismatch(1)  & "00" & cmv_data_par(1) &
			   cmv_match(2)	 & cmv_mismatch(2)  & "00" & cmv_data_par(2) &
			   cmv_match(3)	 & cmv_mismatch(3)  & "00" & cmv_data_par(3);

		pmod_v1 <= cmv_match(4)	 & cmv_mismatch(4)  & "00" & cmv_data_par(4) &
			   cmv_match(5)	 & cmv_mismatch(5)  & "00" & cmv_data_par(5) &
			   cmv_match(6)	 & cmv_mismatch(6)  & "00" & cmv_data_par(6) &
			   cmv_match(7)	 & cmv_mismatch(7)  & "00" & cmv_data_par(7);

	    when "0001" =>
		pmod_v0 <= cmv_match(8)	 & cmv_mismatch(8)  & "00" & cmv_data_par(8) &
			   cmv_match(9)	 & cmv_mismatch(9)  & "00" & cmv_data_par(9) &
			   cmv_match(10) & cmv_mismatch(10) & "00" & cmv_data_par(10) &
			   cmv_match(11) & cmv_mismatch(11) & "00" & cmv_data_par(11);

		pmod_v1 <= cmv_match(12) & cmv_mismatch(12) & "00" & cmv_data_par(12) &
			   cmv_match(13) & cmv_mismatch(13) & "00" & cmv_data_par(13) &
			   cmv_match(14) & cmv_mismatch(14) & "00" & cmv_data_par(14) &
			   cmv_match(15) & cmv_mismatch(15) & "00" & cmv_data_par(15);

	    when "0010" =>
		pmod_v0 <= cmv_match(16) & cmv_mismatch(16) & "00" & cmv_data_par(16) &
			   cmv_match(17) & cmv_mismatch(17) & "00" & cmv_data_par(17) &
			   cmv_match(18) & cmv_mismatch(18) & "00" & cmv_data_par(18) &
			   cmv_match(19) & cmv_mismatch(19) & "00" & cmv_data_par(19);

		pmod_v1 <= cmv_match(20) & cmv_mismatch(20) & "00" & cmv_data_par(20) &
			   cmv_match(21) & cmv_mismatch(21) & "00" & cmv_data_par(21) &
			   cmv_match(22) & cmv_mismatch(22) & "00" & cmv_data_par(22) &
			   cmv_match(23) & cmv_mismatch(23) & "00" & cmv_data_par(23);

	    when "0011" =>
		pmod_v0 <= cmv_match(24) & cmv_mismatch(24) & "00" & cmv_data_par(24) &
			   cmv_match(25) & cmv_mismatch(25) & "00" & cmv_data_par(25) &
			   cmv_match(26) & cmv_mismatch(26) & "00" & cmv_data_par(26) &
			   cmv_match(27) & cmv_mismatch(27) & "00" & cmv_data_par(27);

		pmod_v1 <= cmv_match(28) & cmv_mismatch(28) & "00" & cmv_data_par(28) &
			   cmv_match(29) & cmv_mismatch(29) & "00" & cmv_data_par(29) &
			   cmv_match(30) & cmv_mismatch(30) & "00" & cmv_data_par(30) &
			   cmv_match(31) & cmv_mismatch(31) & "00" & cmv_data_par(31);

	    when "0100" =>
		pmod_v0 <= x"000000000000" &
			   cmv_match(32) & cmv_mismatch(32) & "00" & cmv_data_par(32);

		pmod_v1 <= (others => '0');

	    when "0101" =>
		pmod_v0(63 downto 33) <= (others => '1');
		pmod_v0(32 downto 0) <= pc_status(96 downto 64);
		pmod_v1 <= pc_status(63 downto 0);

	    when others =>
		pmod_v0 <= (others => '0');

		pmod_v1 <= (others => '0');
	end case;
    end process;

end RTL;
