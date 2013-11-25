----------------------------------------------------------------------------
--  dsp48_cnt.vhd
--	DSP48E1 Based Counter
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

entity dsp48_cnt is
    port (
	clk : in std_logic;				-- input clock
	enable : in std_logic;				-- enable count
	--
	value : out std_logic_vector(47 downto 0)	-- Counter Value
    );

end entity dsp48_cnt;


architecture RTL of axihp_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_clk_out : std_logic_vector(pll_clk'range);

begin
    axihp_pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT => 10,
	CLKOUT0_DIVIDE => 1000/250,	-- AXIHP clock
	CLKOUT1_DIVIDE => 1000/250,	-- AXIHP clock
	CLKOUT2_DIVIDE => 1000/250,	-- AXIHP clock
	CLKOUT3_DIVIDE => 1000/250,	-- AXIHP clock
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_clk_out(0),
	CLKOUT1 => pll_clk_out(1),
	CLKOUT2 => pll_clk_out(2),
	CLKOUT3 => pll_clk_out(3),

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    GEN_BUFG : for N in pll_clk'range generate
	BUFG_inst : BUFG
	    port map (
		I => pll_clk_out(N),
		O => pll_clk(N) );
    end generate;

end RTL;
