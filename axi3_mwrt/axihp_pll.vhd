----------------------------------------------------------------------------
--  axihp_pll.vhd
--	AXIHP PLL
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

entity axihp_pll is
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_clk : out std_logic_vector(3 downto 0);	-- PLL clocks
	pll_locked : out std_logic			-- PLL locked
    );

end entity axihp_pll;


architecture RTL of axihp_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lock : std_logic;

    signal pll_clk_out : std_logic_vector(pll_clk'range);

begin
    axihp_pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT => 12,
	CLKOUT0_DIVIDE => 1200/200,	-- AXIHP clock
	CLKOUT1_DIVIDE => 1200/200,	-- AXIHP clock
	CLKOUT2_DIVIDE => 1200/200,	-- AXIHP clock
	CLKOUT3_DIVIDE => 1200/200,	-- AXIHP clock
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,

	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_clk_out(0),
	CLKOUT1 => pll_clk_out(1),
	CLKOUT2 => pll_clk_out(2),
	CLKOUT3 => pll_clk_out(3),

	LOCKED => pll_lock,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    GEN_BUFGCE : for N in pll_clk'range generate
	BUFGCE_inst : BUFGCE
	    port map (
		I => pll_clk_out(N),
		CE => pll_lock,
		O => pll_clk(N) );
    end generate;

    pll_locked <= pll_lock;

end RTL;
