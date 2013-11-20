----------------------------------------------------------------------------
--  lvds_pll.vhd
--	Axiom Alpha LVDS related PLLs
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

entity lvds_pll is
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_clk : out std_logic_vector(5 downto 0);	-- PLL clocks
	pll_locked : out std_logic;			-- PLL locked
	--
	lvds_clk_in : in std_logic;		-- lvds base clock
	--
	lvds_clk : out std_logic_vector(5 downto 0);	-- MMCM clocks
	lvds_locked : out std_logic			-- MMCM locked
    );

end entity lvds_pll;


architecture RTL of lvds_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_clk_out : std_logic_vector(pll_clk'range);

    signal mmcm_fbout : std_logic;
    signal mmcm_fbin : std_logic;

    signal mmcm_clk_out : std_logic_vector(lvds_clk'range);

begin
    lvds_pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT => 12,
	CLKOUT0_DIVIDE => 1200/300,	-- 300MHz LVDS clock
	CLKOUT1_DIVIDE => 1200/240,	-- 240MHz LVDS clock
	CLKOUT2_DIVIDE => 1200/200,	-- 200MHz LVDS clock
	CLKOUT3_DIVIDE => 1200/150,	-- 150MHz LVDS clock
	CLKOUT4_DIVIDE => 1200/30,	--  30MHz Clock
	CLKOUT5_DIVIDE => 1200/10,	--  10MHz Clock
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_clk_out(0),
	CLKOUT1 => pll_clk_out(1),
	CLKOUT2 => pll_clk_out(2),
	CLKOUT3 => pll_clk_out(3),
	CLKOUT4 => pll_clk_out(4),
	CLKOUT5 => pll_clk_out(5),

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    GEN_BUF0 : for N in 0 to pll_clk'high generate
	BUFG_inst : BUFG
	    port map (
		I => pll_clk_out(N),
		O => pll_clk(N) );
    end generate;


    lvds_mmcm_inst : MMCME2_BASE
    generic map (
	BANDWIDTH => "OPTIMIZED",
	CLKIN1_PERIOD => 6.666,
	CLKFBOUT_MULT_F => 8.0,
	CLKOUT0_DIVIDE_F => 60.00,	--  10MHz PMOD
	CLKOUT1_DIVIDE => 1200/600,	-- 300MHz LVDS
	CLKOUT2_DIVIDE => 1200/300,	-- 150MHz LVDS
	CLKOUT3_DIVIDE => 1200/150,	--  75MHz LVDS
	CLKOUT4_DIVIDE => 1200/100,	--  50MHz LVDS
	CLKOUT5_DIVIDE => 1200/60,	--  30MHz LVDS
	DIVCLK_DIVIDE => 2 )
    port map (
	CLKIN1 => lvds_clk_in,
	CLKFBOUT => mmcm_fbout,
	CLKFBIN => mmcm_fbin,

	CLKOUT0 => mmcm_clk_out(5),
	CLKOUT1 => mmcm_clk_out(0),
	CLKOUT2 => mmcm_clk_out(1),
	CLKOUT3 => mmcm_clk_out(2),
	CLKOUT4 => mmcm_clk_out(3),
	CLKOUT5 => mmcm_clk_out(4),

	LOCKED => lvds_locked,
	PWRDWN => '0',
	RST => '0' );

    BUFG_inst : BUFG
	port map (
	    I => mmcm_fbout,
	    O => mmcm_fbin );

    GEN_BUF1 : for N in 0 to lvds_clk'high generate
	BUFG_inst : BUFG
	    port map (
		I => mmcm_clk_out(N),
		O => lvds_clk(N) );
    end generate;

end RTL;
