----------------------------------------------------------------------------
--  scan_gen.vhd
--	Scan Generator
--	Version 1.1
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity scan_check is
    port (
	clk	  : in std_logic;			-- Scan CLK
	reset_n	  : in std_logic;			-- Reset
	--
	counter	  : in std_logic_vector(11 downto 0);	-- Counter
	cval_on	  : in std_logic_vector(11 downto 0);	-- On Match
	cval_off  : in std_logic_vector(11 downto 0);	-- Off Match
	--
	match_on  : out std_logic;
	match_off : out std_logic;
	match	  : out std_logic
    );
end entity scan_check;


architecture RTL of scan_check is
begin
    check_proc : process(clk, reset_n, counter)

	variable cval_on_v : std_logic_vector(11 downto 0)
	    := (others => '0');
	variable cval_off_v : std_logic_vector(11 downto 0)
	    := (others => '0');

	variable match_on_v : std_logic := '0';
	variable match_off_v : std_logic := '0';
	variable match_v : std_logic := '0';

    begin

	if reset_n = '0' then
	    cval_on_v := cval_on;
	    cval_off_v := cval_off;

	    match_v := '0';
	    match_on_v := '0';
	    match_off_v := '0';

	elsif rising_edge(clk) then
	    if counter = cval_on_v then
		match_on_v := '1';
		match_off_v := '0';
		match_v := '1';

	    elsif counter = cval_off_v then
		match_on_v := '0';
		match_off_v := '1';
		match_v := '0';

	    else
		match_on_v := '0';
		match_off_v := '0';

	    end if;
	end if;

	match <= match_v;
	match_on <= match_on_v;
	match_off <= match_off_v;

    end process;

end RTL;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity scan_gen is
    port (
	clk	: in std_logic;				-- Data CLK
	reset_n : in std_logic;				-- Reset
	--
	total_w : in std_logic_vector(11 downto 0);	-- Total Width
	total_h : in std_logic_vector(11 downto 0);	-- Total Heigt
	--
	hcnt	: out std_logic_vector(11 downto 0);	-- Column
	vcnt	: out std_logic_vector(11 downto 0)	-- Row
    );
end entity scan_gen;


architecture RTL of scan_gen is
begin
    scan_proc : process(clk, reset_n, total_w, total_h)

	variable total_w_v : unsigned(11 downto 0);
	variable total_h_v : unsigned(11 downto 0);

	variable hcnt_v : unsigned(11 downto 0)
	    := (others => '0');
	variable vcnt_v : unsigned(11 downto 0)
	    := (others => '0');

    begin

	if reset_n = '0' then
	    total_w_v := unsigned(total_w);
	    total_h_v := unsigned(total_h);

	    hcnt_v := (others => '0');
	    vcnt_v := (others => '0');

	elsif rising_edge(clk) then
	    -- traverse total area
	    if hcnt_v = total_w_v then
		hcnt_v := (others => '0');

		if vcnt_v = total_h_v then
		    vcnt_v := (others => '0');
		else
		    vcnt_v := vcnt_v + 1;
		end if;
	    else
		hcnt_v := hcnt_v + 1;
	    end if;
	end if;

	hcnt <= std_logic_vector(hcnt_v);
	vcnt <= std_logic_vector(vcnt_v);

    end process;

end RTL;
