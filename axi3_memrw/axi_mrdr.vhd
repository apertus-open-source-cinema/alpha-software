----------------------------------------------------------------------------
--  axi_mrdr.vhd
--	AXI Based Memory Reader (Test)
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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.axi3s_pkg.ALL;		-- AXI3 Slave Interface
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity axi_mrdr is
    generic (
	ADDR_MASK : std_logic_vector(31 downto 0) := x"00FFFFFF";
	ADDR_BASE : std_logic_vector(31 downto 0) := x"1B000000";
	DATA_MASK : std_logic_vector(63 downto 0) := x"0FFF0FFF0FFF0FFF";
	DATA_MARK : std_logic_vector(63 downto 0) := x"B000B000B000B000" );
   port (
	m_axi_aclk	: in std_logic;
	m_axi_areset_n	: in std_logic;
	enable		: in std_logic;
	inactive	: out std_logic;
	--
	m_axi_ro	: out axi3s_read_in_r;
	m_axi_ri	: in axi3s_read_out_r;
	--
	data_cnt	: out std_logic_vector(47 downto 0);
	ecnt_data	: out std_logic_vector(23 downto 0);
	ecnt_resp	: out std_logic_vector(23 downto 0)
    );

end entity axi_mrdr;


architecture RTL of axi_mrdr is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";
    -- attribute DONT_TOUCH of RTL : architecture is "TRUE";


    constant DATA_WIDTH : natural := 64;

    signal rdata_clk : std_logic;
    signal rdata_enable : std_logic;
    signal rdata_out : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal rdata_full : std_logic;

    signal rdata_dsp : std_logic_vector (47 downto 0);
    signal rdata_chk : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal rdata_match : std_logic;

    constant ADDR_WIDTH : natural := 32;

    signal raddr_clk : std_logic;
    signal raddr_enable : std_logic;
    signal raddr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal raddr_empty : std_logic;

    signal raddr_dsp : std_logic_vector (47 downto 0);

    signal reader_error : std_logic;
    signal reader_state : std_logic_vector(7 downto 0);

    signal stat_err_c : std_logic_vector (47 downto 0);
    signal stat_err_dsp : std_logic_vector (47 downto 0);
    signal stat_err_data : std_logic;

begin

    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    DSP48_addr_inst : entity work.dsp48_wrap
	generic map (
	    MREG => 1,			-- Pipeline stages for M (0 or 1)
	    PREG => 1 )			-- Pipeline stages for P (0 or 1)
	port map (
	    CLK => raddr_clk,		-- 1-bit input: Clock input
	    --
	    C => x"000000000080",	-- 48-bit input: C data input
	    --
	    OPMODE => "0001110",	-- 7-bit input: Operation mode
	    CEP => raddr_enable,	-- 1-bit input: CE input for PREG
	    --
	    P => raddr_dsp );		-- 48-bit output: Primary data out

    raddr_empty <= '0';
    raddr_in <= raddr_dsp(ADDR_WIDTH - 1 downto 0);

    --------------------------------------------------------------------
    -- Data Generator
    --------------------------------------------------------------------

    DSP48_data_inst : entity work.dsp48_wrap
	generic map (
	    MREG => 1,			-- Pipeline stages for M (0 or 1)
	    PREG => 1,			-- Pipeline stages for P (0 or 1)
	    USE_SIMD => "FOUR12" )	-- SIMD Selection
	port map (
	    CLK => rdata_clk,		-- 1-bit input: Clock input
	    --
	    C => x"004004004004",	-- 48-bit input: C data input
	    --
	    OPMODE => "0001110",	-- 7-bit input: Operation mode
	    CEP => rdata_enable,	-- 1-bit input: CE input for PREG
	    --
	    P => rdata_dsp );		-- 48-bit output: Primary data out

    rdata_full <= '0';
    rdata_chk <= (( x"0" & rdata_dsp(47 downto 36) &
		    x"0" & rdata_dsp(35 downto 24) &
		    x"0" & rdata_dsp(23 downto 12) &
		    x"0" & rdata_dsp(11 downto 0) )
		and DATA_MASK) or DATA_MARK;

    --------------------------------------------------------------------
    -- AXIHP Reader
    --------------------------------------------------------------------

    axihp_reader_inst : entity work.axihp_reader
	generic map (
	    DATA_WIDTH => 64,
	    DATA_COUNT => 16,
	    ADDR_MASK => ADDR_MASK,
	    ADDR_DATA => ADDR_BASE )
	port map (
	    m_axi_aclk => m_axi_aclk,		-- in
	    m_axi_areset_n => m_axi_areset_n,	-- in
	    enable => enable,			-- in
	    inactive => inactive,		-- out
	    --
	    m_axi_ro => m_axi_ro,
	    m_axi_ri => m_axi_ri,
	    --
	    data_clk => rdata_clk,		-- out
	    data_enable => rdata_enable,	-- out
	    data_out => rdata_out,		-- out
	    data_full => rdata_full,		-- in
	    --
	    addr_clk => raddr_clk,		-- out
	    addr_enable => raddr_enable,	-- out
	    addr_in => raddr_in,		-- in
	    addr_empty => raddr_empty,		-- in
	    --
	    reader_error => reader_error,
	    reader_state => reader_state );

    --------------------------------------------------------------------
    -- Statistics
    --------------------------------------------------------------------

    DSP48_error_inst : entity work.dsp48_wrap
	generic map (
	    PREG => 1,			-- Pipeline stages for P (0 or 1)
	    USE_SIMD => "TWO24" )	-- SIMD selection
	port map (
	    CLK => m_axi_aclk,		-- 1-bit input: Clock input
	    --
	    C => stat_err_c,		-- 48-bit input: C data input
	    --
	    OPMODE => "0110010",	-- 7-bit input: Operation mode
	    CEP => enable,		-- 1-bit input: CE input for PREG
	    --
	    P => stat_err_dsp );	-- 48-bit output: Primary data out

    stat_err_c <= ( 24 => stat_err_data,
		     0 => reader_error,
		     others => '0');

    ecnt_data <= stat_err_dsp(47 downto 24);
    ecnt_resp <= stat_err_dsp(23 downto 0);

    DSP48_comp_inst0 : entity work.dsp48_wrap
	generic map (
	    MASK => x"000000000000",	-- 48-bit mask value
	    USE_PATTERN_DETECT => "PATDET" )
	port map (
	    CLK => m_axi_aclk,		-- 1-bit input: Clock input
	    --
	    A => rdata_chk(47 downto 18),
	    B => rdata_chk(17 downto 0),
	    C => rdata_out(47 downto 0),
	    --
	    OPMODE => "0110011",	-- 7-bit input: Operation mode
	    ALUMODE => "0100",		-- 4-bit input: ALU contol input
	    --
	    PATTERNDETECT => rdata_match );

    stat_err_data <= '1' when
	rdata_enable = '1' and rdata_match = '0' else '0';

    DSP48_count_inst : entity work.dsp48_wrap
	generic map (
	    PREG => 1 )			-- Pipeline stages for P (0 or 1)
	port map (
	    CLK => m_axi_aclk,		-- 1-bit input: Clock input
	    --
	    OPMODE => "0110010",	-- 7-bit input: Operation mode
	    CARRYIN => rdata_enable,	-- 1-bit input: Carry input signal
	    CEP => enable,		-- 1-bit input: CE input for PREG
	    --
	    P => data_cnt );		-- 48-bit output: Primary data out

end RTL;
