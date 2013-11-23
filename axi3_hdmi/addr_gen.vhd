----------------------------------------------------------------------------
--  addr_gen.vhd
--	Address Generator
--	Version 1.2
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
	ADDR_WIDTH : natural := 32;
	ADDR_INIT : unsigned := x"0" );
    port (
	clk	: in std_logic;			-- base clock
	reset	: in std_logic;			-- reset
	enable	: in std_logic;			-- enable
	--
	addr_min : in unsigned(ADDR_WIDTH - 1 downto 0);
	addr_inc : in unsigned(ADDR_WIDTH - 1 downto 0);
	addr_cnt : in unsigned(ADDR_WIDTH - 1 downto 0);
	addr_add : in unsigned(ADDR_WIDTH - 1 downto 0);
	addr_max : in unsigned(ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector(ADDR_WIDTH - 1 downto 0)
    );

end entity addr_gen;

architecture RTL of addr_gen is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal addr_next : unsigned(addr'range);
    signal acnt : unsigned(addr'range);

begin

    addr_proc: process (clk, addr_min)

    begin

	if reset = '1' then				-- reset
	    addr <= std_logic_vector(addr_min);
	    addr_next <= addr_min;
	    acnt <= (others => '0');

	elsif rising_edge(clk) then
	    if enable = '1' then			-- enabled
		addr <= std_logic_vector(addr_next);

		if addr_next = addr_max then		-- last?
		    null;
		elsif acnt = addr_cnt then
		    acnt <= (others => '0');
		    addr_next <= addr_next + addr_add;
		else
		    acnt <= acnt + "1";
		    addr_next <= addr_next + addr_inc;
		end if;

	    else
		null;

	    end if;

	end if;

    end process;

end RTL;
