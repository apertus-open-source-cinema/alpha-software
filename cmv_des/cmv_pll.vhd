----------------------------------------------------------------------------
--  cmv_pll.vhd
--	Axiom Alpha CMV PLL
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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

entity cmv_pll is
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_locked : out std_logic;		-- PLL locked
	--
	lvds_clk : out std_logic;		-- lvds base clock
	dly_clk : out std_logic;		-- delay ref clock
	cmv_clk : out std_logic;		-- cmv base clock
	spi_clk : out std_logic			-- spi base clock
    );

end entity cmv_pll;


architecture RTL of cmv_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_dly_clk : std_logic;
    signal pll_cmv_clk : std_logic;
    signal pll_spi_clk : std_logic;

begin
    pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT => 12,
	CLKOUT0_DIVIDE => 1200/300,	-- 300MHz CMV LVDS clock
	CLKOUT1_DIVIDE => 1200/200,	-- 200MHz delay ref clock
	CLKOUT2_DIVIDE => 1200/30,	--  30MHz CMV input clock
	CLKOUT3_DIVIDE => 1200/10,	--  10MHz CMV SPI clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	CLKOUT2_PHASE => 0.0,
	CLKOUT3_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,
	--
	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_dly_clk,
	CLKOUT2 => pll_cmv_clk,
	CLKOUT3 => pll_spi_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_dly_inst : BUFG
	port map (
	    I => pll_dly_clk,
	    O => dly_clk );

    BUFG_cmv_inst : BUFG
	port map (
	    I => pll_cmv_clk,
	    O => cmv_clk );

    BUFG_spi_inst : BUFG
	port map (
	    I => pll_spi_clk,
	    O => spi_clk );

end RTL;
