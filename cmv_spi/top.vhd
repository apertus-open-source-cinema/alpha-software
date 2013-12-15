----------------------------------------------------------------------------
--  top.vhd (for cmv_spi)
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
--    (cd build.vivado && vivado -mode tcl -source ../vivado.tcl)
--    (cd build.vivado && promgen -w -b -p bin -u 0 cmv_spi.bit -data_width 32)
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3m_pkg.ALL;		-- AXI3 Master
use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity top is
    port (
	clk_100 : in std_logic;			-- input clock to FPGA
	--
	cmv_clk : out std_logic;
	cmv_t_exp1 : out std_logic;
	cmv_t_exp2 : out std_logic;
	cmv_frame_req : out std_logic;
	--
	cmv_lvds_clk_p : out std_logic;
	cmv_lvds_clk_n : out std_logic;
	--
	pmod_jad : out std_logic_vector(3 downto 0);
	pmod_jac : out std_logic_vector(3 downto 0);
	--
	led : out std_logic_vector(7 downto 0);
	--
	spi_en : out std_logic;
	spi_clk : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic
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

    --------------------------------------------------------------------
    -- PLL Signals
    --------------------------------------------------------------------

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;
    signal pll_locked : std_logic;

    signal pll_clk_lvds : std_logic;
    signal pll_clk_cmv : std_logic;
    signal pll_clk_spi : std_logic;

    --------------------------------------------------------------------
    -- Clock Signals
    --------------------------------------------------------------------

    signal cmv_lvds_clk : std_logic;
    signal cmv_spi_clk : std_logic;

    --------------------------------------------------------------------
    -- SPI Signals
    --------------------------------------------------------------------

    signal spi_sig_en : std_logic;
    signal spi_sig_clk : std_logic;
    signal spi_sig_in : std_logic;
    signal spi_sig_out : std_logic;

    signal led_sig : std_logic_vector(7 downto 0);

begin

    --------------------------------------------------------------------
    -- PS7 Interface
    --------------------------------------------------------------------

    ps7_stub_inst : entity work.ps7_stub
	port map (
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

    --------------------------------------------------------------------
    -- PLL
    --------------------------------------------------------------------

    pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT => 12,
	CLKOUT0_DIVIDE => 1200/300,	-- 300MHz LVDS clock
	CLKOUT1_DIVIDE => 1200/30,	--  30MHz CMV clock
	CLKOUT2_DIVIDE => 1200/10,	--  10MHz SPI clock
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => clk_100,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_clk_lvds,
	CLKOUT1 => pll_clk_cmv,
	CLKOUT2 => pll_clk_spi,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    BUFG_inst0 : BUFG
	port map (
	    I => pll_fbout,
	    O => pll_fbin );

    BUFG_inst1 : BUFG
	port map (
	    I => pll_clk_lvds,
	    O => cmv_lvds_clk );

    BUFG_inst2 : BUFG
	port map (
	    I => pll_clk_cmv,
	    O => cmv_clk );

    BUFG_inst3 : BUFG
	port map (
	    I => pll_clk_spi,
	    O => cmv_spi_clk );

    --------------------------------------------------------------------
    -- LVDS Clock
    --------------------------------------------------------------------

    OBUFDS_inst : OBUFDS
	generic map (
	    IOSTANDARD => "LVDS_25",
	    SLEW => "SLOW" )
	port map (
	    O => cmv_lvds_clk_p,
	    OB => cmv_lvds_clk_n,
	    I => cmv_lvds_clk );

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

    m_axi0_aclk <= clk_100;

    --------------------------------------------------------------------
    -- CMV SPI Interface
    --------------------------------------------------------------------

    reg_spi_inst : entity work.reg_spi
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,
	    --
	    s_axi_ro => m_axi0l_ri,
	    s_axi_ri => m_axi0l_ro,
	    s_axi_wo => m_axi0l_wi,
	    s_axi_wi => m_axi0l_wo,
	    --
	    led => led_sig,
	    --
	    spi_clk_in => cmv_spi_clk,
	    --
	    spi_clk => spi_sig_clk,
	    spi_in => spi_sig_in,
	    spi_out => spi_sig_out,
	    spi_en => spi_sig_en );

    cmv_t_exp1 <= '0';
    cmv_t_exp2 <= '0';
    cmv_frame_req <= '0';

    spi_clk <= spi_sig_clk;
    spi_in <= spi_sig_in;
    spi_sig_out <= spi_out;
    spi_en <= spi_sig_en;

    --------------------------------------------------------------------
    -- PMOD Debug
    --------------------------------------------------------------------

    led <= led_sig;

    pmod_jad(0) <= spi_sig_clk;
    pmod_jad(1) <= spi_sig_en;
    pmod_jad(2) <= spi_sig_in;
    pmod_jad(3) <= spi_sig_out;

    pmod_jac(0) <= led_sig(3);
    pmod_jac(1) <= led_sig(7);

    PULLUP_inst0 : PULLUP port map ( O => pmod_jad(0) );
    PULLUP_inst1 : PULLUP port map ( O => pmod_jad(1) );
    PULLUP_inst2 : PULLUP port map ( O => pmod_jad(2) );
    PULLUP_inst3 : PULLUP port map ( O => pmod_jad(3) );

    PULLUP_inst4 : PULLUP port map ( O => pmod_jac(0) );
    PULLUP_inst5 : PULLUP port map ( O => pmod_jac(1) );


end RTL;
