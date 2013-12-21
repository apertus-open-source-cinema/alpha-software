----------------------------------------------------------------------------
--  cmv_top_tb.vhd
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
--    (cd sim.vivado; xelab --debug all testbench -prj ../sim_cmv_top.prj)
--    (cd sim.vivado; xsim -gui work.testbench)
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity testbench is
end entity testbench;


architecture RTL of testbench is

    signal clk_100 : std_logic;

    --------------------------------------------------------------------
    -- IIC Signals
    --------------------------------------------------------------------

    signal i2c0_sda : std_ulogic;
    signal i2c0_scl : std_ulogic;

    signal i2c1_sda : std_ulogic;
    signal i2c1_scl : std_ulogic;

    --------------------------------------------------------------------
    -- SPI Signals
    --------------------------------------------------------------------

    signal spi_en : std_ulogic;
    signal spi_clk : std_ulogic;
    signal spi_in : std_ulogic;
    signal spi_out : std_ulogic;

    --------------------------------------------------------------------
    -- CMV Signals
    --------------------------------------------------------------------

    signal cmv_clk : std_ulogic;
    signal cmv_t_exp1 : std_ulogic;
    signal cmv_t_exp2 : std_ulogic;
    signal cmv_frame_req : std_ulogic;

    signal cmv_lvds_clk_p : std_logic;
    signal cmv_lvds_clk_n : std_logic;

    signal cmv_lvds_outclk_p : std_logic;
    signal cmv_lvds_outclk_n : std_logic;

    signal cmv_lvds_data_p : unsigned(31 downto 0);
    signal cmv_lvds_data_n : unsigned(31 downto 0);

    signal cmv_lvds_ctrl_p : std_logic;
    signal cmv_lvds_ctrl_n : std_logic;

    --------------------------------------------------------------------
    -- Debug Signals
    --------------------------------------------------------------------

    signal pmod_jcm : std_logic_vector(3 downto 0);
    signal pmod_jca : std_logic_vector(3 downto 0);

    signal pmod_jdm : std_logic_vector(3 downto 0);
    signal pmod_jda : std_logic_vector(3 downto 0);

    --------------------------------------------------------------------
    -- IO Signals
    --------------------------------------------------------------------

    signal btn_c : std_logic;	-- Button: '1' is pressed
    signal btn_l : std_logic;	-- Button: '1' is pressed
    signal btn_r : std_logic;	-- Button: '1' is pressed
    signal btn_u : std_logic;	-- Button: '1' is pressed
    signal btn_d : std_logic;	-- Button: '1' is pressed

    signal swi : std_logic_vector(7 downto 0);
    signal led : std_logic_vector(7 downto 0);

begin

    uut_inst : entity work.top
	port map (
	    clk_100 => clk_100,
	    --
	    i2c0_sda => i2c0_sda,
	    i2c0_scl => i2c0_scl,
	    --
	    i2c1_sda => i2c1_sda,
	    i2c1_scl => i2c1_scl,
	    --
	    spi_en => spi_en,
	    spi_clk => spi_clk,
	    spi_in => spi_in,
	    spi_out => spi_out,
	    --
	    cmv_clk => cmv_clk,
	    cmv_t_exp1 => cmv_t_exp1,
	    cmv_t_exp2 => cmv_t_exp2,
	    cmv_frame_req => cmv_frame_req,
	    --
	    cmv_lvds_clk_p => cmv_lvds_clk_p,
	    cmv_lvds_clk_n => cmv_lvds_clk_n,
	    --
	    cmv_lvds_outclk_p => cmv_lvds_outclk_p,
	    cmv_lvds_outclk_n => cmv_lvds_outclk_n,
	    --
	    cmv_lvds_data_p => cmv_lvds_data_p,
	    cmv_lvds_data_n => cmv_lvds_data_n,
	    --
	    cmv_lvds_ctrl_p => cmv_lvds_ctrl_p,
	    cmv_lvds_ctrl_n => cmv_lvds_ctrl_n,
	    --
	    pmod_jcm => pmod_jcm,
	    pmod_jca => pmod_jca,
	    --
	    pmod_jdm => pmod_jdm,
	    pmod_jda => pmod_jda,
	    --
	    btn_c => btn_c,
	    btn_l => btn_l,
	    btn_r => btn_r,
	    btn_u => btn_u,
	    btn_d => btn_d,
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


    lvds_outclk_proc : process (cmv_lvds_clk_p)
	variable outclk_v : std_logic := '0';
    begin
	if rising_edge(cmv_lvds_clk_p) then
	    outclk_v :=  not outclk_v;
	end if;

	cmv_lvds_outclk_p <= outclk_v;
	cmv_lvds_outclk_n <= not outclk_v;
    end process;


    lvds_data_proc : process (cmv_lvds_clk_p)
	variable count_v : unsigned (31 downto 0) := x"00000000";
    begin
	if rising_edge(cmv_lvds_clk_p) then
	    count_v := count_v - "1";
	end if;

	cmv_lvds_data_p <= count_v;
	cmv_lvds_data_n <= not count_v;
    end process;

    lvds_ctrl_proc : process (cmv_lvds_clk_p)
	variable count_v : unsigned (31 downto 0) := x"00000000";
    begin
	if rising_edge(cmv_lvds_clk_p) then
	    count_v := count_v + "1";
	end if;

	cmv_lvds_ctrl_p <= count_v(0);
	cmv_lvds_ctrl_n <= not count_v(0);
    end process;

    btn_c <= '0';
    btn_l <= '0';
    btn_r <= '0';
    btn_u <= '0';
    btn_d <= '0';

    swi <= (others => '0');
end RTL;
