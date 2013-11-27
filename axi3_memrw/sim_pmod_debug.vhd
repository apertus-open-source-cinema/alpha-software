----------------------------------------------------------------------------
--  sim_pmod_debug.vhd
--	PMOD Debug Interface (Simulation)
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

entity pmod_debug is
    generic (
	PRESCALE : natural := 5
    );
    port (
	clk	: in std_logic;				-- base clock
	--
	value	: in std_logic_vector(63 downto 0);	-- '1' on '0' off
	--
	jxm	: out std_logic_vector(3 downto 0);	-- mask '0' = on
	jxa	: out std_logic_vector(3 downto 0)	-- address (inv)
    );

end entity pmod_debug;

architecture RTL of pmod_debug is
begin
	jxm <= (others => '0');
	jxa <= (others => '0');

end RTL;
