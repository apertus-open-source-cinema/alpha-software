----------------------------------------------------------------------------
--  sim_tb.vhd (for fifo_test)
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

library unisim;
use unisim.VCOMPONENTS.all;

library unimacro;
use unimacro.VCOMPONENTS.all;


entity testbench is
end entity testbench;


architecture RTL of testbench is

    attribute DONT_TOUCH : string;

    signal clk_a_in : std_logic;
    signal clk_b_in : std_logic;

    signal clk_a : std_logic;
    signal clk_b : std_logic;

    signal pulse_in : std_logic;
    signal pulse_out : std_logic_vector(1 to 2);

    attribute DONT_TOUCH of pulse_in : signal is "YES";
    attribute DONT_TOUCH of pulse_out : signal is "YES";

begin

    BUFG_inst0 : BUFG
	port map (
	    I => clk_a_in,
	    O => clk_a );

    BUFG_inst1 : BUFG
	port map (
	    I => clk_b_in,
	    O => clk_b );


    data_sync_inst : entity work.data_sync
	port map (
	    clk => clk_b,
	    async_in => pulse_in,
	    sync_out => pulse_out(1) );

    reset_sync_inst : entity work.reset_sync
	port map (
	    clk => clk_b,
	    async_in => pulse_in,
	    sync_out => pulse_out(2) );


    --------------------------------------------------------------------
    -- Testbench
    --------------------------------------------------------------------


    clk_a_proc : process
    begin
	clk_a_in <= '1';
	wait for 7ns;
	clk_a_in <= '0';
	wait for 7ns;
    end process;

    clk_b_proc : process
    begin
	clk_b_in <= '1';
	wait for 57ns;
	clk_b_in <= '0';
	wait for 57ns;
    end process;



    pulse_proc : process(clk_a)
	variable count_v : natural := 0;
    begin

	if rising_edge(clk_a) then
	    if count_v = 0 then
		pulse_in <= '0';
	    elsif count_v > 20  and count_v < 25 then
		pulse_in <= '1';
	    elsif count_v = 100 then
		pulse_in <= '1';
	    else
		pulse_in <= '0';
	    end if;

	    count_v := count_v + 1;
	end if;
    end process;


end RTL;
