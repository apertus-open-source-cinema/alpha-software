----------------------------------------------------------------------------
--  cmv_serdes.vhd
--	LVDS Serial Deserializer
--	Version 1.1
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library unisim;
use unisim.vcomponents.ALL;



entity cmv_serdes is
    port (
	serdes_clk	: in  std_logic;
	serdes_clkdiv	: in  std_logic;
	serdes_toggle	: in  std_logic;
	serdes_rst	: in  std_logic;
	--
	data_ser	: in  std_logic;
	data_par	: out std_logic_vector (11 downto 0);
	data_push	: out std_logic;
	--
	pattern		: in  std_logic_vector (11 downto 0);
	match		: out std_logic;
	mismatch	: out std_logic;
	--
	bitslip		: in  std_logic
    );

end entity cmv_serdes;


architecture RTL of cmv_serdes is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal bitslip_occ : std_logic := '0';

    signal data : std_logic_vector(5 downto 0);
    signal data_out : std_logic_vector(11 downto 0);

begin

    ISERDES_master_inst : ISERDESE2
	generic map (
	    DATA_RATE		=> "SDR",
	    DATA_WIDTH		=> 6,
	    INTERFACE_TYPE	=> "NETWORKING",
	    IOBDELAY		=> "BOTH",
	    OFB_USED		=> "FALSE",
	    SERDES_MODE		=> "MASTER",
	    IS_CLK_INVERTED	=> '0',
	    IS_CLKB_INVERTED	=> '1',
	    IS_CLKDIV_INVERTED	=> '0',
	    IS_CLKDIVP_INVERTED	=> '1',
	    NUM_CE		=> 1 )
	port map (
	    Q1		=> data(5),
	    Q2		=> data(4),
	    Q3		=> data(3),
	    Q4		=> data(2),
	    Q5		=> data(1),
	    Q6		=> data(0),
	    BITSLIP	=> bitslip_occ,
	    CE1		=> '1',
	    CE2		=> '1',
	    CLK		=> serdes_clk,
	    CLKB	=> serdes_clk,
	    CLKDIV	=> serdes_clkdiv,
	    CLKDIVP	=> serdes_clkdiv,
	    D		=> '0',
	    DDLY	=> data_ser,
	    DYNCLKDIVSEL => '0',
	    DYNCLKSEL	=> '0',
	    OCLK	=> '0',
	    OCLKB	=> '0',
	    OFB		=> '0',
	    RST		=> serdes_rst,
	    SHIFTIN1	=> '0',
	    SHIFTIN2	=> '0' );

    -- match <= '0';
    -- mismatch <= '0';
    -- data_par(11 downto 6) <= (others => '0');

    switch_proc : process (serdes_clkdiv, serdes_toggle)
    begin
	if rising_edge(serdes_clkdiv) then
	    if serdes_toggle = '1' then
		data_out(5 downto 0) <= data;
	    else
		data_out(11 downto 6) <= data;
	    end if;
	end if;
    end process;

    push_proc : process (serdes_clk, serdes_toggle)
	variable toggle_v : std_logic := '0';
    begin
	if rising_edge(serdes_clk) then
	    if toggle_v = '1' and
		serdes_toggle = '0' then
		data_par <= data_out;
		data_push <= '1';
	    else
		data_push <= '0';
	    end if;

	    toggle_v := serdes_toggle;
	end if;
    end process;

    bitslip_proc : process (serdes_clkdiv, bitslip)
	variable shift_v : std_logic_vector(1 downto 0) := "10";
    begin
	if bitslip = '1' then
	    shift_v := "10";
	else
	    if rising_edge(serdes_clkdiv) then
		shift_v := '0' & shift_v(1);
		bitslip_occ <= shift_v(0);
	    end if;
	end if;
    end process;

    match_proc : process (serdes_clkdiv, pattern)
	variable shift_v : std_logic_vector(7 downto 0);
    begin
	if rising_edge(serdes_clkdiv) then
	    if pattern = data_out then
		shift_v := '1' & shift_v(shift_v'high downto 1);
	    else
		shift_v := '0' & shift_v(shift_v'high downto 1);
	    end if;
	end if;
	
	if shift_v = x"FF" then
	    match <= '1';
	else
	    match <= '0';
	end if;
	
	if shift_v = x"00" then
	    mismatch <= '1';
	else
	    mismatch <= '0';
	end if;
    end process;

end RTL;
