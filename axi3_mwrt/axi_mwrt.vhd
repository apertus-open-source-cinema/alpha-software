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

    DSP48E1_addr_inst : DSP48E1
	generic map (
	    AREG => 0,				-- Pipeline stages for A (0, 1 or 2)
	    BREG => 0,				-- Pipeline stages for B (0, 1 or 2)
	    CREG => 0,				-- Pipeline stages for C (0 or 1)
	    DREG => 0,				-- Pipeline stages for D (0 or 1)
	    MREG => 1,				-- Pipeline stages for M (0 or 1)
	    PREG => 1,				-- Pipeline stages for P (0 or 1)
	    ACASCREG => 0,			-- Pipeline stages A/ACIN to ACOUT (0, 1 or 2)
	    BCASCREG => 0,			-- Pipeline stages B/BCIN to BCOUT (0, 1 or 2)
	    ADREG => 0, 			-- Pipeline stages for pre-adder (0 or 1)
	    ALUMODEREG => 0,			-- Pipeline stages for ALUMODE (0 or 1)
	    CARRYINREG => 0,			-- Pipeline stages for CARRYIN (0 or 1)
	    CARRYINSELREG => 0,			-- Pipeline stages for CARRYINSEL (0 or 1)
	    INMODEREG => 0,			-- Pipeline stages for INMODE (0 or 1)
	    OPMODEREG => 0,			-- Pipeline stages for OPMODE (0 or 1)
	    --
	    USE_MULT => "NONE",
	    AUTORESET_PATDET => "NO_RESET",	-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
	    MASK => x"000000000000",		-- 48-bit mask value for pattern detect (1=ignore)
	    PATTERN => x"000000000000",		-- 48-bit pattern match for pattern detect
	    SEL_MASK => "MASK",			-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
	    SEL_PATTERN => "PATTERN",		-- Select pattern value ("PATTERN" or "C")
	    USE_PATTERN_DETECT => "NO_PATDET",	-- Enable pattern detect ("PATDET" or "NO_PATDET")
	    USE_SIMD => "ONE48" )		-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => waddr_clk,			-- 1-bit input: Clock input
	    --
	    A => (others => '0'),		-- 30-bit input: A data input
	    B => (others => '0'),		-- 18-bit input: B data input
	    C => x"000000000080",		-- 48-bit input: C data input
	    D => (others => '0'),		-- 25-bit input: D data input
	    --
	    OPMODE => "0001110",		-- 7-bit input: Operation mode input
	    ALUMODE => "0000",			-- 4-bit input: ALU control input
	    INMODE => (others => '0'),		-- 5-bit input: INMODE control input
	    CARRYINSEL => "000",		-- 3-bit input: Carry select input
	    CARRYIN => '0',			-- 1-bit input: Carry input signal
	    --
	    MULTSIGNIN => '0',			-- 1-bit input: Multiplier sign input
	    ACIN => (others => '0'),		-- 30-bit input: A cascade data input
	    BCIN => (others => '0'),		-- 18-bit input: B cascade data input
	    PCIN => (others => '0'),		-- 48-bit input: P cascade input
	    CARRYCASCIN => '0',			-- 1-bit input: Cascade carry input
	    --
	    CEA1 => '0',			-- 1-bit input: CE input for 1st stage AREG
	    CEA2 => '0',			-- 1-bit input: CE input for 2nd stage AREG
	    CEAD => '0',			-- 1-bit input: CE input for ADREG
	    CEALUMODE => '0',			-- 1-bit input: CE input for ALUMODERE
	    CEB1 => '0',			-- 1-bit input: CE input for 1st stage BREG
	    CEB2 => '0',			-- 1-bit input: CE input for 2nd stage BREG
	    CEC => '1',				-- 1-bit input: CE input for CREG
	    CECARRYIN => '0',			-- 1-bit input: CE input for CARRYINREG
	    CECTRL => '0',			-- 1-bit input: CE input for OPMODEREG and CARRYINSELREG
	    CED => '0',				-- 1-bit input: CE input for DREG
	    CEINMODE => '0',			-- 1-bit input: CE input for INMODREG
	    CEM => '0',				-- 1-bit input: CE input for MREG
	    CEP => waddr_enable,		-- 1-bit input: CE input for PREG
	    --
	    RSTA => '0',			-- 1-bit input: Reset input for AREG
	    RSTALLCARRYIN => '0',		-- 1-bit input: Reset input for CARRYINREG
	    RSTALUMODE => '0',			-- 1-bit input: Reset input for ALUMODEREG
	    RSTB => '0',			-- 1-bit input: Reset input for BREG
	    RSTC => '0',			-- 1-bit input: Reset input for CREG
	    RSTCTRL => '0',			-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
	    RSTD => '0',			-- 1-bit input: Reset input for DREG and ADREG
	    RSTINMODE => '0',			-- 1-bit input: Reset input for INMODREG
	    RSTM => '0',			-- 1-bit input: Reset input for MREG
	    RSTP => '0',			-- 1-bit input: Reset input for PREG
	    --
	    P => waddr_dsp );			-- 48-bit output: Primary data output

    waddr_empty <= '0';
    waddr_in <= waddr_dsp(ADDR_WIDTH - 1 downto 0);

    DSP48E1_data_inst : DSP48E1
	generic map (
	    AREG => 0,				-- Pipeline stages for A (0, 1 or 2)
	    BREG => 0,				-- Pipeline stages for B (0, 1 or 2)
	    CREG => 0,				-- Pipeline stages for C (0 or 1)
	    DREG => 0,				-- Pipeline stages for D (0 or 1)
	    MREG => 1,				-- Pipeline stages for M (0 or 1)
	    PREG => 1,				-- Pipeline stages for P (0 or 1)
	    ACASCREG => 0,			-- Pipeline stages A/ACIN to ACOUT (0, 1 or 2)
	    BCASCREG => 0,			-- Pipeline stages B/BCIN to BCOUT (0, 1 or 2)
	    ADREG => 0, 			-- Pipeline stages for pre-adder (0 or 1)
	    ALUMODEREG => 0,			-- Pipeline stages for ALUMODE (0 or 1)
	    CARRYINREG => 0,			-- Pipeline stages for CARRYIN (0 or 1)
	    CARRYINSELREG => 0,			-- Pipeline stages for CARRYINSEL (0 or 1)
	    INMODEREG => 0,			-- Pipeline stages for INMODE (0 or 1)
	    OPMODEREG => 0,			-- Pipeline stages for OPMODE (0 or 1)
	    --
	    USE_MULT => "NONE",
	    AUTORESET_PATDET => "NO_RESET",	-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
	    MASK => x"000000000000",		-- 48-bit mask value for pattern detect (1=ignore)
	    PATTERN => x"000000000000",		-- 48-bit pattern match for pattern detect
	    SEL_MASK => "MASK",			-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
	    SEL_PATTERN => "PATTERN",		-- Select pattern value ("PATTERN" or "C")
	    USE_PATTERN_DETECT => "NO_PATDET",	-- Enable pattern detect ("PATDET" or "NO_PATDET")
	    USE_SIMD => "FOUR12" )		-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => wdata_clk,			-- 1-bit input: Clock input
	    --
	    A => (others => '0'),		-- 30-bit input: A data input
	    B => (others => '0'),		-- 18-bit input: B data input
	    C => x"004004004004",		-- 48-bit input: C data input
	    D => (others => '0'),		-- 25-bit input: D data input
	    --
	    OPMODE => "0001110",		-- 7-bit input: Operation mode input
	    ALUMODE => "0000",			-- 4-bit input: ALU control input
	    INMODE => (others => '0'),		-- 5-bit input: INMODE control input
	    CARRYINSEL => "000",		-- 3-bit input: Carry select input
	    CARRYIN => '0',			-- 1-bit input: Carry input signal
	    --
	    MULTSIGNIN => '0',			-- 1-bit input: Multiplier sign input
	    ACIN => (others => '0'),		-- 30-bit input: A cascade data input
	    BCIN => (others => '0'),		-- 18-bit input: B cascade data input
	    PCIN => x"003002001000",		-- 48-bit input: P cascade input
	    CARRYCASCIN => '0',			-- 1-bit input: Cascade carry input
	    --
	    CEA1 => '0',			-- 1-bit input: CE input for 1st stage AREG
	    CEA2 => '0',			-- 1-bit input: CE input for 2nd stage AREG
	    CEAD => '0',			-- 1-bit input: CE input for ADREG
	    CEALUMODE => '0',			-- 1-bit input: CE input for ALUMODERE
	    CEB1 => '0',			-- 1-bit input: CE input for 1st stage BREG
	    CEB2 => '0',			-- 1-bit input: CE input for 2nd stage BREG
	    CEC => '0',				-- 1-bit input: CE input for CREG
	    CECARRYIN => '0',			-- 1-bit input: CE input for CARRYINREG
	    CECTRL => '0',			-- 1-bit input: CE input for OPMODEREG and CARRYINSELREG
	    CED => '0',				-- 1-bit input: CE input for DREG
	    CEINMODE => '0',			-- 1-bit input: CE input for INMODREG
	    CEM => '0',				-- 1-bit input: CE input for MREG
	    CEP => wdata_enable,		-- 1-bit input: CE input for PREG
	    --
	    RSTA => '0',			-- 1-bit input: Reset input for AREG
	    RSTALLCARRYIN => '0',		-- 1-bit input: Reset input for CARRYINREG
	    RSTALUMODE => '0',			-- 1-bit input: Reset input for ALUMODEREG
	    RSTB => '0',			-- 1-bit input: Reset input for BREG
	    RSTC => '0',			-- 1-bit input: Reset input for CREG
	    RSTCTRL => '0',			-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
	    RSTD => '0',			-- 1-bit input: Reset input for DREG and ADREG
	    RSTINMODE => '0',			-- 1-bit input: Reset input for INMODREG
	    RSTM => '0',			-- 1-bit input: Reset input for MREG
	    RSTP => '0',			-- 1-bit input: Reset input for PREG
	    --
	    P => wdata_dsp );			-- 48-bit output: Primary data output

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
