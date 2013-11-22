----------------------------------------------------------------------------
--  fifo_reset.vhd
--	FIFO Reset Manager
--	Version 1.3
--
--  Copyright (C) 2013 H.Poetzl
--  Based on a suggestion by L.M. Capossio 
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity fifo_reset is
    port (
	clk	: in std_logic;
	reset	: in std_logic;
	--
	fifo_rst : out std_logic;
	fifo_rdy : out std_logic );

end entity fifo_reset;


architecture RTL of fifo_reset is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal shift : std_logic_vector(11 downto 0);

begin

    reset_proc : process(clk, reset)
    begin

	if reset = '1' then
	    shift <= (others => '0');

	elsif rising_edge(clk) then
	    shift <= shift(shift'high - 1 downto 0) & '1';

	end if;

	fifo_rdy <= shift(shift'high);
	fifo_rst <= shift(1) xor shift(7);

    end process;

end RTL;
