----------------------------------------------------------------------------
--  addr_gen.vhd
--	Address Generator
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


entity addr_gen is
    generic (
	ADDR_WIDTH : natural := 32 );
    port (
	clk	: in std_logic;			-- base clock
	reset	: in std_logic;			-- reset
	enable	: in std_logic;			-- enable
	auto	: in std_logic;			-- loop
	--
	addr_min : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
	addr_inc : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
	addr_max : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector(ADDR_WIDTH - 1 downto 0)
    );

end entity addr_gen;

architecture RTL of addr_gen is
begin

    addr_proc: process(clk, addr_min)

	variable addr_v : unsigned(addr'range)
	    := unsigned(addr_min);

    begin

	if rising_edge(clk) then

	    if reset = '1' then				-- reset
		addr_v := unsigned(addr_min);

	    elsif enable = '1' then			-- enabled
		if addr_v = unsigned(addr_max) then	-- last?
		    if auto = '1' then			-- loop
			addr_v := unsigned(addr_min);
		    end if;
		else
		    addr_v := addr_v + unsigned(addr_inc);
		end if;
	
	    else
		null;

	    end if;

	addr <= std_logic_vector(addr_v);

	end if;

    end process;

end RTL;
