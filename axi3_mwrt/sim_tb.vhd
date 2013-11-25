----------------------------------------------------------------------------
--  sim_tb.vhd (for axi3_mwrt)
--	Simulation Testbench
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
--  Vivado 2013.3:
--    mkdir -p sim.vivado
--    (cd sim.vivado && xelab --debug all testbench -prj ../sim.prj)
--    (cd sim.vivado && xsim -gui work.testbench)
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity testbench is
end entity testbench;


architecture RTL of testbench is

    attribute DONT_TOUCH : string;

    signal clk_100 : std_logic;

begin

    uut_inst : entity work.top
	port map (
	    clk_100 => clk_100 );


    --------------------------------------------------------------------
    -- Testbench
    --------------------------------------------------------------------


    clk_100_proc : process
    begin
	clk_100 <= '1';
	wait for 5ns;
	clk_100 <= '0';
	wait for 5ns;
    end process;

end RTL;
