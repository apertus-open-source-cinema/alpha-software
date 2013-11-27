----------------------------------------------------------------------------
--  axi_mwrt.vhd
--	AXI Based Memory Writer (Test)
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


entity axi_mwrt is
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
	m_axi_wo	: out axi3s_write_in_r;
	m_axi_wi	: in axi3s_write_out_r
    );

end entity axi_mwrt;


architecture RTL of axi_mwrt is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";
    -- attribute DONT_TOUCH of RTL : architecture is "TRUE";


    constant DATA_WIDTH : natural := 64;

    signal wdata_clk : std_logic;
    signal wdata_enable : std_logic;
    signal wdata_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal wdata_empty : std_logic;

    signal wdata_dsp : std_logic_vector (47 downto 0);

    constant ADDR_WIDTH : natural := 32;

    signal waddr_clk : std_logic;
    signal waddr_enable : std_logic;
    signal waddr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal waddr_empty : std_logic;

    signal waddr_dsp : std_logic_vector (47 downto 0);

    signal writer_state : std_logic_vector(7 downto 0);

begin

    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    DSP48_addr_inst : entity work.dsp48_wrap
	generic map (
	    MREG => 1,			-- Pipeline stages for M (0 or 1)
	    PREG => 1 )			-- Pipeline stages for P (0 or 1)
	port map (
	    CLK => waddr_clk,		-- 1-bit input: Clock input
	    --
	    C => x"000000000080",	-- 48-bit input: C data input
	    --
	    OPMODE => "0001110",	-- 7-bit input: Operation mode
	    CEP => waddr_enable,	-- 1-bit input: CE input for PREG
	    --
	    P => waddr_dsp );		-- 48-bit output: Primary data out

    waddr_empty <= '0';
    waddr_in <= waddr_dsp(ADDR_WIDTH - 1 downto 0);

    --------------------------------------------------------------------
    -- Data Generator
    --------------------------------------------------------------------

    DSP48_data_inst : entity work.dsp48_wrap
	generic map (
	    MREG => 1,			-- Pipeline stages for M (0 or 1)
	    PREG => 1,			-- Pipeline stages for P (0 or 1)
	    USE_SIMD => "FOUR12" )	-- SIMD Selection
	port map (
	    CLK => wdata_clk,		-- 1-bit input: Clock input
	    --
	    C => x"004004004004",	-- 48-bit input: C data input
	    --
	    OPMODE => "0001110",	-- 7-bit input: Operation mode
	    CEP => wdata_enable,	-- 1-bit input: CE input for PREG
	    --
	    P => wdata_dsp );		-- 48-bit output: Primary data out

    wdata_empty <= '0';
    wdata_in <= (( x"0" & wdata_dsp(47 downto 36) &
		   x"0" & wdata_dsp(35 downto 24) &
		   x"0" & wdata_dsp(23 downto 12) &
		   x"0" & wdata_dsp(11 downto 0) )
		and DATA_MASK) or DATA_MARK;

    --------------------------------------------------------------------
    -- AXIHP Writer
    --------------------------------------------------------------------

    axihp_writer_inst : entity work.axihp_writer
	generic map (
	    DATA_WIDTH => 64,
	    DATA_COUNT => 16,
	    ADDR_MASK => ADDR_MASK,
	    ADDR_DATA => ADDR_BASE )
	port map (
	    m_axi_aclk => m_axi_aclk,
	    m_axi_areset_n => m_axi_areset_n,
	    enable => enable,
	    inactive => inactive,
	    --
	    m_axi_wo => m_axi_wo,
	    m_axi_wi => m_axi_wi,
	    --
	    data_clk => wdata_clk,		-- out
	    data_enable => wdata_enable,	-- out
	    data_in => wdata_in,		-- in
	    data_empty => wdata_empty,		-- in
	    --
	    addr_clk => waddr_clk,		-- out
	    addr_enable => waddr_enable,	-- out
	    addr_in => waddr_in,		-- in
	    addr_empty => waddr_empty,		-- in
	    --
	    writer_state => writer_state );

end RTL;
