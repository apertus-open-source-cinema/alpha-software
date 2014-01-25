----------------------------------------------------------------------------
--  top.vhd (for cmv_io2)
--	ZedBoard simple VHDL example
--	Version 1.2
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
--    (cd build.vivado && promgen -w -b -p bin -u 0 cmv_io2.bit -data_width 32)
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.axi3m_pkg.ALL;		-- AXI3 Master
use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.axi3s_pkg.ALL;		-- AXI3 Slave

use work.reduce_pkg.ALL;	-- Logic Reduction
use work.vivado_pkg.ALL;	-- Vivado Attributes

use work.fifo_pkg.ALL;		-- FIFO Functions
use work.lut5_pkg.ALL;		-- LUT5 Record/Array
use work.reg_array_pkg.ALL;	-- Register Arrays
use work.par_array_pkg.ALL;	-- Parallel Data



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
	pmod_jcm : out std_logic_vector (3 downto 0);
	pmod_jca : out std_logic_vector (3 downto 0);
	--
	pmod_jdm : out std_logic_vector (3 downto 0);
	pmod_jda : out std_logic_vector (3 downto 0);
	--
	btn : in std_logic_vector (4 downto 0);
	swi : in std_logic_vector (7 downto 0);
	led : out std_logic_vector (7 downto 0)
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    --------------------------------------------------------------------
    -- PS7 Signals
    --------------------------------------------------------------------

    signal ps_fclk : std_logic_vector (3 downto 0);
    signal ps_reset_n : std_logic_vector (3 downto 0);

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

    signal m_axi0a_aclk : std_logic_vector (3 downto 0);
    signal m_axi0a_areset_n : std_logic_vector (3 downto 0);

    signal m_axi0a_ri : axi3ml_read_in_a(3 downto 0);
    signal m_axi0a_ro : axi3ml_read_out_a(3 downto 0);
    signal m_axi0a_wi : axi3ml_write_in_a(3 downto 0);
    signal m_axi0a_wo : axi3ml_write_out_a(3 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI Slave Signals
    --------------------------------------------------------------------

    signal s_axi_aclk : std_logic_vector (3 downto 0);
    signal s_axi_areset_n : std_logic_vector (3 downto 0);

    signal s_axi_ri : axi3s_read_in_a(3 downto 0);
    signal s_axi_ro : axi3s_read_out_a(3 downto 0);
    signal s_axi_wi : axi3s_write_in_a(3 downto 0);
    signal s_axi_wo : axi3s_write_out_a(3 downto 0);

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
    signal cmv_axi_clk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS MMCM Signals
    --------------------------------------------------------------------

    signal lvds_pll_locked : std_ulogic;

    signal hdmi_clk : std_ulogic;
    signal lvds_clk : std_ulogic;
    signal word_clk : std_ulogic;

    signal cmv_outclk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS IDELAY Signals
    --------------------------------------------------------------------

    constant CHANNELS : natural := 32;

    signal idelay_valid : std_logic;

    signal idelay_in : std_logic_vector (CHANNELS + 1 downto 0);
    signal idelay_out : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- CMV Serdes Signals
    --------------------------------------------------------------------

    alias serdes_clk : std_logic is lvds_clk;
    alias serdes_clkdiv : std_logic is word_clk;

    signal serdes_phase : std_logic;

    signal serdes_bitslip : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- CMV Parallel Data Signals
    --------------------------------------------------------------------

    signal par_data : par12_a (CHANNELS downto 0);

    alias par_ctrl : std_logic_vector (11 downto 0)
	is par_data(CHANNELS);

    signal par_valid : std_logic;
    signal par_enable : std_logic;

    signal par_pattern : par12_a (CHANNELS downto 0);
    signal par_match : std_logic_vector (CHANNELS + 1 downto 0);
    signal par_mismatch : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- Remapper Signals
    --------------------------------------------------------------------

    signal remap_ctrl : std_logic_vector (11 downto 0);
    signal remap_data : par12_a (CHANNELS-1 downto 0);

    --------------------------------------------------------------------
    -- Register File Signals
    --------------------------------------------------------------------

    constant OREG_SIZE : natural := 6;

    signal reg_oreg : reg32_a(0 to OREG_SIZE - 1);

    alias reg_pattern : std_logic_vector (11 downto 0)
	is reg_oreg(0)(11 downto 0);

    alias reg_mval : std_logic_vector (2 downto 0)
	is reg_oreg(0)(16 + 2 downto 16);

    alias reg_mask : std_logic_vector (2 downto 0)
	is reg_oreg(0)(24 + 2 downto 24);

    alias waddr_inc : std_logic_vector (31 downto 0)
	is reg_oreg(1)(31 downto 0);

    alias waddr_max : std_logic_vector (31 downto 0)
	is reg_oreg(2)(31 downto 0);

    alias led_val : std_logic_vector (7 downto 0)
	is reg_oreg(3)(7 downto 0);

    alias led_mask : std_logic_vector (7 downto 0)
	is reg_oreg(3)(23 downto 16);

    alias led_done : std_logic is reg_oreg(3)(8);

    alias swi_val : std_logic_vector (7 downto 0)
	is reg_oreg(4)(7 downto 0);

    alias swi_mask : std_logic_vector (7 downto 0)
	is reg_oreg(4)(23 downto 16);

    alias btn_val : std_logic_vector (4 downto 0)
	is reg_oreg(4)(8 + 4 downto 8);

    alias btn_mask : std_logic_vector (4 downto 0)
	is reg_oreg(4)(24 + 4 downto 24);

    alias waddr_reset : std_logic is reg_oreg(5)(0);
    alias fifo_data_reset : std_logic is reg_oreg(5)(1);

    alias waddr_block : std_logic is reg_oreg(5)(4);

    alias serdes_reset : std_logic is reg_oreg(5)(8);

    alias writer_enable : std_logic_vector (3 downto 0)
	is reg_oreg(5)(19 downto 16);


    constant IREG_SIZE : natural := 4;

    signal reg_ireg : reg32_a(0 to IREG_SIZE - 1);

    --------------------------------------------------------------------
    -- CFGLUT5 Signals
    --------------------------------------------------------------------

    alias lut_clk : std_logic is clk_100;

    signal lut_in : lut5_in_a (1 downto 0);
    signal lut_out : lut5_out_a (1 downto 0);

    alias lut_dval_in : std_logic is lut_in(0).I0;
    alias lut_lval_in : std_logic is lut_in(0).I1;
    alias lut_fval_in : std_logic is lut_in(0).I2;

    alias lut_fot_in : std_logic is lut_in(0).I3;

    alias lut_en_out : std_logic is lut_out(0).O5;

    --------------------------------------------------------------------
    -- Override Signals
    --------------------------------------------------------------------

    signal led_out : std_logic_vector (7 downto 0);
    signal swi_ovr : std_logic_vector (7 downto 0);
    signal btn_ovr : std_logic_vector (4 downto 0);

    --------------------------------------------------------------------
    -- Writer Constants and Signals
    --------------------------------------------------------------------

    type waddr_a is array (natural range <>) of
	std_logic_vector (31 downto 0);

    constant WADDR_MASK : waddr_a(0 to 3) := 
	( x"07FFFFFF", x"03FFFFFF", x"000FFFFF", x"000FFFFF" );
    constant WADDR_BASE : waddr_a(0 to 3) := 
	( x"18000000", x"1C000000", x"1D000000", x"1E000000" );

    constant DATA_WIDTH : natural := 64;

    signal wdata_clk : std_logic;
    signal wdata_enable : std_logic;
    signal wdata_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal wdata_empty : std_logic;

    signal wdata_full : std_logic;

    constant ADDR_WIDTH : natural := 32;

    signal waddr_clk : std_logic;
    signal waddr_enable : std_logic;
    signal waddr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal waddr_empty : std_logic;

    signal waddr_match : std_logic;

    alias writer_clk : std_logic is cmv_axi_clk;

    signal writer_inactive : std_logic_vector (3 downto 0);
    signal writer_error : std_logic_vector (3 downto 0);

    signal writer_active : std_logic_vector (3 downto 0);
    signal writer_unconf : std_logic_vector (3 downto 0);

    --------------------------------------------------------------------
    -- Data FIFO Signals
    --------------------------------------------------------------------

    signal fifo_data_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal fifo_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);

    constant DATA_CWIDTH : natural := cwidth_f(DATA_WIDTH, "36Kb");

    signal fifo_data_rdcount : std_logic_vector (DATA_CWIDTH - 1 downto 0);
    signal fifo_data_wrcount : std_logic_vector (DATA_CWIDTH - 1 downto 0);

    signal fifo_data_wclk : std_logic;
    signal fifo_data_wen : std_logic;
    signal fifo_data_high : std_logic;
    signal fifo_data_full : std_logic;
    signal fifo_data_wrerr : std_logic;

    signal fifo_data_rclk : std_logic;
    signal fifo_data_ren : std_logic;
    signal fifo_data_low : std_logic;
    signal fifo_data_empty : std_logic;
    signal fifo_data_rderr : std_logic;

    signal fifo_data_rst : std_logic;
    signal fifo_data_rrdy : std_logic;
    signal fifo_data_wrdy : std_logic;

    signal fifo_ctrl : std_logic_vector (11 downto 0);

    signal match_en : std_logic;

    signal data_wen : std_logic;
    signal data_wen_d : std_logic;
    signal data_wen_dd : std_logic;

    signal data_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal data_in_d : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal data_in_dd : std_logic_vector (DATA_WIDTH - 1 downto 0);

    --------------------------------------------------------------------
    -- PMOD Debug Signals
    --------------------------------------------------------------------

    signal pmod_clk : std_ulogic;

    attribute DONT_TOUCH of pmod_clk : signal is "TRUE";

    signal pmod_v0 : std_logic_vector (63 downto 0);

    attribute DONT_TOUCH of pmod_dbg_jc_inst : label is "TRUE";
    attribute MARK_DEBUG of pmod_v0 : signal is "TRUE";

    signal pmod_v1 : std_logic_vector (63 downto 0);

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
	    ps_fclk => ps_fclk,
	    ps_reset_n => ps_reset_n,
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
	    s_axi0_aclk => s_axi_aclk(0),
	    s_axi0_areset_n => s_axi_areset_n(0),
	    --
	    s_axi0_arid => s_axi_ri(0).arid,
	    s_axi0_araddr => s_axi_ri(0).araddr,
	    s_axi0_arburst => s_axi_ri(0).arburst,
	    s_axi0_arlen => s_axi_ri(0).arlen,
	    s_axi0_arsize => s_axi_ri(0).arsize,
	    s_axi0_arprot => s_axi_ri(0).arprot,
	    s_axi0_arvalid => s_axi_ri(0).arvalid,
	    s_axi0_arready => s_axi_ro(0).arready,
	    s_axi0_racount => s_axi_ro(0).racount,
	    --
	    s_axi0_rid => s_axi_ro(0).rid,
	    s_axi0_rdata => s_axi_ro(0).rdata,
	    s_axi0_rlast => s_axi_ro(0).rlast,
	    s_axi0_rvalid => s_axi_ro(0).rvalid,
	    s_axi0_rready => s_axi_ri(0).rready,
	    s_axi0_rcount => s_axi_ro(0).rcount,
	    --
	    s_axi0_awid => s_axi_wi(0).awid,
	    s_axi0_awaddr => s_axi_wi(0).awaddr,
	    s_axi0_awburst => s_axi_wi(0).awburst,
	    s_axi0_awlen => s_axi_wi(0).awlen,
	    s_axi0_awsize => s_axi_wi(0).awsize,
	    s_axi0_awprot => s_axi_wi(0).awprot,
	    s_axi0_awvalid => s_axi_wi(0).awvalid,
	    s_axi0_awready => s_axi_wo(0).awready,
	    s_axi0_wacount => s_axi_wo(0).wacount,
	    --
	    s_axi0_wid => s_axi_wi(0).wid,
	    s_axi0_wdata => s_axi_wi(0).wdata,
	    s_axi0_wstrb => s_axi_wi(0).wstrb,
	    s_axi0_wlast => s_axi_wi(0).wlast,
	    s_axi0_wvalid => s_axi_wi(0).wvalid,
	    s_axi0_wready => s_axi_wo(0).wready,
	    s_axi0_wcount => s_axi_wo(0).wcount,
	    --
	    s_axi0_bid => s_axi_wo(0).bid,
	    s_axi0_bresp => s_axi_wo(0).bresp,
	    s_axi0_bvalid => s_axi_wo(0).bvalid,
	    s_axi0_bready => s_axi_wi(0).bready,
	    --
	    s_axi1_aclk => s_axi_aclk(1),
	    s_axi1_areset_n => s_axi_areset_n(1),
	    --
	    s_axi1_arid => s_axi_ri(1).arid,
	    s_axi1_araddr => s_axi_ri(1).araddr,
	    s_axi1_arburst => s_axi_ri(1).arburst,
	    s_axi1_arlen => s_axi_ri(1).arlen,
	    s_axi1_arsize => s_axi_ri(1).arsize,
	    s_axi1_arprot => s_axi_ri(1).arprot,
	    s_axi1_arvalid => s_axi_ri(1).arvalid,
	    s_axi1_arready => s_axi_ro(1).arready,
	    s_axi1_racount => s_axi_ro(1).racount,
	    --
	    s_axi1_rid => s_axi_ro(1).rid,
	    s_axi1_rdata => s_axi_ro(1).rdata,
	    s_axi1_rlast => s_axi_ro(1).rlast,
	    s_axi1_rvalid => s_axi_ro(1).rvalid,
	    s_axi1_rready => s_axi_ri(1).rready,
	    s_axi1_rcount => s_axi_ro(1).rcount,
	    --
	    s_axi1_awid => s_axi_wi(1).awid,
	    s_axi1_awaddr => s_axi_wi(1).awaddr,
	    s_axi1_awburst => s_axi_wi(1).awburst,
	    s_axi1_awlen => s_axi_wi(1).awlen,
	    s_axi1_awsize => s_axi_wi(1).awsize,
	    s_axi1_awprot => s_axi_wi(1).awprot,
	    s_axi1_awvalid => s_axi_wi(1).awvalid,
	    s_axi1_awready => s_axi_wo(1).awready,
	    s_axi1_wacount => s_axi_wo(1).wacount,
	    --
	    s_axi1_wid => s_axi_wi(1).wid,
	    s_axi1_wdata => s_axi_wi(1).wdata,
	    s_axi1_wstrb => s_axi_wi(1).wstrb,
	    s_axi1_wlast => s_axi_wi(1).wlast,
	    s_axi1_wvalid => s_axi_wi(1).wvalid,
	    s_axi1_wready => s_axi_wo(1).wready,
	    s_axi1_wcount => s_axi_wo(1).wcount,
	    --
	    s_axi1_bid => s_axi_wo(1).bid,
	    s_axi1_bresp => s_axi_wo(1).bresp,
	    s_axi1_bvalid => s_axi_wo(1).bvalid,
	    s_axi1_bready => s_axi_wi(1).bready,
	    --
	    s_axi2_aclk => s_axi_aclk(2),
	    s_axi2_areset_n => s_axi_areset_n(2),
	    --
	    s_axi2_arid => s_axi_ri(2).arid,
	    s_axi2_araddr => s_axi_ri(2).araddr,
	    s_axi2_arburst => s_axi_ri(2).arburst,
	    s_axi2_arlen => s_axi_ri(2).arlen,
	    s_axi2_arsize => s_axi_ri(2).arsize,
	    s_axi2_arprot => s_axi_ri(2).arprot,
	    s_axi2_arvalid => s_axi_ri(2).arvalid,
	    s_axi2_arready => s_axi_ro(2).arready,
	    s_axi2_racount => s_axi_ro(2).racount,
	    --
	    s_axi2_rid => s_axi_ro(2).rid,
	    s_axi2_rdata => s_axi_ro(2).rdata,
	    s_axi2_rlast => s_axi_ro(2).rlast,
	    s_axi2_rvalid => s_axi_ro(2).rvalid,
	    s_axi2_rready => s_axi_ri(2).rready,
	    s_axi2_rcount => s_axi_ro(2).rcount,
	    --
	    s_axi2_awid => s_axi_wi(2).awid,
	    s_axi2_awaddr => s_axi_wi(2).awaddr,
	    s_axi2_awburst => s_axi_wi(2).awburst,
	    s_axi2_awlen => s_axi_wi(2).awlen,
	    s_axi2_awsize => s_axi_wi(2).awsize,
	    s_axi2_awprot => s_axi_wi(2).awprot,
	    s_axi2_awvalid => s_axi_wi(2).awvalid,
	    s_axi2_awready => s_axi_wo(2).awready,
	    s_axi2_wacount => s_axi_wo(2).wacount,
	    --
	    s_axi2_wid => s_axi_wi(2).wid,
	    s_axi2_wdata => s_axi_wi(2).wdata,
	    s_axi2_wstrb => s_axi_wi(2).wstrb,
	    s_axi2_wlast => s_axi_wi(2).wlast,
	    s_axi2_wvalid => s_axi_wi(2).wvalid,
	    s_axi2_wready => s_axi_wo(2).wready,
	    s_axi2_wcount => s_axi_wo(2).wcount,
	    --
	    s_axi2_bid => s_axi_wo(2).bid,
	    s_axi2_bresp => s_axi_wo(2).bresp,
	    s_axi2_bvalid => s_axi_wo(2).bvalid,
	    s_axi2_bready => s_axi_wi(2).bready,
	    --
	    s_axi3_aclk => s_axi_aclk(3),
	    s_axi3_areset_n => s_axi_areset_n(3),
	    --
	    s_axi3_arid => s_axi_ri(3).arid,
	    s_axi3_araddr => s_axi_ri(3).araddr,
	    s_axi3_arburst => s_axi_ri(3).arburst,
	    s_axi3_arlen => s_axi_ri(3).arlen,
	    s_axi3_arsize => s_axi_ri(3).arsize,
	    s_axi3_arprot => s_axi_ri(3).arprot,
	    s_axi3_arvalid => s_axi_ri(3).arvalid,
	    s_axi3_arready => s_axi_ro(3).arready,
	    s_axi3_racount => s_axi_ro(3).racount,
	    --
	    s_axi3_rid => s_axi_ro(3).rid,
	    s_axi3_rdata => s_axi_ro(3).rdata,
	    s_axi3_rlast => s_axi_ro(3).rlast,
	    s_axi3_rvalid => s_axi_ro(3).rvalid,
	    s_axi3_rready => s_axi_ri(3).rready,
	    s_axi3_rcount => s_axi_ro(3).rcount,
	    --
	    s_axi3_awid => s_axi_wi(3).awid,
	    s_axi3_awaddr => s_axi_wi(3).awaddr,
	    s_axi3_awburst => s_axi_wi(3).awburst,
	    s_axi3_awlen => s_axi_wi(3).awlen,
	    s_axi3_awsize => s_axi_wi(3).awsize,
	    s_axi3_awprot => s_axi_wi(3).awprot,
	    s_axi3_awvalid => s_axi_wi(3).awvalid,
	    s_axi3_awready => s_axi_wo(3).awready,
	    s_axi3_wacount => s_axi_wo(3).wacount,
	    --
	    s_axi3_wid => s_axi_wi(3).wid,
	    s_axi3_wdata => s_axi_wi(3).wdata,
	    s_axi3_wstrb => s_axi_wi(3).wstrb,
	    s_axi3_wlast => s_axi_wi(3).wlast,
	    s_axi3_wvalid => s_axi_wi(3).wvalid,
	    s_axi3_wready => s_axi_wo(3).wready,
	    s_axi3_wcount => s_axi_wo(3).wcount,
	    --
	    s_axi3_bid => s_axi_wo(3).bid,
	    s_axi3_bresp => s_axi_wo(3).bresp,
	    s_axi3_bvalid => s_axi_wo(3).bvalid,
	    s_axi3_bready => s_axi_wi(3).bready );

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
	    spi_clk => cmv_spi_clk,
	    axi_clk => cmv_axi_clk );

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

    axi_split_inst : entity work.axi_split4
	generic map (
	    SPLIT_BIT0 => 16,
	    SPLIT_BIT1 => 20 )
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,
	    --
	    s_axi_ro => m_axi0l_ri,
	    s_axi_ri => m_axi0l_ro,
	    s_axi_wo => m_axi0l_wi,
	    s_axi_wi => m_axi0l_wo,
	    --
	    m_axi_aclk => m_axi0a_aclk,
	    m_axi_areset_n => m_axi0a_areset_n,
	    --
	    m_axi_ri => m_axi0a_ri,
	    m_axi_ro => m_axi0a_ro,
	    m_axi_wi => m_axi0a_wi,
	    m_axi_wo => m_axi0a_wo );

    --------------------------------------------------------------------
    -- CMV SPI Interface
    --------------------------------------------------------------------

    reg_spi_inst : entity work.reg_spi
	port map (
	    s_axi_aclk => m_axi0a_aclk(0),
	    s_axi_areset_n => m_axi0a_areset_n(0),
	    --
	    s_axi_ro => m_axi0a_ri(0),
	    s_axi_ri => m_axi0a_ro(0),
	    s_axi_wo => m_axi0a_wi(0),
	    s_axi_wi => m_axi0a_wo(0),
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
	    s_axi_aclk => m_axi0a_aclk(1),
	    s_axi_areset_n => m_axi0a_areset_n(1),
	    --
	    s_axi_ro => m_axi0a_ri(2),
	    s_axi_ri => m_axi0a_ro(2),
	    s_axi_wo => m_axi0a_wi(2),
	    s_axi_wi => m_axi0a_wo(2),
	    --
	    delay_clk => serdes_clkdiv,		-- in
	    --
	    delay_in => idelay_in,		-- in
	    delay_out => idelay_out,		-- out
	    --
	    match => par_match,			-- in
	    mismatch => par_mismatch,		-- in
	    bitslip => serdes_bitslip );	-- out

    --------------------------------------------------------------------
    -- Capture Register File
    --------------------------------------------------------------------

    reg_file_inst : entity work.reg_file
	generic map (
	    REG_MASK => x"000000FF",
	    OREG_SIZE => OREG_SIZE,
	    IREG_SIZE => IREG_SIZE )
	port map (
	    s_axi_aclk => m_axi0a_aclk(2),
	    s_axi_areset_n => m_axi0a_areset_n(2),
	    --
	    s_axi_ro => m_axi0a_ri(1),
	    s_axi_ri => m_axi0a_ro(1),
	    s_axi_wo => m_axi0a_wi(1),
	    s_axi_wi => m_axi0a_wo(1),
	    --
	    oreg => reg_oreg,
	    ireg => reg_ireg );

    reg_ireg(0) <= par_match(31 downto 0);
    reg_ireg(1) <= par_mismatch(31 downto 0);
    reg_ireg(2) <= waddr_in(31 downto 0);
    reg_ireg(3) <= x"0" & writer_inactive &			-- 8bit
		   "00" & fifo_data_wrerr & fifo_data_rderr &	-- 4bit
		   fifo_data_full & fifo_data_high &		-- 2bit
		   fifo_data_low & fifo_data_empty &		-- 2bit
		   "000" & btn & swi;				-- 16bit

    --------------------------------------------------------------------
    -- CFGLUT5 Interface
    --------------------------------------------------------------------

    reg_lut5_inst : entity work.reg_lut5
	generic map (
	    LUT_COUNT => 2 )
	port map (
	    s_axi_aclk => m_axi0a_aclk(3),
	    s_axi_areset_n => m_axi0a_areset_n(3),
	    --
	    s_axi_ro => m_axi0a_ri(3),
	    s_axi_ri => m_axi0a_ro(3),
	    s_axi_wo => m_axi0a_wi(3),
	    s_axi_wi => m_axi0a_wo(3),
	    --
	    lut_clk_in => lut_clk,
	    --
	    lut_in => lut_in,
	    lut_out => lut_out );

    --------------------------------------------------------------------
    -- LVDS Input and Deserializer
    --------------------------------------------------------------------

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

	end generate;
    end generate;

    cmv_outclk <= idelay_out(CHANNELS + 1);

    ser_to_par_inst : entity work.ser_to_par
	generic map (
	    CHANNELS => CHANNELS + 1 )
	port map (
	    serdes_clk	  => serdes_clk,	-- in
	    serdes_clkdiv => serdes_clkdiv,	-- in
	    serdes_phase  => serdes_phase,	-- in
	    serdes_rst	  => serdes_reset,	-- in
	    --
	    ser_data	  => idelay_out(CHANNELS downto 0),
	    --
	    par_clk	  => serdes_clk,	-- in
	    par_enable	  => par_enable,	-- out
	    par_data	  => par_data,		-- out
	    --
	    bitslip	  => serdes_bitslip(CHANNELS downto 0) );

    phase_proc : process (serdes_clkdiv)
	variable phase_v : std_logic := '0';
    begin
	serdes_phase <= phase_v;

	if rising_edge(serdes_clkdiv) then
	    if serdes_bitslip(CHANNELS + 1) = '0' then
		phase_v := not phase_v;
	    end if;
	end if;
    end process;

    par_match_inst : entity work.par_match
	generic map (
	    CHANNELS => CHANNELS + 1 )
	port map (
	    par_clk	=> serdes_clkdiv,	-- in
	    par_data	=> par_data,		-- in
	    --
	    pattern	=> par_pattern,		-- in
	    --
	    match	=> par_match(CHANNELS downto 0),
	    mismatch	=> par_mismatch(CHANNELS downto 0) );

    pattern_proc : process
    begin
	for I in CHANNELS - 1 downto 0 loop
	    par_pattern(I) <= reg_pattern;
	end loop;

	par_pattern(CHANNELS) <= x"080";
    end process;

    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    addr_gen_inst : entity work.addr_gen
	port map (
	    clk => waddr_clk,
	    reset => waddr_reset,
	    enable => waddr_enable,
	    --
	    addr_inc => waddr_inc,
	    addr_max => waddr_max,
	    --
	    addr => waddr_in,
	    match => waddr_match );

    waddr_empty <= waddr_match or waddr_block;

    --------------------------------------------------------------------
    -- Data FIFO
    --------------------------------------------------------------------

    FIFO_data_inst : FIFO_DUALCLOCK_MACRO
	generic map (
	    DEVICE => "7SERIES",
	    DATA_WIDTH => DATA_WIDTH,
	    ALMOST_FULL_OFFSET => x"020",
	    ALMOST_EMPTY_OFFSET => x"020",
	    FIFO_SIZE => "36Kb",
	    FIRST_WORD_FALL_THROUGH => TRUE )
	port map (
	    DI => fifo_data_in,
	    WRCLK => fifo_data_wclk,
	    WREN => fifo_data_wen,
	    FULL => fifo_data_full,
	    ALMOSTFULL => fifo_data_high,
	    WRERR => fifo_data_wrerr,
	    WRCOUNT => fifo_data_wrcount,
	    --
	    DO => fifo_data_out,
	    RDCLK => fifo_data_rclk,
	    RDEN => fifo_data_ren,
	    EMPTY => fifo_data_empty,
	    ALMOSTEMPTY => fifo_data_low,
	    RDERR => fifo_data_rderr,
	    RDCOUNT => fifo_data_rdcount,
	    --
	    RST => fifo_data_rst );

    fifo_reset_inst : entity work.fifo_reset
	port map (
	    rclk => fifo_data_rclk,
	    wclk => fifo_data_wclk,
	    reset => fifo_data_reset,
	    --
	    fifo_rst => fifo_data_rst,
	    fifo_rrdy => fifo_data_rrdy,
	    fifo_wrdy => fifo_data_wrdy );


    pixel_remap_even_inst : entity work.pixel_remap
	  generic map (
	    NB_LANES => CHANNELS/2 )
	  port map (
	    clk      => serdes_clkdiv,
	    --
	    dv_par   => par_valid,
	    ctrl_in  => par_data(32),
	    par_din  => par_data(15 downto 0),
	    --
	    ctrl_out => remap_ctrl,
	    par_dout => remap_data(15 downto 0) );

    pixel_remap_odd_inst : entity work.pixel_remap
	  generic map (
	    NB_LANES => CHANNELS/2 )
	  port map (
	    clk      => serdes_clkdiv,
	    --
	    dv_par   => par_valid,
	    ctrl_in  => par_data(32),
	    par_din  => par_data(31 downto 16),
	    --
	    ctrl_out => open  ,
	    par_dout => remap_data(31 downto 16) );

    valid_proc : process (serdes_clkdiv)
    begin
	if rising_edge(serdes_clkdiv) then
	    if serdes_phase = '1' then
		par_valid <= '1';
	    else
		par_valid <= '0';
	    end if;
	end if;
    end process;


    fifo_chop_inst : entity work.fifo_chop
	port map (
	    par_clk => serdes_clk,
	    par_enable => par_enable,
	    par_data => remap_data(31 downto 0),
	    --
	    par_ctrl => remap_ctrl,
	    --
	    fifo_clk => fifo_data_wclk,
	    fifo_enable => data_wen,
	    fifo_data => data_in,
	    --
	    fifo_ctrl => fifo_ctrl );

    -- lut_dval_in <= fifo_ctrl(0);
    -- lut_lval_in <= fifo_ctrl(0);
    -- lut_fval_in <= fifo_ctrl(0);

    match_en <= '1'
	when (fifo_ctrl(2 downto 0) and reg_mask) = reg_mval
	else '0';

    data_filter_inst : entity work.data_filter
	port map (
	    clk => fifo_data_wclk,
	    enable => match_en,
	    --
	    en_in => data_wen,
	    data_in => data_in,
	    --
	    en_out => data_wen_d,
	    data_out => data_in_d );

    -- fifo_data_wclk <= iserdes_clk;
    fifo_data_wen <= data_wen_d when fifo_data_wrdy = '1' else '0';
    wdata_full <= fifo_data_full when fifo_data_wrdy = '1' else '1';
    fifo_data_in <= data_in_d;

    fifo_data_rclk <= wdata_clk;
    fifo_data_ren <= wdata_enable when fifo_data_rrdy = '1' else '0';
    wdata_empty <= fifo_data_low when fifo_data_rrdy = '1' else '1';
    wdata_in <= fifo_data_out;

    --------------------------------------------------------------------
    -- AXIHP Writer
    --------------------------------------------------------------------

    axihp_writer_inst : entity work.axihp_writer
	generic map (
	    DATA_WIDTH => 64,
	    DATA_COUNT => 16,
	    ADDR_MASK => WADDR_MASK(0),
	    ADDR_DATA => WADDR_BASE(0) )
	port map (
	    m_axi_aclk => writer_clk,		-- in
	    m_axi_areset_n => s_axi_areset_n(0), -- in
	    enable => writer_enable(0),		-- in
	    inactive => writer_inactive(0),	-- out
	    --
	    m_axi_wo => s_axi_wi(0),
	    m_axi_wi => s_axi_wo(0),
	    --
	    addr_clk => waddr_clk,		-- out
	    addr_enable => waddr_enable,	-- out
	    addr_in => waddr_in,		-- in
	    addr_empty => waddr_empty,		-- in
	    --
	    data_clk => wdata_clk,		-- out
	    data_enable => wdata_enable,	-- out
	    data_in => wdata_in,		-- in
	    data_empty => wdata_empty,		-- in
	    --
	    writer_error => writer_error(0),	-- out
	    writer_active => writer_active,	-- out
	    writer_unconf => writer_unconf );	-- out

    s_axi_aclk(0) <= writer_clk;

    --------------------------------------------------------------------
    -- LED/Button/Switch Override
    --------------------------------------------------------------------

    swi_ovr <= (swi and not swi_mask) or (swi_val and swi_mask);
    btn_ovr <= (btn and not btn_mask) or (btn_val and btn_mask);
    led <= (led_out and not led_mask) or (led_val and led_mask);

    --------------------------------------------------------------------
    -- Button input
    --------------------------------------------------------------------

    cmv_frame_req <= btn_ovr(0);
    cmv_t_exp1 <= btn_ovr(1);
    cmv_t_exp2 <= btn_ovr(2);

    --------------------------------------------------------------------
    -- LED Status output
    --------------------------------------------------------------------

    led_out(0) <= cmv_pll_locked;
    led_out(1) <= lvds_pll_locked;
    led_out(2) <= idelay_valid;

    div_lvds_inst0 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => cmv_lvds_clk,
	    clk_out => led_out(6) );

    div_lvds_inst1 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => lvds_clk,
	    clk_out => led_out(7) );

    led_out(4 downto 3) <= (others => '0');
    led_out(5) <= wdata_full;

    STARTUPE2_inst : STARTUPE2
	generic map (
	    PROG_USR => "FALSE",	-- Program event security feature.
	    SIM_CCLK_FREQ => 0.0 )	-- Configuration Clock Frequency(ns)
	port map (
	    CFGCLK => open,		-- 1-bit output: Configuration main clock output
	    CFGMCLK => open,		-- 1-bit output: Configuration internal oscillator clock output
	    EOS => open,		-- 1-bit output: Active high output signal indicating the End Of Startup.
	    PREQ => open,		-- 1-bit output: PROGRAM request to fabric output
	    CLK => '0',			-- 1-bit input: User start-up clock input
	    GSR => '0',			-- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
	    GTS => '0',			-- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
	    KEYCLEARB => '0',		-- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
	    PACK => '0',		-- 1-bit input: PROGRAM acknowledge input
	    USRCCLKO => '0',		-- 1-bit input: User CCLK input
	    USRCCLKTS => '0',		-- 1-bit input: User CCLK 3-state enable input
	    USRDONEO => '0',		-- 1-bit input: User DONE pin output control
	    USRDONETS => led_done );	-- 1-bit input: User DONE 3-state enable output

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
	pmod_clk, swi_ovr,
	par_match, par_mismatch, par_data,
	m_axi0_wo, m_axi0_wi, m_axi0_ro, m_axi0_ri )

    begin
	case swi_ovr(3 downto 0) is
	    when "0000" =>
		pmod_v0 <= par_match(0)	 & par_mismatch(0)  & "00" & par_data(0) &
			   par_match(1)	 & par_mismatch(1)  & "00" & par_data(1) &
			   par_match(2)	 & par_mismatch(2)  & "00" & par_data(2) &
			   par_match(3)	 & par_mismatch(3)  & "00" & par_data(3);

		pmod_v1 <= par_match(4)	 & par_mismatch(4)  & "00" & par_data(4) &
			   par_match(5)	 & par_mismatch(5)  & "00" & par_data(5) &
			   par_match(6)	 & par_mismatch(6)  & "00" & par_data(6) &
			   par_match(7)	 & par_mismatch(7)  & "00" & par_data(7);

	    when "0001" =>
		pmod_v0 <= par_match(8)	 & par_mismatch(8)  & "00" & par_data(8) &
			   par_match(9)	 & par_mismatch(9)  & "00" & par_data(9) &
			   par_match(10) & par_mismatch(10) & "00" & par_data(10) &
			   par_match(11) & par_mismatch(11) & "00" & par_data(11);

		pmod_v1 <= par_match(12) & par_mismatch(12) & "00" & par_data(12) &
			   par_match(13) & par_mismatch(13) & "00" & par_data(13) &
			   par_match(14) & par_mismatch(14) & "00" & par_data(14) &
			   par_match(15) & par_mismatch(15) & "00" & par_data(15);

	    when "0010" =>
		pmod_v0 <= par_match(16) & par_mismatch(16) & "00" & par_data(16) &
			   par_match(17) & par_mismatch(17) & "00" & par_data(17) &
			   par_match(18) & par_mismatch(18) & "00" & par_data(18) &
			   par_match(19) & par_mismatch(19) & "00" & par_data(19);

		pmod_v1 <= par_match(20) & par_mismatch(20) & "00" & par_data(20) &
			   par_match(21) & par_mismatch(21) & "00" & par_data(21) &
			   par_match(22) & par_mismatch(22) & "00" & par_data(22) &
			   par_match(23) & par_mismatch(23) & "00" & par_data(23);

	    when "0011" =>
		pmod_v0 <= par_match(24) & par_mismatch(24) & "00" & par_data(24) &
			   par_match(25) & par_mismatch(25) & "00" & par_data(25) &
			   par_match(26) & par_mismatch(26) & "00" & par_data(26) &
			   par_match(27) & par_mismatch(27) & "00" & par_data(27);

		pmod_v1 <= par_match(28) & par_mismatch(28) & "00" & par_data(28) &
			   par_match(29) & par_mismatch(29) & "00" & par_data(29) &
			   par_match(30) & par_mismatch(30) & "00" & par_data(30) &
			   par_match(31) & par_mismatch(31) & "00" & par_data(31);

	    when "0100" =>
		pmod_v0 <= x"000000000000" &
			   par_match(32) & par_mismatch(32) & "00" & par_data(32);

		pmod_v1 <= par_match(31 downto 0) & par_mismatch(31 downto 0);


	    when "1000" =>
		pmod_v0 <= wdata_enable & '0' & wdata_empty & '0' &	-- 4bit
			   fifo_data_full & fifo_data_high &		-- 2bit
			   fifo_data_low & fifo_data_empty &		-- 2bit
			   fifo_data_wrdy & fifo_data_wrerr &		-- 2bit
			   fifo_data_rrdy & fifo_data_rderr &		-- 2bit
			   "000" & fifo_data_rst &			-- 4bit
			   writer_enable & writer_inactive &		-- 8bit
			   writer_active & writer_unconf &		-- 8bit
			   waddr_in;

		pmod_v1 <= wdata_in;

	    when "1001" =>
		pmod_v0 <= waddr_enable & '0' & waddr_empty & '0' &	-- 4bit
			   "000" & waddr_reset &			-- 4bit
			   x"000000" &
			   waddr_in;
		pmod_v1(63 downto 32) <= waddr_inc;
		pmod_v1(31 downto 0) <= waddr_max;

	    when others =>
		pmod_v0 <= (others => '0');

		pmod_v1 <= (others => '0');
	end case;
    end process;

end RTL;
