----------------------------------------------------------------------------
--  sim_tb.vhd (for ping_pong)
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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;


entity testbench is
end entity testbench;


architecture RTL of testbench is

    attribute DONT_TOUCH : string;

    signal clk_in : std_logic;

    signal spi_clk_in : std_logic;

    signal spi_action : std_logic;
    signal spi_active : std_logic;

    signal spi_write : std_logic;
    signal spi_addr : std_logic_vector(6 downto 0);
    signal spi_din : std_logic_vector(15 downto 0);

    signal spi_dout : std_logic_vector(15 downto 0);

    signal spi_clk : std_logic;
    signal spi_en : std_logic;
    signal spi_in : std_logic;
    signal spi_out : std_logic;

begin

    BUFG_inst : BUFG
	port map (
	    I => clk_in,
	    O => spi_clk_in );

    uut : entity work.cmv_spi(RTL)
	port map (
	    spi_clk_in => spi_clk_in,
	    --
	    spi_action => spi_action,
	    spi_active => spi_active,
	    --
	    spi_write => spi_write,
	    spi_addr => spi_addr,
	    spi_din => spi_din,
	    --
	    spi_dout => spi_dout,
	    --
	    spi_clk => spi_clk,
	    spi_en => spi_en,
	    spi_in => spi_in,
	    spi_out => spi_out );


    --------------------------------------------------------------------
    -- Testbench
    --------------------------------------------------------------------


    clk_proc : process
    begin
	clk_in <= '1';
	wait for 50ns;
	clk_in <= '0';
	wait for 50ns;
    end process;

    rw_proc : process
    begin
	spi_write <= '0';
	spi_addr <= "0000000";
	spi_din <= x"0000";
	spi_action <= '0';
	spi_out <= '0';
	wait for 1000ns;

	spi_write <= '1';
	spi_addr <= "1010101";
	spi_din <= x"1357";

	spi_action <= '1';
	wait for 100ns;
	spi_action <= '0';
	wait for 2900ns;

	spi_write <= '0';
	spi_addr <= "1010101";
	spi_din <= x"1357";

	spi_action <= '1';
	wait for 100ns;
	spi_action <= '0';
	wait for 1050ns;

	spi_out <= '1';
	wait for 100ns;
	spi_out <= '0';
	wait for 200ns;
	spi_out <= '1';
	wait for 200ns;
	spi_out <= '0';
	wait for 100ns;
	spi_out <= '1';
	wait for 100ns;
	spi_out <= '0';
	wait for 100ns;
	spi_out <= '1';
	wait for 100ns;
	spi_out <= '0';
	wait for 100ns;
	spi_out <= '1';
	wait for 300ns;
	spi_out <= '0';

	wait;
    end process;

end RTL;
