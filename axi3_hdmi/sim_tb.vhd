----------------------------------------------------------------------------
--  sim_tb.vhd (for axi3_hdmi)
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

    --------------------------------------------------------------------
    -- Debug Signals
    --------------------------------------------------------------------

    signal pmod_jcm : std_logic_vector(3 downto 0);
    signal pmod_jca : std_logic_vector(3 downto 0);

    signal pmod_jdm : std_logic_vector(3 downto 0);
    signal pmod_jda : std_logic_vector(3 downto 0);

    --------------------------------------------------------------------
    -- IIC Signals
    --------------------------------------------------------------------

    signal cmv_sda : std_ulogic;
    signal cmv_scl : std_ulogic;

    signal hd_sda : std_ulogic;
    signal hd_scl : std_ulogic;

    --------------------------------------------------------------------
    -- SPI Signals
    --------------------------------------------------------------------

    signal spi_en : std_ulogic;
    signal spi_clk : std_ulogic;
    signal spi_in : std_ulogic;
    signal spi_out : std_ulogic;

    --------------------------------------------------------------------
    -- HDMI Signals
    --------------------------------------------------------------------

    signal hd_data  : std_logic_vector(15 downto 0);
    signal hd_hsync : std_logic;
    signal hd_vsync : std_logic;
    signal hd_de    : std_logic;
    signal hd_clk   : std_logic;

    attribute DONT_TOUCH of hd_data : signal is "TRUE";
    attribute DONT_TOUCH of hd_hsync : signal is "TRUE";
    attribute DONT_TOUCH of hd_vsync : signal is "TRUE";
    attribute DONT_TOUCH of hd_de : signal is "TRUE";
    attribute DONT_TOUCH of hd_clk : signal is "TRUE";

    --------------------------------------------------------------------
    -- IO Signals
    --------------------------------------------------------------------

    signal swi : std_logic_vector(7 downto 0);
    signal led : std_logic_vector(7 downto 0);

begin

    uut_inst : entity work.top
	port map (
	    clk_100 => clk_100,
	    --
	    cmv_sda => cmv_sda,
	    cmv_scl => cmv_scl,
	    --
	    spi_en => spi_en,
	    spi_clk => spi_clk,
	    spi_in => spi_in,
	    spi_out => spi_out,
	    --
	    hd_data => hd_data,
	    hd_hsync => hd_hsync,
	    hd_vsync => hd_vsync,
	    hd_de => hd_de,
	    hd_clk => hd_clk,
	    --
	    hd_sda => hd_sda,
	    hd_scl => hd_scl,
	    --
	    pmod_jcm => pmod_jcm,
	    pmod_jca => pmod_jca,
	    --
	    pmod_jdm => pmod_jdm,
	    pmod_jda => pmod_jda,
	    --
	    swi => swi,
	    led => led );


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


    swi_proc : process
    begin
	swi <= "00000000";
	wait;
    end process;

end RTL;
