----------------------------------------------------------------------------
--  top.vhd (for axi3_hdmi)
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
--  Vivado 2013.3:
--    mkdir -p build.vivado
--    (cd build.vivado && vivado -mode tcl -source ../vivado.tcl)
--    (cd build.vivado && promgen -w -b -p bin -u 0 axi3_hdmi.bit -data_width 32)
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

library unimacro;
use unimacro.VCOMPONENTS.all;

use work.axi3m_pkg.all;		-- AXI3 Master
use work.axi3ml_pkg.all;	-- AXI3 Lite Master

use work.axi3s_pkg.all;		-- AXI3 Slave Interface

-- use work.reduce_pkg.all;	-- Logic Reduction

use work.reg_array_pkg.ALL;
-- use work.val_array_pkg.ALL;

use work.fifo_pkg.ALL;		-- FIFO Functions


entity top is
    port (
	clk_100 : in std_logic;			-- input clock to FPGA
	--
	cmv_sda : inout std_logic;
	cmv_scl : inout std_logic;
	--
	spi_en : out std_logic;
	spi_clk : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic;
	--
	hd_data	 : out std_logic_vector(15 downto 0);	-- HDMI DATA
	hd_hsync : out std_logic;			-- HDMI HSYNC
	hd_vsync : out std_logic;			-- HDMI VSYNC
	hd_de	 : out std_logic;			-- HDMI DE
	hd_clk	 : out std_logic;			-- HDMI CLK
	--
	hd_sda	 : inout std_logic;			-- HDMI SDA
	hd_scl	 : inout std_logic;			-- HDMI SCL
	--
	pmod_jcm : out std_logic_vector(3 downto 0);
	pmod_jca : out std_logic_vector(3 downto 0);
	--
	pmod_jdm : out std_logic_vector(3 downto 0);
	pmod_jda : out std_logic_vector(3 downto 0);
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
    -- PS7 Signals
    --------------------------------------------------------------------

    signal ps_fclk : std_logic_vector(3 downto 0);
    signal ps_reset_n : std_logic_vector(3 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI Master Signals
    --------------------------------------------------------------------

    signal m_axi1_aclk : std_logic;
    signal m_axi1_areset_n : std_logic;

    signal m_axi1_ri : axi3m_read_in_r;
    signal m_axi1_ro : axi3m_read_out_r;
    signal m_axi1_wi : axi3m_write_in_r;
    signal m_axi1_wo : axi3m_write_out_r;

    signal m_axi1l_ri : axi3ml_read_in_r;
    signal m_axi1l_ro : axi3ml_read_out_r;
    signal m_axi1l_wi : axi3ml_write_in_r;
    signal m_axi1l_wo : axi3ml_write_out_r;

    signal m_axi10_aclk : std_logic;
    signal m_axi10_areset_n : std_logic;

    signal m_axi10_ri : axi3ml_read_in_r;
    signal m_axi10_ro : axi3ml_read_out_r;
    signal m_axi10_wi : axi3ml_write_in_r;
    signal m_axi10_wo : axi3ml_write_out_r;

    signal m_axi11_aclk : std_logic;
    signal m_axi11_areset_n : std_logic;

    signal m_axi11_ri : axi3ml_read_in_r;
    signal m_axi11_ro : axi3ml_read_out_r;
    signal m_axi11_wi : axi3ml_write_in_r;
    signal m_axi11_wo : axi3ml_write_out_r;

    signal m_axi110_aclk : std_logic;
    signal m_axi110_areset_n : std_logic;

    signal m_axi110_ri : axi3ml_read_in_r;
    signal m_axi110_ro : axi3ml_read_out_r;
    signal m_axi110_wi : axi3ml_write_in_r;
    signal m_axi110_wo : axi3ml_write_out_r;

    signal m_axi111_aclk : std_logic;
    signal m_axi111_areset_n : std_logic;

    signal m_axi111_ri : axi3ml_read_in_r;
    signal m_axi111_ro : axi3ml_read_out_r;
    signal m_axi111_wi : axi3ml_write_in_r;
    signal m_axi111_wo : axi3ml_write_out_r;

    --------------------------------------------------------------------
    -- PS7 AXI Slave Signals
    --------------------------------------------------------------------

    signal s_axi_aclk : std_logic_vector(3 downto 0);
    signal s_axi_areset_n : std_logic_vector(3 downto 0);

    type axi3s_read_in_t is array (natural range <>) of
	axi3s_read_in_r;

    signal s_axi_ri : axi3s_read_in_t(3 downto 0);

    type axi3s_read_out_t is array (natural range <>) of
	axi3s_read_out_r;

    signal s_axi_ro : axi3s_read_out_t(3 downto 0);

    --------------------------------------------------------------------
    -- Gen Register File Signals
    --------------------------------------------------------------------

    signal reg_ogen : reg_array(0 to 15);
    signal reg_igen : reg_array(0 to 3);

    --------------------------------------------------------------------
    -- Register File Signals
    --------------------------------------------------------------------

    signal reg_oreg : reg_array(0 to 15);
    signal reg_ireg : reg_array(0 to 3);

    --------------------------------------------------------------------
    -- I2C0 Signals
    --------------------------------------------------------------------

    signal i2c0_sda_i : std_logic;
    signal i2c0_sda_o : std_logic;
    signal i2c0_sda_t : std_logic;
    signal i2c0_sda_t_n : std_logic;

    signal i2c0_scl_i : std_logic;
    signal i2c0_scl_o : std_logic;
    signal i2c0_scl_t : std_logic;
    signal i2c0_scl_t_n : std_logic;

    --------------------------------------------------------------------
    -- I2C1 Signals
    --------------------------------------------------------------------

    signal i2c1_sda_i : std_logic;
    signal i2c1_sda_o : std_logic;
    signal i2c1_sda_t : std_logic;
    signal i2c1_sda_t_n : std_logic;

    signal i2c1_scl_i : std_logic;
    signal i2c1_scl_o : std_logic;
    signal i2c1_scl_t : std_logic;
    signal i2c1_scl_t_n : std_logic;

    --------------------------------------------------------------------
    -- PLL Signals
    --------------------------------------------------------------------

    signal pll_clkout : std_logic_vector(5 downto 0);

    signal pll_clkin1 : std_logic;
    signal pll_clkin2 : std_logic;
    signal pll_clkinsel : std_logic;

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_locked : std_logic;
    signal pll_rst : std_logic;

    signal pll_dclk : std_logic;
    signal pll_den : std_logic;
    signal pll_dwe : std_logic;
    signal pll_drdy : std_logic;

    signal pll_daddr : std_logic_vector(6 downto 0);
    signal pll_do : std_logic_vector(15 downto 0);
    signal pll_di : std_logic_vector(15 downto 0);

    signal pll_pwrdwn : std_logic;

    --------------------------------------------------------------------
    -- Scan Signals
    --------------------------------------------------------------------

    signal scan_clk : std_logic;
    signal scan_reset_n : std_logic;

    signal scan_total_w : std_logic_vector(11 downto 0);
    signal scan_total_h : std_logic_vector(11 downto 0);

    signal scan_hcnt : std_logic_vector(11 downto 0);
    signal scan_vcnt : std_logic_vector(11 downto 0);

    signal scan_hdisp_s : std_logic_vector(11 downto 0);
    signal scan_hdisp_e : std_logic_vector(11 downto 0);

    signal scan_hdisp : std_logic;

    signal scan_vdisp_s : std_logic_vector(11 downto 0);
    signal scan_vdisp_e : std_logic_vector(11 downto 0);

    signal scan_vdisp : std_logic;

    signal scan_hsync_s : std_logic_vector(11 downto 0);
    signal scan_hsync_e : std_logic_vector(11 downto 0);

    signal scan_hsync : std_logic;

    signal scan_vsync_s : std_logic_vector(11 downto 0);
    signal scan_vsync_e : std_logic_vector(11 downto 0);

    signal scan_vsync : std_logic;


    signal scan_vconf_s : std_logic_vector(11 downto 0);
    signal scan_vconf_e : std_logic_vector(11 downto 0);
    signal scan_vconf : std_logic;
    signal scan_vc_on : std_logic;
    signal scan_vcoff : std_logic;

    signal scan_hdata_s : std_logic_vector(11 downto 0);
    signal scan_hdata_e : std_logic_vector(11 downto 0);

    signal scan_hdata : std_logic;

    signal scan_vdata_s : std_logic_vector(11 downto 0);
    signal scan_vdata_e : std_logic_vector(11 downto 0);

    signal scan_vdata : std_logic;

    --------------------------------------------------------------------
    -- HDMI PLL Signals
    --------------------------------------------------------------------

    signal hdmi_pll_locked : std_logic;

    signal hdmi_clk : std_logic;

    --------------------------------------------------------------------
    -- HDMI Signals
    --------------------------------------------------------------------

    signal hdmi_reset_n : std_logic;

    signal hdmi_hblank : std_logic;
    signal hdmi_vblank : std_logic;

    signal hdmi_frame : std_logic_vector(7 downto 0);

    signal hdmi_eo : std_logic_vector(15 downto 0);

    --------------------------------------------------------------------
    -- Addr Gen Signals
    --------------------------------------------------------------------

    constant ADDR_COUNT : natural := 4;

    signal addr_gen_clk : std_logic_vector(ADDR_COUNT - 1 downto 0);
    signal addr_gen_reset : std_logic_vector(ADDR_COUNT - 1 downto 0);
    signal addr_gen_enable : std_logic_vector(ADDR_COUNT - 1 downto 0);
    signal addr_gen_auto : std_logic_vector(ADDR_COUNT - 1 downto 0);

    --------------------------------------------------------------------
    -- Reader/Writer Signals
    --------------------------------------------------------------------

    constant READER_COUNT : natural := 2;
    constant WRITER_COUNT : natural := 2;
    constant RW_COUNT : natural := READER_COUNT + WRITER_COUNT;

    type rdata_t is array (natural range <>) of
	std_logic_vector (15 downto 0);

    signal rdata_clk	: std_logic_vector(RW_COUNT - 1 downto 0);
    signal rdata_enable : std_logic_vector(RW_COUNT - 1 downto 0);
    signal rdata_out	: rdata_t(RW_COUNT - 1 downto 0);
    signal rdata_empty	: std_logic_vector(RW_COUNT - 1 downto 0);

    -- attribute DONT_TOUCH of rdata_clk : signal is "TRUE";
    -- attribute DONT_TOUCH of rdata_enable : signal is "TRUE";
    -- attribute DONT_TOUCH of rdata_out : signal is "TRUE";
    -- attribute DONT_TOUCH of rdata_empty : signal is "TRUE";

    type raddr_t is array (natural range <>) of
	std_logic_vector (31 downto 0);

    signal raddr_clk	: std_logic_vector(RW_COUNT - 1 downto 0);
    signal raddr_enable : std_logic_vector(RW_COUNT - 1 downto 0);
    signal raddr_in	: raddr_t(RW_COUNT - 1 downto 0);
    signal raddr_full	: std_logic_vector(RW_COUNT - 1 downto 0);

    -- attribute DONT_TOUCH of raddr_clk : signal is "TRUE";
    -- attribute DONT_TOUCH of raddr_enable : signal is "TRUE";
    -- attribute DONT_TOUCH of raddr_in : signal is "TRUE";
    -- attribute DONT_TOUCH of raddr_full : signal is "TRUE";

    signal reader_enable : std_logic_vector(RW_COUNT - 1 downto 0);
    signal reader_reset : std_logic_vector(RW_COUNT - 1 downto 0);

    type reader_state_t is array (natural range <>) of
	std_logic_vector (7 downto 0);

    signal reader_state : reader_state_t(RW_COUNT - 1 downto 0);

    type reader_data_t is array (natural range <>) of
	std_logic_vector (63 downto 0);

    signal reader_data : reader_data_t(RW_COUNT - 1 downto 0);

    type reader_addr_t is array (natural range <>) of
	std_logic_vector (31 downto 0);

    signal reader_addr : reader_addr_t(RW_COUNT - 1 downto 0);

    signal reader_clk : std_logic;

    -- attribute DONT_TOUCH of reader_enable : signal is "TRUE";
    -- attribute DONT_TOUCH of reader_data : signal is "TRUE";
    -- attribute DONT_TOUCH of reader_addr : signal is "TRUE";
    -- attribute DONT_TOUCH of reader_clk : signal is "TRUE";

    signal data_clk : std_logic;

    --------------------------------------------------------------------
    -- Debug Signals
    --------------------------------------------------------------------

    signal rcnt : unsigned (7 downto 0);

    attribute DONT_TOUCH of rcnt : signal is "TRUE";

    signal pmod_clk : std_logic;

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
	    ps_fclk => ps_fclk,
	    ps_reset_n => ps_reset_n,
	    --
	    i2c0_sda_i => i2c0_sda_i,
	    i2c0_sda_o => i2c0_sda_o,
	    i2c0_sda_t_n => i2c0_sda_t_n,
	    --
	    i2c0_scl_i => i2c0_scl_i,
	    i2c0_scl_o => i2c0_scl_o,
	    i2c0_scl_t_n => i2c0_scl_t_n,
	    --
	    m_axi1_aclk => m_axi1_aclk,
	    m_axi1_areset_n => m_axi1_areset_n,
	    --
	    m_axi1_arid => m_axi1_ro.arid,
	    m_axi1_araddr => m_axi1_ro.araddr,
	    m_axi1_arburst => m_axi1_ro.arburst,
	    m_axi1_arlen => m_axi1_ro.arlen,
	    m_axi1_arsize => m_axi1_ro.arsize,
	    m_axi1_arprot => m_axi1_ro.arprot,
	    m_axi1_arvalid => m_axi1_ro.arvalid,
	    m_axi1_arready => m_axi1_ri.arready,
	    --
	    m_axi1_rid => m_axi1_ri.rid,
	    m_axi1_rdata => m_axi1_ri.rdata,
	    m_axi1_rlast => m_axi1_ri.rlast,
	    m_axi1_rresp => m_axi1_ri.rresp,
	    m_axi1_rvalid => m_axi1_ri.rvalid,
	    m_axi1_rready => m_axi1_ro.rready,
	    --
	    m_axi1_awid => m_axi1_wo.awid,
	    m_axi1_awaddr => m_axi1_wo.awaddr,
	    m_axi1_awburst => m_axi1_wo.awburst,
	    m_axi1_awlen => m_axi1_wo.awlen,
	    m_axi1_awsize => m_axi1_wo.awsize,
	    m_axi1_awprot => m_axi1_wo.awprot,
	    m_axi1_awvalid => m_axi1_wo.awvalid,
	    m_axi1_awready => m_axi1_wi.wready,
	    --
	    m_axi1_wid => m_axi1_wo.wid,
	    m_axi1_wdata => m_axi1_wo.wdata,
	    m_axi1_wstrb => m_axi1_wo.wstrb,
	    m_axi1_wlast => m_axi1_wo.wlast,
	    m_axi1_wvalid => m_axi1_wo.wvalid,
	    m_axi1_wready => m_axi1_wi.wready,
	    --
	    m_axi1_bid => m_axi1_wi.bid,
	    m_axi1_bresp => m_axi1_wi.bresp,
	    m_axi1_bvalid => m_axi1_wi.bvalid,
	    m_axi1_bready => m_axi1_wo.bready,
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
	    s_axi3_rcount => s_axi_ro(3).rcount );

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
	    T => i2c0_sda_t, IO => hd_sda );

    i2c0_scl_t <= not i2c0_scl_t_n;

    IOBUF_scl_inst0 : IOBUF
	generic map (
	    IOSTANDARD => "LVCMOS33",
	    DRIVE => 4 )
	port map (
	    I => i2c0_scl_o, O => i2c0_scl_i,
	    T => i2c0_scl_t, IO => hd_scl );

    --------------------------------------------------------------------
    -- AXI3 Interconnect
    --------------------------------------------------------------------

    axi_lite_inst0 : entity work.axi_lite
	port map (
	    s_axi_aclk => m_axi1_aclk,
	    s_axi_areset_n => m_axi1_areset_n,

	    s_axi_ro => m_axi1_ri,
	    s_axi_ri => m_axi1_ro,
	    s_axi_wo => m_axi1_wi,
	    s_axi_wi => m_axi1_wo,

	    m_axi_ro => m_axi1l_ro,
	    m_axi_ri => m_axi1l_ri,
	    m_axi_wo => m_axi1l_wo,
	    m_axi_wi => m_axi1l_wi );

    axi_split_inst0 : entity work.axi_split
	generic map (
	    SPLIT_BIT => 16 )
	port map (
	    s_axi_aclk => m_axi1_aclk,
	    s_axi_areset_n => m_axi1_areset_n,
	    --
	    s_axi_ro => m_axi1l_ri,
	    s_axi_ri => m_axi1l_ro,
	    s_axi_wo => m_axi1l_wi,
	    s_axi_wi => m_axi1l_wo,
	    --
	    m_axi0_aclk => m_axi10_aclk,
	    m_axi0_areset_n => m_axi10_areset_n,
	    --
	    m_axi0_ri => m_axi10_ri,
	    m_axi0_ro => m_axi10_ro,
	    m_axi0_wi => m_axi10_wi,
	    m_axi0_wo => m_axi10_wo,
	    --
	    m_axi1_aclk => m_axi11_aclk,
	    m_axi1_areset_n => m_axi11_areset_n,
	    --
	    m_axi1_ri => m_axi11_ri,
	    m_axi1_ro => m_axi11_ro,
	    m_axi1_wi => m_axi11_wi,
	    m_axi1_wo => m_axi11_wo );

    axi_split_inst1 : entity work.axi_split
	generic map (
	    SPLIT_BIT => 12 )
	port map (
	    s_axi_aclk => m_axi1_aclk,
	    s_axi_areset_n => m_axi1_areset_n,
	    --
	    s_axi_ro => m_axi11_ri,
	    s_axi_ri => m_axi11_ro,
	    s_axi_wo => m_axi11_wi,
	    s_axi_wi => m_axi11_wo,
	    --
	    m_axi0_aclk => m_axi110_aclk,
	    m_axi0_areset_n => m_axi110_areset_n,
	    --
	    m_axi0_ri => m_axi110_ri,
	    m_axi0_ro => m_axi110_ro,
	    m_axi0_wi => m_axi110_wi,
	    m_axi0_wo => m_axi110_wo,
	    --
	    m_axi1_aclk => m_axi111_aclk,
	    m_axi1_areset_n => m_axi111_areset_n,
	    --
	    m_axi1_ri => m_axi111_ri,
	    m_axi1_ro => m_axi111_ro,
	    m_axi1_wi => m_axi111_wi,
	    m_axi1_wo => m_axi111_wo );

    m_axi1_aclk <= clk_100;

    --------------------------------------------------------------------
    -- HDMI PLL
    --------------------------------------------------------------------

    hdmi_pll_inst : PLLE2_ADV
	generic map (
	    BANDWIDTH => "HIGH",	-- OPTIMIZED, HIGH, LOW
	    CLKFBOUT_MULT => 15,	-- Multiply value (2-64)
	    CLKFBOUT_PHASE => 0.0,	-- Phase offset (-360.000-360.000).
	    --
	    CLKIN1_PERIOD => 10.0,
	    CLKIN2_PERIOD => 10.0,
	    --
	    CLKOUT0_DIVIDE => 10,	-- (1-128)
	    CLKOUT1_DIVIDE => 20,
	    CLKOUT2_DIVIDE => 8,
	    CLKOUT3_DIVIDE => 1,
	    CLKOUT4_DIVIDE => 1,
	    CLKOUT5_DIVIDE => 1,
	    --
	    CLKOUT0_DUTY_CYCLE => 0.5,	-- (0.001-0.999)
	    CLKOUT1_DUTY_CYCLE => 0.5,
	    CLKOUT2_DUTY_CYCLE => 0.5,
	    CLKOUT3_DUTY_CYCLE => 0.5,
	    CLKOUT4_DUTY_CYCLE => 0.5,
	    CLKOUT5_DUTY_CYCLE => 0.5,
	    --
	    CLKOUT0_PHASE => 0.0,	-- (-360.000-360.000)
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0,
	    CLKOUT3_PHASE => 0.0,
	    CLKOUT4_PHASE => 0.0,
	    CLKOUT5_PHASE => 0.0,
	    --
	    COMPENSATION => "ZHOLD",	-- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
	    DIVCLK_DIVIDE => 1,		-- Master division value (1-56)
	    --
	    REF_JITTER1 => 0.01,		-- Jitter in UI (0.000-0.999)
	    REF_JITTER2 => 0.01,
	    --
	    STARTUP_WAIT => "FALSE" )
	port map (
	    CLKIN1 => pll_clkin1,
	    CLKIN2 => pll_clkin2,
	    CLKINSEL => pll_clkinsel,
	    --
	    CLKOUT0 => pll_clkout(0),
	    CLKOUT1 => pll_clkout(1),
	    CLKOUT2 => pll_clkout(2),
	    CLKOUT3 => pll_clkout(3),
	    CLKOUT4 => pll_clkout(4),
	    CLKOUT5 => pll_clkout(5),
	    --
	    CLKFBOUT => pll_fbout,
	    CLKFBIN => pll_fbin,
	    --
	    LOCKED => pll_locked,
	    --
	    RST => pll_rst,
	    --
	    DCLK => pll_dclk,
	    DEN => pll_den,
	    DWE => pll_dwe,
	    DRDY => pll_drdy,
	    --
	    DADDR => pll_daddr,
	    DO => pll_do,
	    DI => pll_di,
	    --
	    PWRDWN => pll_pwrdwn );

    pll_rst <= not ps_reset_n(0);

    pll_fbin <= pll_fbout;

    pll_clkin1 <= clk_100;
    pll_clkin2 <= ps_fclk(0);
    pll_clkinsel <= ps_reset_n(2);

    pll_pwrdwn <= '0';

    BUFG_inst0 : BUFGCE
	port map (
	    I => pll_clkout(0),
	    CE => pll_locked,
	    O => hdmi_clk );

    BUFG_inst1 : BUFGCE
	port map (
	    I => pll_clkout(1),
	    CE => pll_locked,
	    O => data_clk );

    BUFG_inst2 : BUFGCE
	port map (
	    I => pll_clkout(2),
	    CE => pll_locked,
	    O => reader_clk );

    hdmi_pll_locked <= pll_locked;

    --------------------------------------------------------------------
    -- PLL DRP Register File
    --------------------------------------------------------------------

    reg_pll_inst : entity work.reg_pll
	port map (
	    s_axi_aclk => m_axi111_aclk,
	    s_axi_areset_n => m_axi111_areset_n,
	    --
	    s_axi_ro => m_axi111_ri,
	    s_axi_ri => m_axi111_ro,
	    s_axi_wo => m_axi111_wi,
	    s_axi_wi => m_axi111_wo,
	    --
	    pll_dclk => pll_dclk,
	    pll_den => pll_den,
	    pll_dwe => pll_dwe,
	    pll_drdy => pll_drdy,
	    --
	    pll_daddr => pll_daddr,
	    pll_dout => pll_do,
	    pll_din => pll_di );

    --------------------------------------------------------------------
    -- Scan Register File
    --------------------------------------------------------------------

    reg_file_inst0 : entity work.reg_file
	generic map (
	    NAME => "ScanGen",
	    REG_MASK => x"000000FF",
	    OREG_SIZE => 16,
	    IREG_SIZE => 4 )
	port map (
	    s_axi_aclk => m_axi10_aclk,
	    s_axi_areset_n => m_axi10_areset_n,
	    --
	    s_axi_ro => m_axi10_ri,
	    s_axi_ri => m_axi10_ro,
	    s_axi_wo => m_axi10_wi,
	    s_axi_wi => m_axi10_wo,
	    --
	    oreg => reg_oreg,
	    ireg => reg_igen );

    scan_total_w <= reg_oreg(0)(11 downto 0);
    scan_total_h <= reg_oreg(1)(11 downto 0);

    scan_hdisp_s <= reg_oreg(2)(11 downto 0);
    scan_hdisp_e <= reg_oreg(3)(11 downto 0);

    scan_vdisp_s <= reg_oreg(4)(11 downto 0);
    scan_vdisp_e <= reg_oreg(5)(11 downto 0);

    scan_hsync_s <= reg_oreg(6)(11 downto 0);
    scan_hsync_e <= reg_oreg(7)(11 downto 0);

    scan_vsync_s <= reg_oreg(8)(11 downto 0);
    scan_vsync_e <= reg_oreg(9)(11 downto 0);


    scan_vconf_s <= reg_oreg(10)(11 downto 0);
    scan_vconf_e <= reg_oreg(11)(11 downto 0);

    scan_hdata_s <= reg_oreg(12)(11 downto 0);
    scan_hdata_e <= reg_oreg(13)(11 downto 0);

    scan_vdata_s <= reg_oreg(14)(11 downto 0);
    scan_vdata_e <= reg_oreg(15)(11 downto 0);


    --------------------------------------------------------------------
    -- Scan Generator
    --------------------------------------------------------------------

    scan_gen_inst : entity work.scan_gen
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    total_w => scan_total_w,
	    total_h => scan_total_h,
	    --
	    hcnt => scan_hcnt,
	    vcnt => scan_vcnt );

    scan_hdisp_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_hcnt,
	    cval_on => scan_hdisp_s,
	    cval_off => scan_hdisp_e,
	    --
	    match => scan_hdisp );

    scan_vdisp_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => scan_vdisp_s,
	    cval_off => scan_vdisp_e,
	    --
	    match => scan_vdisp );

    scan_hsync_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_hcnt,
	    cval_on => scan_hsync_s,
	    cval_off => scan_hsync_e,
	    --
	    match => scan_hsync );

    scan_vsync_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => scan_vsync_s,
	    cval_off => scan_vsync_e,
	    --
	    match => scan_vsync );

    scan_vconf_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => scan_vconf_s,
	    cval_off => scan_vconf_e,
	    --
	    match_on => scan_vc_on,
	    match_off => scan_vcoff,
	    match => scan_vconf );

    scan_hdata_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_hcnt,
	    cval_on => scan_hdata_s,
	    cval_off => scan_hdata_e,
	    --
	    match => scan_hdata );

    scan_vdata_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => scan_vdata_s,
	    cval_off => scan_vdata_e,
	    --
	    match => scan_vdata );


    scan_clk <= hdmi_clk;
    scan_reset_n <= ps_reset_n(1);

    hdmi_eo <= x"0000"
	when (scan_hcnt(0) xor scan_vcnt(0)) = '0'
	else x"FFFF";

    hd_data <= hdmi_eo when (scan_hdata and scan_vdata) = '0'
	else rdata_out(2) when scan_hcnt(0) = '0'
	else rdata_out(3);

    hd_hsync <= scan_hsync;
    hd_vsync <= scan_vsync;

    hd_de <= scan_hdisp and scan_vdisp;

    hd_clk <= hdmi_clk;


    --------------------------------------------------------------------
    -- AddrGen Register File
    --------------------------------------------------------------------

    reg_file_inst1 : entity work.reg_file
	generic map (
	    NAME => "AddrGen",
	    REG_MASK => x"000000FF",
	    OREG_SIZE => 16,
	    IREG_SIZE => 4 )
	port map (
	    s_axi_aclk => m_axi110_aclk,
	    s_axi_areset_n => m_axi110_areset_n,
	    --
	    s_axi_ro => m_axi110_ri,
	    s_axi_ri => m_axi110_ro,
	    s_axi_wo => m_axi110_wi,
	    s_axi_wi => m_axi110_wo,
	    --
	    oreg => reg_ogen,
	    ireg => reg_igen );

    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    GEN_ADDR: for I in 3 downto 2 generate
    begin
	addr_gen_inst : entity work.addr_gen
	    port map (
		clk => addr_gen_clk(I),
		reset => addr_gen_reset(I),
		enable => addr_gen_enable(I),
		--
		addr_min => unsigned(reg_ogen((I-2)*8 + 0)),
		addr_inc => unsigned(reg_ogen((I-2)*8 + 1)),
		addr_cnt => unsigned(reg_ogen((I-2)*8 + 2)),
		addr_add => unsigned(reg_ogen((I-2)*8 + 3)),
		addr_max => unsigned(reg_ogen((I-2)*8 + 4)),
		--
		addr => raddr_in(I) );

	addr_gen_clk(I) <= clk_100;
	-- addr_gen_reset(I) <= swi(4);
	addr_gen_reset(I) <= scan_vc_on;
	addr_gen_auto(I) <= swi(4);
	addr_gen_enable(I) <= not raddr_full(I);

    end generate;

    GEN_DATA: for I in 3 downto 2 generate
    begin
	RDR2 : if I = 2 generate
	begin
	    AXI_DSRC_inst : entity work.axi_dsrc
		generic map (
		    ADDR_MASK => x"00FFFFFF",
		    ADDR_DATA => x"1B000000" )
		port map (
		    m_axi_aclk => s_axi_aclk(1),
		    m_axi_areset_n => s_axi_areset_n(1),
		    enable => reader_enable(I),		-- in, reader
		    reset => reader_reset(I),		-- in, reset
		    --
		    m_axi_ro => s_axi_ri(1),
		    m_axi_ri => s_axi_ro(1),
		    --
		    addr_clk => raddr_clk(I),		-- in
		    addr_enable => raddr_enable(I),	-- in
		    addr_full => raddr_full(I),		-- out
		    addr_in => raddr_in(I),		-- in
		    --
		    data_clk => rdata_clk(I),		-- in
		    data_enable => rdata_enable(I),	-- in
		    data_empty => rdata_empty(I),	-- out
		    data_out => rdata_out(I),		-- out
		    --
		    reader_data => reader_data(I),
		    reader_addr => reader_addr(I),
		    reader_state => reader_state(I) );

	end generate;

	RDR3 : if I = 3 generate
	begin
	    AXI_DSRC_inst : entity work.axi_dsrc
		generic map (
		    ADDR_MASK => x"00FFFFFF",
		    ADDR_DATA => x"1C000000" )
		port map (
		    m_axi_aclk => s_axi_aclk(3),
		    m_axi_areset_n => s_axi_areset_n(3),
		    enable => reader_enable(I),		-- in, reader
		    reset => reader_reset(I),		-- in, reset
		    --
		    m_axi_ro => s_axi_ri(3),
		    m_axi_ri => s_axi_ro(3),
		    --
		    addr_clk => raddr_clk(I),		-- in
		    addr_enable => raddr_enable(I),	-- in
		    addr_full => raddr_full(I),		-- out
		    addr_in => raddr_in(I),		-- in
		    --
		    data_clk => rdata_clk(I),		-- in
		    data_enable => rdata_enable(I),	-- in
		    data_empty => rdata_empty(I),	-- out
		    data_out => rdata_out(I),		-- out
		    --
		    reader_data => reader_data(I),
		    reader_addr => reader_addr(I),
		    reader_state => reader_state(I) );

	end generate;

	raddr_clk(I) <= addr_gen_clk(I);
	raddr_enable(I) <= not raddr_full(I);

	rdata_clk(I) <= hdmi_clk;
	rdata_enable(I) <= scan_hdata and scan_vdata;

	reader_enable(I) <= not scan_vconf;
	reader_reset(I) <= scan_vc_on;

    end generate;

    s_axi_aclk(1) <= reader_clk;
    s_axi_aclk(3) <= reader_clk;



    --addr_gen_reset(3) <= scan_vconf;

    --------------------------------------------------------------------
    -- LED Status output
    --------------------------------------------------------------------

    led(0) <= hdmi_pll_locked;

    div_reader_inst : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => reader_clk,
	    clk_out => led(1) );

    div_hdmi_inst : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => hdmi_clk,
	    clk_out => led(2) );

    div_data_inst : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => data_clk,
	    clk_out => led(3) );


    led(4) <= rdata_empty(2);
    led(5) <= rdata_enable(2);
    led(6) <= rdata_empty(3);
    led(7) <= rdata_enable(3);


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
	m_axi1_wo, m_axi1_wi, m_axi1_ro, m_axi1_ri )
    begin
	case swi(3 downto 0) is
	    when "0000" =>
		pmod_v0 <= raddr_in(2) & 
			   "0" & addr_gen_enable(2) & "0" & addr_gen_reset(2) & 
			   "0" & raddr_enable(2) & "0" & raddr_full(2) &
			   "000" & rdata_enable(2) & "000" & rdata_empty(2) &
			   rdata_out(2);

		pmod_v1 <= raddr_in(3) &
			   "0" & addr_gen_enable(3) & "0" & addr_gen_reset(3) & 
			   "0" & raddr_enable(3) & "0" & raddr_full(3) &
			   "000" & rdata_enable(3) & "000" & rdata_empty(3) &
			   rdata_out(3);

	    -- when "0001" =>
		-- pmod_v0 <= raddr_in(2);
		-- pmod_v1 <= raddr_in(3);

	    when "0010" =>
		pmod_v0 <= reader_addr(2) & x"000000" & reader_state(2);
		pmod_v1 <= reader_data(2);

	    when "0011" =>
		pmod_v0 <= reader_addr(3) & x"000000" & reader_state(3);
		pmod_v1 <= reader_data(3);

	    when others =>
		pmod_v0 <= (others => '0');
		pmod_v1 <= (others => '0');

	end case;
    end process;

end RTL;
