----------------------------------------------------------------------------
--  scan_hdmi.vhd
--	Scan Generator for HDMI
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity scan_hdmi is
    port (
	clk	: in std_logic;				-- Scan CLK
	reset_n	: in std_logic;				-- # Reset
	--
	total_w : in std_logic_vector(11 downto 0);	-- Total Width
	total_h : in std_logic_vector(11 downto 0);	-- Total Heigt
	--
	hdisp_s : in std_logic_vector(11 downto 0);
	hdisp_e : in std_logic_vector(11 downto 0);
	vdisp_s : in std_logic_vector(11 downto 0);
	vdisp_e : in std_logic_vector(11 downto 0);
	--
	hsync_s : in std_logic_vector(11 downto 0);
	hsync_e : in std_logic_vector(11 downto 0);
	vsync_s : in std_logic_vector(11 downto 0);
	vsync_e : in std_logic_vector(11 downto 0);
	--
	hdata_s : in std_logic_vector(11 downto 0);
	hdata_e : in std_logic_vector(11 downto 0);
	vdata_s : in std_logic_vector(11 downto 0);
	vdata_e : in std_logic_vector(11 downto 0);
	--
	vconf_r : in std_logic_vector(11 downto 0);
	vconf_a : in std_logic_vector(11 downto 0);
	vconf_b : in std_logic_vector(11 downto 0);
	vconf_c : in std_logic_vector(11 downto 0);
	--
	hdisp	: out std_logic;
	vdisp	: out std_logic;
	disp	: out std_logic;
	--
	hsync	: out std_logic;
	vsync	: out std_logic;
	--
	hdata	: out std_logic;
	vdata	: out std_logic;
	data	: out std_logic;
	even	: out std_logic;
	--
	vconf	: out std_logic;
	vc_ev_a : out std_logic;
	vc_ev_b : out std_logic;
	vc_ev_c : out std_logic
    );
end entity scan_hdmi;


architecture RTL of scan_hdmi is

    signal scan_clk : std_logic;
    signal scan_reset_n : std_logic;

    signal scan_hcnt : std_logic_vector(11 downto 0);
    signal scan_vcnt : std_logic_vector(11 downto 0);

    signal scan_hdisp : std_logic;
    signal scan_vdisp : std_logic;
    signal scan_disp : std_logic;

    signal scan_hsync : std_logic;
    signal scan_vsync : std_logic;

    signal scan_hdata : std_logic;
    signal scan_vdata : std_logic;
    signal scan_data : std_logic;

    signal scan_vconf : std_logic;

begin

    --------------------------------------------------------------------
    -- Scan Generator
    --------------------------------------------------------------------

    scan_gen_inst : entity work.scan_gen
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    total_w => total_w,
	    total_h => total_h,
	    --
	    hcnt => scan_hcnt,
	    vcnt => scan_vcnt );

    sync_inst : entity work.synchronizer
	generic map (
	    ACTIVE_IN => '0',
	    ACTIVE_OUT => '0' )
	port map (
	    clk => scan_clk,
	    async_in => reset_n,
	    sync_out => scan_reset_n );

    scan_clk <= clk;

    --------------------------------------------------------------------
    -- Scan Checks
    --------------------------------------------------------------------

    scan_hdisp_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_hcnt,
	    cval_on => hdisp_s,
	    cval_off => hdisp_e,
	    --
	    match => scan_hdisp );

    scan_vdisp_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => vdisp_s,
	    cval_off => vdisp_e,
	    --
	    match => scan_vdisp );

    scan_hsync_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_hcnt,
	    cval_on => hsync_s,
	    cval_off => hsync_e,
	    --
	    match => scan_hsync );

    scan_vsync_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => vsync_s,
	    cval_off => vsync_e,
	    --
	    match => scan_vsync );

    scan_hdata_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_hcnt,
	    cval_on => hdata_s,
	    cval_off => hdata_e,
	    --
	    match => scan_hdata );

    scan_vdata_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => vdata_s,
	    cval_off => vdata_e,
	    --
	    match => scan_vdata );

    scan_vconf_inst : entity work.scan_check
	port map (
	    clk => scan_clk,
	    reset_n => scan_reset_n,
	    --
	    counter => scan_vcnt,
	    cval_on => vconf_r,
	    cval_off => vconf_r,
	    --
	    match_on => scan_vconf );

    scan_proc : process (clk, reset_n)
    begin
	if reset_n = '0' then
	    hdisp <= '0';
	    vdisp <= '0';
	    disp <= '0';
	
	    hsync <= '0';
	    vsync <= '0';
	
	    hdata <= '0';
	    vdata <= '0';
	    data <= '0';
	    even <= '0';
	
	    vconf <= '0';
	    vc_ev_a <= '0';
	    vc_ev_b <= '0';
	    vc_ev_c <= '0';

	elsif rising_edge(clk) then
	    hdisp <= scan_hdisp;
	    vdisp <= scan_vdisp;
	    disp <= scan_hdisp and scan_vdisp;

	    hsync <= scan_hsync;
	    vsync <= scan_vsync;

	    hdata <= scan_hdata;
	    vdata <= scan_vdata;
	    data <= scan_hdata and scan_vdata;

	    even <= not scan_hcnt(0);

	    vconf <= scan_vconf;

	    if scan_vconf = '1' then
		if scan_hcnt = vconf_a then
		    vc_ev_a <= '1';
		else
		    vc_ev_a <= '0';
		end if;

		if scan_hcnt = vconf_b then
		    vc_ev_b <= '1';
		else
		    vc_ev_b <= '0';
		end if;

		if scan_hcnt = vconf_c then
		    vc_ev_c <= '1';
		else
		    vc_ev_c <= '0';
		end if;
	    end if;
	end if;
    end process;

end RTL;
