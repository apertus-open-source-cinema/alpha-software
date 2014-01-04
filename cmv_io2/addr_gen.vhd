----------------------------------------------------------------------------
--  addr_gen.vhd
--	Address Generator
--	Version 1.1
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

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity addr_gen is
    generic (
	ADDR_WIDTH : natural := 32 );
    port (
	clk	: in std_logic;			-- base clock
	reset	: in std_logic;			-- reset
	enable	: in std_logic;			-- enable
	--
	addr_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	addr_max : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
	match	: out std_logic
    );

end entity addr_gen;


architecture RTL of addr_gen is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal pat_c : std_logic_vector (47 downto 0)
	:= (others => '0');
    signal ab_in : std_logic_vector (47 downto 0)
	:= (others => '0');

    alias inc_a : std_logic_vector (29 downto 0)
	is ab_in(47 downto 18);

    alias inc_b : std_logic_vector (17 downto 0)
	is ab_in(17 downto 0);

    signal p_out : std_logic_vector (47 downto 0);

    signal detect : std_logic;
    signal active : std_logic;

begin

    pat_c(addr_max'range) <= addr_max;
    ab_in(addr_inc'range) <= addr_inc;

    DSP48_addr_inst : entity work.dsp48_wrap
	generic map (
	    PREG => 1,				-- Pipeline stages for P (0 or 1)
	    MASK => x"000000000000",		-- 48-bit mask value for pattern detect
	    SEL_PATTERN => "C",			-- Select pattern value ("PATTERN" or "C")
	    USE_PATTERN_DETECT => "PATDET",	-- ("PATDET" or "NO_PATDET")
	    USE_SIMD => "ONE48" )		-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,				-- 1-bit input: Clock input
	    A => inc_a,				-- 30-bit input: A data input
	    B => inc_b,				-- 18-bit input: B data input
	    C => pat_c,				-- 48-bit input: C data input
	    OPMODE => "0100011",		-- 7-bit input: Operation mode input
	    ALUMODE => "0000",			-- 7-bit input: Operation mode input
	    CARRYIN => '0',			-- 1-bit input: Carry input signal
	    CEP => active,			-- 1-bit input: CE input for PREG
	    RSTP => reset,			-- 1-bit input: Reset input for PREG
	    --
	    PATTERNDETECT => detect,		-- Match indicator P[47:0] with pattern
	    P => p_out );			-- 48-bit output: Primary data output

    match <= (not reset) and detect;
    active <= (not reset) and (not detect) and enable;
    addr <= p_out(addr'range);

end RTL;
