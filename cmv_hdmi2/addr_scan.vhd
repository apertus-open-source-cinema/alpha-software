----------------------------------------------------------------------------
--  addr_scan.vhd
--	Scan Address Generator
--	Version 1.4
--
--  Copyright (C) 2013-2014 H.Poetzl
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


entity addr_scan is
    generic (
	COUNT_WIDTH : natural := 12;
	ADDR_WIDTH : natural := 32 );
    port (
	clk	: in std_logic;			-- base clock
	reset	: in std_logic;			-- reset
	enable	: in std_logic;			-- enable
	--
	evenodd : in std_logic;
	--
	addr_min : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	addr_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	addr_max : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	col_cnt : in std_logic_vector (COUNT_WIDTH - 1 downto 0);
	row_add : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	row_cnt : in std_logic_vector (COUNT_WIDTH - 1 downto 0);
	frm_add : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
	match	: out std_logic
    );

end entity addr_scan;

architecture RTL of addr_scan is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal ccnt : unsigned(col_cnt'range);
    signal rcnt : unsigned(row_cnt'range);

    signal pat_c : std_logic_vector (47 downto 0)
	:= (others => '0');
    signal ab_in : std_logic_vector (47 downto 0)
	:= (others => '0');

    alias inc_a : std_logic_vector (29 downto 0)
	is ab_in(47 downto 18);

    alias inc_b : std_logic_vector (17 downto 0)
	is ab_in(17 downto 0);

    signal opmode : std_logic_vector (6 downto 0);

    signal p_out : std_logic_vector (47 downto 0);

    signal detect : std_logic;
    signal active : std_logic;
    signal load : std_logic := '1';

    signal do_row : boolean := false;
    signal do_frm : boolean := false;

begin

    addr_proc: process (clk)
    begin
	if reset = '1' then				-- reset
	    ccnt <= (0 => '1', others => '0');
	    rcnt <= (0 => '0', others => '0');

	    do_row <= false;
	    do_frm <= false;
	    load <= '1';

	elsif rising_edge(clk) then
	    if enable = '1' then			-- enabled
		if ccnt = unsigned(col_cnt) then
		    ccnt <= (0 => '0', others => '0');

		    if rcnt = unsigned(row_cnt) then
			rcnt <= (0 => '0', others => '0');
			do_row <= false;
			do_frm <= true;

		    else
			rcnt <= rcnt + "1";
			do_row <= true;
			do_frm <= false;

		    end if;

		else
		    ccnt <= ccnt + "1";
		    do_row <= false;
		    do_frm <= false;

		end if;
	    end if;

	    load <= '0';
	end if;
    end process;

    pat_c(addr_max'range) <= addr_min
	when (evenodd xor load) = '0'
	else addr_max;

    ab_in(addr_inc'range) <=
	frm_add when do_frm else
	row_add when do_row else
	addr_inc;

    opmode <= "0100011" when load = '0' else "0110000";

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
	    OPMODE => opmode,			-- 7-bit input: Operation mode input
	    ALUMODE => "0000",			-- 7-bit input: Operation mode input
	    CARRYIN => '0',			-- 1-bit input: Carry input signal
	    CEP => active,			-- 1-bit input: CE input for PREG
	    RSTP => reset,			-- 1-bit input: Reset input for PREG
	    --
	    PATTERNDETECT => detect,		-- Match indicator P[47:0] with pattern
	    P => p_out );			-- 48-bit output: Primary data output

    match <= (not reset) and detect;
    active <= (not reset) and (not detect) and (enable or load);
    addr <= p_out(addr'range);

end RTL;
