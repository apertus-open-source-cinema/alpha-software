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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

entity lvds_pll is
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_locked : out std_logic;		-- PLL locked
	--
	hdmi_clk : out std_logic;		-- HDMI output clock
	lvds_clk : out std_logic;		-- regenerated clock
	word_clk : out std_logic		-- word clock
    );

end entity lvds_pll;


architecture RTL of lvds_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_hdmi_clk : std_logic;
    signal pll_lvds_clk : std_logic;
    signal pll_word_clk : std_logic;

begin
    mmcm_inst : MMCME2_BASE
    generic map (
	BANDWIDTH => "OPTIMIZED",
	CLKIN1_PERIOD => 6.666,
	CLKFBOUT_MULT_F => 8.0,
	CLKOUT0_DIVIDE_F => 4.00,	-- 150MHz HDMI clock
	CLKOUT1_DIVIDE => 600/300,	-- 300MHz LVDS clock
	CLKOUT2_DIVIDE => 600/50,	--  25MHz WORD clock
	DIVCLK_DIVIDE => 2 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_hdmi_clk,
	CLKOUT1 => pll_lvds_clk,
	CLKOUT2 => pll_word_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_hdmi_inst : BUFG
	port map (
	    I => pll_hdmi_clk,
	    O => hdmi_clk );

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_word_inst : BUFG
	port map (
	    I => pll_word_clk,
	    O => word_clk );

end RTL;
