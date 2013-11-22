----------------------------------------------------------------------------
--  synchronizer.vhd
--	Synchronizer
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--  Based on a design by Leonardo Capossio
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity synchronizer is
    generic (
	ACTIVE_IN : std_logic := '1';
	ACTIVE_OUT : std_logic := '1';
	OFF_DELAY : natural := 1
    );
    port (
	clk      : in std_logic;		-- Target Clock
	async_in : in std_logic;		-- Async Input
	--
	sync_out : out std_logic		-- Sync Output
    );
end entity synchronizer;


architecture RTL of synchronizer is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal shift : std_logic_vector(OFF_DELAY downto 0);

    attribute REGISTER_BALANCING : string;
    attribute REGISTER_BALANCING of shift: signal is "NO";

    attribute REGISTER_DUPLICATION : string;
    attribute REGISTER_DUPLICATION of shift: signal is "NO";

begin

    async_proc : process(clk, async_in)
    begin

	if async_in = ACTIVE_IN then
	    shift <= (others => ACTIVE_OUT);

	elsif rising_edge(clk) then
	    shift <= shift(OFF_DELAY - 1 downto 0)
		& (not ACTIVE_OUT);

	end if;

    end process;

    sync_out <= shift(OFF_DELAY);

end RTL;
