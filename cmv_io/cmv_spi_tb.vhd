----------------------------------------------------------------------------
--  cmv_spi_tb.vhd
--	ZedBoard simple VHDL example
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
--  Vivado 2013.2:
--    mkdir -p sim.vivado
--    (cd sim.vivado; xelab --debug all testbench -prj ../sim_cmv_spi.prj)
--    (cd sim.vivado; xsim -gui work.testbench)
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity testbench is
end entity testbench;


architecture RTL of testbench is

    signal spi_clk_in : std_logic;

    signal spi_write : std_logic;
    signal spi_addr : std_logic_vector(6 downto 0);
    signal spi_din : std_logic_vector(15 downto 0);
    signal spi_go : std_logic;

    signal spi_active : std_logic;
    signal spi_dout : std_logic_vector(15 downto 0);

    signal spi_clk : std_logic;
    signal spi_en : std_logic;
    signal spi_in : std_logic;
    signal spi_out : std_logic;

begin

    uut : entity work.cmv_spi
    port map (
	spi_clk_in => spi_clk_in,

	spi_write => spi_write,
	spi_addr => spi_addr,
	spi_din => spi_din,
	spi_go => spi_go,

	spi_active => spi_active,
	spi_dout => spi_dout,

	spi_clk => spi_clk,
	spi_en => spi_en,
	spi_in => spi_in,
	spi_out => spi_out );


    spi_clk_proc : process
    begin
	spi_clk_in <= '1';
	wait for 5ns;
	spi_clk_in <= '0';
	wait for 5ns;
    end process;

    rw_proc : process
    begin
	spi_write <= '0';
	spi_addr <= "0000000";
	spi_din <= "0000000000000000";
	spi_go <= '0';

	wait for 100ns;

	spi_write <= '1';
	spi_addr <= "1010101";
	spi_din <= "1111000011110000";
	spi_go <= '1';

	wait for 300ns;
	spi_go <= '0';

	wait for 100ns;

	spi_write <= '0';
	spi_addr <= "0101010";
	spi_din <= "1111000011110000";
	spi_go <= '1';

	spi_out <= '1';
	wait for 100ns;

	spi_out <= '0';
	wait for 100ns;

	spi_out <= '1';
	wait for 100ns;

	wait for 300ns;
	spi_go <= '0';

	wait;
    end process;

end RTL;
