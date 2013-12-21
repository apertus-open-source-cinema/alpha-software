----------------------------------------------------------------------------
--  top.vhd
--	ZedBoard simple VHDL example
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
--  Vivado 2013.2:
--    mkdir -p build.vivado
--    (cd build.vivado; vivado -mode tcl -source ../vivado.tcl)
--    (cd build.vivado; promgen -w -b -p bin -o cmv_io.bin -u 0 cmv_io.bit -data_width 32)
--
--  0xf8000900 rw	ps7::slcr::LVL_SHFTR_EN
--  devmem 0x600001FC 16 0x03AE ~ 42.0/43.0
--  devmem 0x600001FC 16 0x03AC ~ 41.0/42.5
--  devmem 0x600001FC 16 0x03A6 ~ 40.5/41.5
--  devmem 0x600001FC 16 0x0374 ~ 26.0/26.5
--  devmem 0x600001FC 16 0x0377 ~ 26.5/27.0
--			 0x0386 ~ 30.5/31.0
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

use work.axi3m_pkg.all;		-- AXI3 Master
use work.axi3ml_pkg.all;	-- AXI3 Lite Master

use work.reg_array_pkg.ALL;
use work.val_array_pkg.ALL;


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
	cmv_clk : out std_ulogic;
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
	pmod_jac : out std_logic_vector(3 downto 0);
	pmod_jad : out std_logic_vector(3 downto 0);
	--
	pmod_jcm : out std_logic_vector(3 downto 0);
	pmod_jca : out std_logic_vector(3 downto 0);
	--
	pmod_jdm : out std_logic_vector(3 downto 0);
	pmod_jda : out std_logic_vector(3 downto 0);
	--
	btn_l : in std_logic;	-- Button: '1' is pressed
	btn_c : in std_logic;	-- Button: '1' is pressed
	btn_r : in std_logic;	-- Button: '1' is pressed
	btn_u : in std_logic;	-- Button: '1' is pressed
	btn_d : in std_logic;	-- Button: '1' is pressed
	--
	swi : in std_logic_vector(7 downto 0);
	led : out std_logic_vector(7 downto 0)
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    attribute DONT_TOUCH : string;
    attribute MARK_DEBUG : string;

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

    signal m_axi00_state : std_logic_vector(3 downto 0);

    signal m_axi01_aclk : std_logic;
    signal m_axi01_areset_n : std_logic;

    signal m_axi01_ri : axi3ml_read_in_r;
    signal m_axi01_ro : axi3ml_read_out_r;
    signal m_axi01_wi : axi3ml_write_in_r;
    signal m_axi01_wo : axi3ml_write_out_r;

    signal m_axi010_aclk : std_logic;
    signal m_axi010_areset_n : std_logic;

    signal m_axi010_ri : axi3ml_read_in_r;
    signal m_axi010_ro : axi3ml_read_out_r;
    signal m_axi010_wi : axi3ml_write_in_r;
    signal m_axi010_wo : axi3ml_write_out_r;

    signal m_axi010_state : std_logic_vector(2 downto 0);

    signal m_axi011_aclk : std_logic;
    signal m_axi011_areset_n : std_logic;

    signal m_axi011_ri : axi3ml_read_in_r;
    signal m_axi011_ro : axi3ml_read_out_r;
    signal m_axi011_wi : axi3ml_write_in_r;
    signal m_axi011_wo : axi3ml_write_out_r;

    signal m_axi011_state : std_logic_vector(3 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI Slave Signals
    --------------------------------------------------------------------

    signal s_axi_aclk : std_ulogic;
    signal s_axi_areset_n : std_ulogic;

    signal s_axi_arid : std_logic_vector(5 downto 0);
    signal s_axi_araddr : std_logic_vector(31 downto 0);
    signal s_axi_arburst : std_logic_vector(1 downto 0);
    signal s_axi_arlen : std_logic_vector(3 downto 0);
    signal s_axi_arsize : std_logic_vector(1 downto 0);
    signal s_axi_arvalid : std_ulogic;
    signal s_axi_arready : std_ulogic;

    signal s_axi_rid : std_logic_vector(5 downto 0);
    signal s_axi_rdata : std_logic_vector(63 downto 0);
    signal s_axi_rlast : std_ulogic;
    signal s_axi_rresp : std_logic_vector(1 downto 0);
    signal s_axi_rvalid : std_ulogic;
    signal s_axi_rready : std_ulogic;

    signal s_axi_awid : std_logic_vector(5 downto 0);
    signal s_axi_awaddr : std_logic_vector(31 downto 0);
    signal s_axi_awburst : std_logic_vector(1 downto 0);
    signal s_axi_awlen : std_logic_vector(3 downto 0);
    signal s_axi_awsize : std_logic_vector(1 downto 0);
    signal s_axi_awvalid : std_ulogic;
    signal s_axi_awready : std_ulogic;

    signal s_axi_wid : std_logic_vector(5 downto 0);
    signal s_axi_wdata : std_logic_vector(63 downto 0);
    signal s_axi_wstrb : std_logic_vector(7 downto 0);
    signal s_axi_wlast : std_ulogic;
    signal s_axi_wvalid : std_ulogic;
    signal s_axi_wready : std_ulogic;

    signal s_axi_bid : std_logic_vector(5 downto 0);
    signal s_axi_bresp : std_logic_vector(1 downto 0);
    signal s_axi_bvalid : std_ulogic;
    signal s_axi_bready : std_ulogic;

    --------------------------------------------------------------------
    -- CMV SPI Signals
    --------------------------------------------------------------------

    signal cmv_spi_clk : std_ulogic;

    signal spi_en_d : std_ulogic;
    signal spi_clk_d : std_ulogic;
    signal spi_in_d : std_ulogic;
    signal spi_out_d : std_ulogic;

    signal spi_state : std_logic_vector(2 downto 0);

    --------------------------------------------------------------------
    -- Register File Signals
    --------------------------------------------------------------------

    signal reg_oreg : reg_array(0 to 3);
    signal reg_ireg : reg_array(0 to 3);

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

    signal cmv_pll : std_logic_vector(4 downto 0);
    signal cmv_pll_locked : std_ulogic;

    signal cmv_clk_300 : std_ulogic;
    signal cmv_clk_200 : std_ulogic;
    signal cmv_clk_150 : std_ulogic;
    signal cmv_clk_30 : std_ulogic;
    signal cmv_clk_10 : std_ulogic;

    signal cmv_outclk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS MMCM Signals
    --------------------------------------------------------------------

    signal lvds_clk : std_logic_vector(4 downto 0);
    signal lvds_clk_locked : std_ulogic;

    signal lvds_clk_150 : std_ulogic;
    signal lvds_clk_75 : std_ulogic;
    signal lvds_clk_50 : std_ulogic;
    signal lvds_clk_30 : std_ulogic;
    signal lvds_clk_10 : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS IDELAY Signals
    --------------------------------------------------------------------

    signal idelay_ce   : unsigned (32 downto 0) := (others => '0');
    signal idelay_inc  : unsigned (32 downto 0) := (others => '1');
    signal idelay_rst  : unsigned (32 downto 0) := (others => '0');

    signal idelay_val  : std_logic_vector(4 downto 0);
    signal idelay_oval : delay_val_array(32 downto 0);
    signal idelay_ld   : std_logic_vector(32 downto 0);

    signal idelay_valid : std_logic;
    signal idelay_clk  : std_logic;

    signal btn_feedback : std_logic;

    --------------------------------------------------------------------
    -- CMV Serdes Signals
    --------------------------------------------------------------------

    signal iserdes_clk : std_logic;
    signal iserdes_bitslip : std_logic_vector (32 downto 0);

    signal cmv_data_ser : unsigned (32 downto 0);

    type data_array is array (32 downto 0) of
	std_logic_vector (11 downto 0);

    signal cmv_data_par : data_array := (others => (others => '0'));

    signal cmv_rst_sys : std_logic;

    signal cmv_pattern : std_logic_vector (11 downto 0) := x"A0A";

    signal cmv_match : std_logic_vector (32 downto 0);

    signal cmv_fail : fail_cnt_array(32 downto 0);

    signal delay_state : std_logic_vector(1 downto 0);
    signal delay_index : std_logic_vector(5 downto 0);

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

    signal pmod_v2 : std_logic_vector(287 downto 0);

    attribute DONT_TOUCH of pmod_enc_ja_inst : label is "TRUE";
    attribute MARK_DEBUG of pmod_v2 : signal is "TRUE";

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
	    m_axi0_bready => m_axi0_wo.bready,
	    --
	    s_axi0_aclk => s_axi_aclk,
	    s_axi0_areset_n => s_axi_areset_n,
	    --
	    s_axi0_arid => s_axi_arid,
	    s_axi0_araddr => s_axi_araddr,
	    s_axi0_arburst => s_axi_arburst,
	    s_axi0_arlen => s_axi_arlen,
	    s_axi0_arsize => s_axi_arsize,
	    s_axi0_arvalid => s_axi_arvalid,
	    s_axi0_arready => s_axi_arready,
	    --
	    s_axi0_rid => s_axi_rid,
	    s_axi0_rdata => s_axi_rdata,
	    s_axi0_rlast => s_axi_rlast,
	    s_axi0_rresp => s_axi_rresp,
	    s_axi0_rvalid => s_axi_rvalid,
	    s_axi0_rready => s_axi_rready,
	    --
	    s_axi0_awid => s_axi_awid,
	    s_axi0_awaddr => s_axi_awaddr,
	    s_axi0_awburst => s_axi_awburst,
	    s_axi0_awlen => s_axi_awlen,
	    s_axi0_awsize => s_axi_awsize,
	    s_axi0_awvalid => s_axi_awvalid,
	    s_axi0_awready => s_axi_awready,
	    --
	    s_axi0_wid => s_axi_wid,
	    s_axi0_wdata => s_axi_wdata,
	    s_axi0_wstrb => s_axi_wstrb,
	    s_axi0_wlast => s_axi_wlast,
	    s_axi0_wvalid => s_axi_wvalid,
	    s_axi0_wready => s_axi_wready,
	    --
	    s_axi0_bid => s_axi_bid,
	    s_axi0_bresp => s_axi_bresp,
	    s_axi0_bvalid => s_axi_bvalid,
	    s_axi0_bready => s_axi_bready );

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

    lvds_pll_inst : entity work.lvds_pll
	port map (
	    ref_clk_in => clk_100,
	    --
	    pll_clk => cmv_pll,
	    pll_locked => cmv_pll_locked,
	    --
	    lvds_clk_in => cmv_outclk,
	    --
	    lvds_clk => lvds_clk,
	    lvds_locked => lvds_clk_locked );

    cmv_clk_300 <= cmv_pll(0);
    cmv_clk_200 <= cmv_pll(1);
    cmv_clk_150 <= cmv_pll(2);
    cmv_clk_30 <= cmv_pll(3);
    cmv_clk_10 <= cmv_pll(4);

    lvds_clk_150 <= lvds_clk(0);
    lvds_clk_75 <= lvds_clk(1);
    lvds_clk_50 <= lvds_clk(2);
    lvds_clk_30 <= lvds_clk(3);
    lvds_clk_10 <= lvds_clk(4);

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

    axi_split_inst0 : entity work.axi_split
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

    axi_split_inst1 : entity work.axi_split
	generic map (
	    SPLIT_BIT => 12 )
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,
	    --
	    s_axi_ro => m_axi01_ri,
	    s_axi_ri => m_axi01_ro,
	    s_axi_wo => m_axi01_wi,
	    s_axi_wi => m_axi01_wo,
	    --
	    m_axi0_aclk => m_axi010_aclk,
	    m_axi0_areset_n => m_axi010_areset_n,
	    --
	    m_axi0_ri => m_axi010_ri,
	    m_axi0_ro => m_axi010_ro,
	    m_axi0_wi => m_axi010_wi,
	    m_axi0_wo => m_axi010_wo,
	    --
	    m_axi1_aclk => m_axi011_aclk,
	    m_axi1_areset_n => m_axi011_areset_n,
	    --
	    m_axi1_ri => m_axi011_ri,
	    m_axi1_ro => m_axi011_ro,
	    m_axi1_wi => m_axi011_wi,
	    m_axi1_wo => m_axi011_wo );

    --------------------------------------------------------------------
    -- CMV SPI Interface
    --------------------------------------------------------------------

    reg_spi_inst : entity work.reg_spi
	port map (
	    s_axi_aclk => m_axi00_aclk,
	    s_axi_areset_n => m_axi00_areset_n,

	    s_axi_ro => m_axi00_ri,
	    s_axi_ri => m_axi00_ro,
	    s_axi_wo => m_axi00_wi,
	    s_axi_wi => m_axi00_wo,

	    s_state => m_axi00_state,
	    --
	    spi_bclk => cmv_spi_clk,
	    --
	    spi_clk => spi_clk_d,
	    spi_in => spi_in_d,
	    spi_out => spi_out_d,
	    spi_en => spi_en_d,

	    spi_state => spi_state );

    spi_clk <= spi_clk_d;
    spi_in <= spi_in_d;
    spi_out_d <= spi_out;
    spi_en <= spi_en_d;

    -- m_axi0_aclk <= clk_100;
    -- m_axi0_aclk <= cmv_clk_30;

    async_div_inst0 : entity work.async_div
	generic map (STAGES => 18)
	port map (clk_in => cmv_clk_30, clk_out => m_axi0_aclk);

    s_axi_aclk <= cmv_clk_200;

    -- cmv_spi_clk <= cmv_clk_10;

    async_div_inst1 : entity work.async_div
	generic map (STAGES => 18)
	port map (clk_in => cmv_clk_10, clk_out => cmv_spi_clk);

    --------------------------------------------------------------------
    -- Deser Register File
    --------------------------------------------------------------------

    reg_file_inst : entity work.reg_file
	generic map (
	    REG_BASE => 16#60000000#,
	    OREG_SIZE => 4,
	    IREG_SIZE => 4 )
	port map (
	    s_axi_aclk => m_axi010_aclk,
	    s_axi_areset_n => m_axi010_areset_n,

	    s_axi_ro => m_axi010_ri,
	    s_axi_ri => m_axi010_ro,
	    s_axi_wo => m_axi010_wi,
	    s_axi_wi => m_axi010_wo,

	    s_state => m_axi010_state,

	    oreg => reg_oreg,
	    ireg => reg_ireg );

    --------------------------------------------------------------------
    -- Delay Register File
    --------------------------------------------------------------------

    reg_delay_inst : entity work.reg_delay
	generic map (
	    REG_BASE => 16#60000000#,
	    CHANNELS => 33 )
	port map (
	    s_axi_aclk => m_axi011_aclk,
	    s_axi_areset_n => m_axi011_areset_n,

	    s_axi_ro => m_axi011_ri,
	    s_axi_ri => m_axi011_ro,
	    s_axi_wo => m_axi011_wi,
	    s_axi_wi => m_axi011_wo,

	    s_state => m_axi011_state,

	    delay_clk => idelay_clk,
	    delay_val => idelay_val,
	    delay_oval => idelay_oval,
	    delay_ld => idelay_ld,
	    --
	    match => cmv_match,
	    fail_cnt => cmv_fail,
	    bitslip => iserdes_bitslip,
	    
	    d_index => delay_index,
	    d_state => delay_state );

    --------------------------------------------------------------------
    -- CMV12K Related
    --------------------------------------------------------------------

    cmv_clk <= cmv_clk_30;

    cmv_frame_req <= '0';
    cmv_t_exp1 <= '0';
    cmv_t_exp2 <= '0';

    OBUFDS_inst : OBUFDS
	generic map (
	    IOSTANDARD => "LVDS_25",
	    SLEW => "SLOW" )
	port map (
	    O => cmv_lvds_clk_p,
	    OB => cmv_lvds_clk_n,
	    I => cmv_clk_300 );

    IBUFDS_inst : IBUFDS
	generic map (
	    DIFF_TERM => TRUE,
	    IBUF_LOW_PWR => TRUE,
	    IOSTANDARD => "LVDS_25" )
	port map (
	    O => cmv_outclk,
	    I => cmv_lvds_outclk_p,
	    IB => cmv_lvds_outclk_n );

    GEN_LVDS: for I in 32 downto 0 generate
    begin
	CTRL : if I = 32 generate
	    IBUFDS_i : IBUFDS
		generic map (
		    DIFF_TERM => TRUE,
		    IBUF_LOW_PWR => TRUE,
		    IOSTANDARD => "LVDS_25" )
		port map (
		    O => cmv_data_ser(I),
		    I => cmv_lvds_ctrl_p,
		    IB => cmv_lvds_ctrl_n );
	end generate;

	DATA : if I < 32 generate
	    IBUFDS_i : IBUFDS
		generic map (
		    DIFF_TERM => TRUE,
		    IBUF_LOW_PWR => TRUE,
		    IOSTANDARD => "LVDS_25" )
		port map (
		    O => cmv_data_ser(I),
		    I => cmv_lvds_data_p(I),
		    IB => cmv_lvds_data_n(I) );
	end generate;

	cmv_deser_inst : entity work.cmv_deser
	    port map (
		serdes_clk	=> iserdes_clk,
		rst		=> cmv_rst_sys,
		
		width		=> "00",
		
		data_ser	=> cmv_data_ser(I),
		data_par	=> cmv_data_par(I),
		
		pattern		=> cmv_pattern,
		match		=> cmv_match(I),
		fail_cnt	=> cmv_fail(I),
		
		delay_clk	=> idelay_clk,
		delay_ce	=> idelay_ce(I),
		delay_inc	=> idelay_inc(I),
		delay_rst	=> idelay_rst(I),
		delay_ld	=> idelay_ld(I),
		delay_val	=> idelay_val,
		delay_oval	=> idelay_oval(I),

		bitslip		=> iserdes_bitslip(I) );

    end generate;

    iserdes_clk <= lvds_clk_150;
    idelay_clk <= lvds_clk_30;


    --------------------------------------------------------------------
    -- Delay Control
    --------------------------------------------------------------------

    IDELAYCTRL_inst : IDELAYCTRL
	port map (
	    RDY => idelay_valid,	-- 1-bit output indicates validity of the REFCLK
	    REFCLK => cmv_clk_200,	-- 1-bit reference clock input
	    RST => cmv_rst_sys );	-- 1-bit reset input


    --------------------------------------------------------------------
    -- Button Input
    --------------------------------------------------------------------

    adj_proc : process(idelay_clk)

	variable index_v : natural range 0 to 63;
	variable count_v : natural;

	type adj_state is (
	    idle_s, wait_s,
	    btnu_s, btnd_s, btnl_s, btnr_s, btnc_s );

	variable state : adj_state := idle_s;

	variable idelay_ce_v : std_logic := '0';
	variable idelay_inc_v : std_logic := '0';
	variable idelay_rst_v : std_logic := '0';

	variable bitslip_v : std_logic := '0';

    begin

	btn_feedback <= '0';
	index_v := to_integer(unsigned(swi(5 downto 0)));


	if rising_edge(idelay_clk) then
	    case state is
		when idle_s =>
		    if btn_c = '1' then
			state := btnc_s;
		    elsif btn_u = '1' then
			state := btnu_s;
		    elsif btn_d = '1' then
			state := btnd_s;
		    elsif btn_l = '1' then
			state := btnl_s;
		    elsif btn_r = '1' then
			state := btnr_s;
		    end if;

		when wait_s =>
		    btn_feedback <= '1';
		    if count_v = 0 then
			if  btn_c = '0' and
			    btn_u = '0' and
			    btn_d = '0' and
			    btn_l = '0' and
			    btn_r = '0' then
			    state := idle_s;
			else
			    count_v := 2 ** 20;
			end if;
		    else
			count_v := count_v - 1;
		    end if;

		when others =>
		    count_v := 2 ** 20;
		    state := wait_s;

	    end case;
	end if;

	if falling_edge(idelay_clk) then
	    case state is
		when btnc_s =>
		    idelay_rst_v := '1';

		when btnu_s =>
		    null;

		when btnd_s =>
		    null;

		when btnl_s =>
		    idelay_inc_v := '0';
		    idelay_ce_v := '1';

		when btnr_s =>
		    idelay_inc_v := '1';
		    idelay_ce_v := '1';

		when others =>
		    idelay_ce_v := '0';
		    idelay_rst_v := '0';

	    end case;
	end if;

	idelay_ce(index_v) <= idelay_ce_v;
	idelay_inc(index_v) <= idelay_inc_v;
	idelay_rst(index_v) <= idelay_rst_v;

    end process;


    --------------------------------------------------------------------
    -- LED Status output
    --------------------------------------------------------------------

    led(0) <= cmv_pll_locked;
    led(1) <= lvds_clk_locked;
    led(2) <= idelay_valid;

    div_lvds_inst0 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => cmv_clk_300,
	    clk_out => led(4) );

    div_lvds_inst1 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => lvds_clk_150,
	    clk_out => led(5) );

    led(3) <= '0';
    led(6) <= '0';
    led(7) <= btn_feedback;

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
	cmv_match, cmv_fail, cmv_data_par,
	m_axi0_wo, m_axi0_wi, m_axi0_ro, m_axi0_ri )
    begin
	case swi(5 downto 3) is
	    when "000" =>
		pmod_v0 <= cmv_match(0)	 & cmv_fail(0)(7 downto 5)  & cmv_data_par(0) &
			   cmv_match(1)	 & cmv_fail(1)(7 downto 5)  & cmv_data_par(1) &
			   cmv_match(2)	 & cmv_fail(2)(7 downto 5)  & cmv_data_par(2) &
			   cmv_match(3)	 & cmv_fail(3)(7 downto 5)  & cmv_data_par(3);

		pmod_v1 <= cmv_match(4)	 & cmv_fail(4)(7 downto 5)  & cmv_data_par(4) &
			   cmv_match(5)	 & cmv_fail(5)(7 downto 5)  & cmv_data_par(5) &
			   cmv_match(6)	 & cmv_fail(6)(7 downto 5)  & cmv_data_par(6) &
			   cmv_match(7)	 & cmv_fail(7)(7 downto 5)  & cmv_data_par(7);

	    when "001" =>
		pmod_v0 <= cmv_match(8)	 & cmv_fail(8)(7 downto 5)  & cmv_data_par(8) &
			   cmv_match(9)	 & cmv_fail(9)(7 downto 5)  & cmv_data_par(9) &
			   cmv_match(10) & cmv_fail(10)(7 downto 5) & cmv_data_par(10) &
			   cmv_match(11) & cmv_fail(11)(7 downto 5) & cmv_data_par(11);

		pmod_v1 <= cmv_match(12) & cmv_fail(12)(7 downto 5) & cmv_data_par(12) &
			   cmv_match(13) & cmv_fail(13)(7 downto 5) & cmv_data_par(13) &
			   cmv_match(14) & cmv_fail(14)(7 downto 5) & cmv_data_par(14) &
			   cmv_match(15) & cmv_fail(15)(7 downto 5) & cmv_data_par(15);

	    when "010" =>
		pmod_v0 <= cmv_match(16) & cmv_fail(16)(7 downto 5) & cmv_data_par(16) &
			   cmv_match(17) & cmv_fail(17)(7 downto 5) & cmv_data_par(17) &
			   cmv_match(18) & cmv_fail(18)(7 downto 5) & cmv_data_par(18) &
			   cmv_match(19) & cmv_fail(19)(7 downto 5) & cmv_data_par(19);

		pmod_v1 <= cmv_match(20) & cmv_fail(20)(7 downto 5) & cmv_data_par(20) &
			   cmv_match(21) & cmv_fail(21)(7 downto 5) & cmv_data_par(21) &
			   cmv_match(22) & cmv_fail(22)(7 downto 5) & cmv_data_par(22) &
			   cmv_match(23) & cmv_fail(23)(7 downto 5) & cmv_data_par(23);

	    when "011" =>
		pmod_v0 <= cmv_match(24) & cmv_fail(24)(7 downto 5) & cmv_data_par(24) &
			   cmv_match(25) & cmv_fail(25)(7 downto 5) & cmv_data_par(25) &
			   cmv_match(26) & cmv_fail(26)(7 downto 5) & cmv_data_par(26) &
			   cmv_match(27) & cmv_fail(27)(7 downto 5) & cmv_data_par(27);

		pmod_v1 <= cmv_match(28) & cmv_fail(28)(7 downto 5) & cmv_data_par(28) &
			   cmv_match(29) & cmv_fail(29)(7 downto 5) & cmv_data_par(29) &
			   cmv_match(30) & cmv_fail(30)(7 downto 5) & cmv_data_par(30) &
			   cmv_match(31) & cmv_fail(31)(7 downto 5) & cmv_data_par(31);

	    when "100" =>
		pmod_v0 <= x"000000000000" &
			   cmv_match(32) & cmv_fail(32)(7 downto 5) & cmv_data_par(32);

		pmod_v1 <= (others => '0');

	    when "111" =>
		pmod_v0(63 downto 48) <= m_axi0_wo.awaddr(15 downto 0);
		pmod_v0(47 downto 32) <= m_axi0_wo.awvalid & m_axi0_wi.awready &
		    m_axi0_wo.wvalid & m_axi0_wi.wready & m_axi0_wo.awid;
		pmod_v0(31 downto 16) <= m_axi0_wo.wdata(15 downto 0);
		pmod_v0(15 downto 0) <= m_axi0_wi.bvalid & m_axi0_wo.bready &
		    m_axi0_wi.bresp & m_axi0_wi.bid;

		pmod_v1(63 downto 48) <= m_axi0_ro.araddr(15 downto 0);
		pmod_v1(47 downto 32) <= m_axi0_ro.arvalid & m_axi0_ri.arready &
		    "00" & m_axi0_ro.arid;
		pmod_v1(31 downto 16) <= m_axi0_ri.rdata(15 downto 0);
		pmod_v1(15 downto 0) <= m_axi0_ri.rvalid & m_axi0_ro.rready &
		    m_axi0_ri.rresp & m_axi0_ri.rid;

	    when others =>
		pmod_v0 <= (others => '0');

		pmod_v1 <= (others => '0');
	end case;
    end process;


    pmod_enc_ja_inst : entity work.pmod_encode
	generic map (
	    PRESCALE => 5,
	    DATA_WIDTH => 288 )
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v2,
	    --
	    jxc => pmod_jac,
	    jxd => pmod_jad );

    pmod_v2(0)	<= m_axi0_ri.arready;
    pmod_v2(1)	<= m_axi0_ri.rlast;
    pmod_v2(2)	<= m_axi0_ri.rvalid;

    pmod_v2(3)	<= m_axi0_ro.arvalid;
    pmod_v2(4)	<= m_axi0_ro.rready;

    pmod_v2(5)	<= m_axi0_wi.awready;
    pmod_v2(6)	<= m_axi0_wi.wready;
    pmod_v2(7)	<= m_axi0_wi.bvalid;

    pmod_v2(8)	<= m_axi0_wo.awvalid;
    pmod_v2(9)	<= m_axi0_wo.wlast;
    pmod_v2(10) <= m_axi0_wo.wvalid;
    pmod_v2(11) <= m_axi0_wo.bready;

    pmod_v2(23 downto 12) <= m_axi0_ri.rid;
    pmod_v2(55 downto 24) <= m_axi0_ri.rdata;
    pmod_v2(57 downto 56) <= m_axi0_ri.rresp;

    pmod_v2(69 downto 58) <= m_axi0_ro.arid;
    pmod_v2(101 downto 70) <= m_axi0_ro.araddr;
    pmod_v2(103 downto 102) <= m_axi0_ro.arburst;
    pmod_v2(107 downto 104) <= m_axi0_ro.arlen;
    pmod_v2(109 downto 108) <= m_axi0_ro.arsize;
    -- pmod_v2(111 downto 110) <= m_axi0_ro.arlock;
    pmod_v2(114 downto 112) <= m_axi0_ro.arprot;
    -- pmod_v2(118 downto 115) <= m_axi0_ro.arcache;
    -- pmod_v2(122 downto 119) <= m_axi0_ro.arqos;

    pmod_v2(134 downto 123) <= m_axi0_wi.bid;
    pmod_v2(136 downto 135) <= m_axi0_wi.bresp;

    pmod_v2(148 downto 137) <= m_axi0_wo.awid;
    pmod_v2(180 downto 149) <= m_axi0_wo.awaddr;
    pmod_v2(182 downto 181) <= m_axi0_wo.awburst;
    pmod_v2(186 downto 183) <= m_axi0_wo.awlen;
    pmod_v2(188 downto 187) <= m_axi0_wo.awsize;
    -- pmod_v2(190 downto 189) <= m_axi0_wo.awlock;
    pmod_v2(193 downto 191) <= m_axi0_wo.awprot;
    -- pmod_v2(197 downto 194) <= m_axi0_wo.awcache;
    -- pmod_v2(201 downto 198) <= m_axi0_wo.awqos;
    pmod_v2(213 downto 202) <= m_axi0_wo.wid;
    pmod_v2(245 downto 214) <= m_axi0_wo.wdata;
    pmod_v2(249 downto 246) <= m_axi0_wo.wstrb;

    pmod_v2(253 downto 250) <= m_axi00_state;
    pmod_v2(256 downto 254) <= m_axi010_state;
    pmod_v2(260 downto 257) <= m_axi011_state;

    pmod_v2(263 downto 261) <= spi_state;

    pmod_v2(264) <= spi_clk_d;
    pmod_v2(265) <= spi_en_d;
    pmod_v2(266) <= spi_in_d;
    pmod_v2(267) <= spi_out_d;
    pmod_v2(268) <= m_axi0_aclk;
    

end RTL;
