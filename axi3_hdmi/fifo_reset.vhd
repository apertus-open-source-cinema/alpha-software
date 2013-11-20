----------------------------------------------------------------------------
--  fifo_reset.vhd
--	FIFO Reset Manager
--	Version 1.2
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

begin

    reset_proc : process(clk, reset)

	variable shift_v : std_logic_vector(11 downto 0) :=
	    (others => '0');

    begin

	if reset = '1' then
	    shift_v := (others => '0');

	elsif rising_edge(clk) then
	    shift_v := shift_v(shift_v'high - 1 downto 0) & '1';

	end if;

	fifo_rdy <= shift_v(shift_v'high);
	fifo_rst <= shift_v(1) xor shift_v(7);

    end process;

end RTL;
