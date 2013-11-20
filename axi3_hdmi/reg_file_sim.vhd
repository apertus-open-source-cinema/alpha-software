----------------------------------------------------------------------------
--  reg_file_sim.vhd
--	AXI Lite Register File (Simulation)
--	Version 1.1
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package reg_array_pkg is
    type reg_array is array (natural range <>) of
	std_logic_vector(31 downto 0);
end reg_array_pkg;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

use work.axi3ml_pkg.all;	-- AXI3 Lite Master
use work.reg_array_pkg.ALL;


entity reg_file is
    generic (
	REG_MASK : unsigned (31 downto 0) := x"000000F";
	OREG_SIZE : natural := 8;
	IREG_SIZE : natural := 8
    );
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	oreg : out reg_array(0 to OREG_SIZE - 1);
	ireg : in reg_array(0 to IREG_SIZE - 1)
    );
end entity reg_file;


architecture RTL of reg_file is
begin

    oreg <= (
	std_logic_vector(to_unsigned(  64, 32)),	-- 2480
	std_logic_vector(to_unsigned(  32, 32)),	-- 1170
	std_logic_vector(to_unsigned(   8, 32)),	--  280
	std_logic_vector(to_unsigned(  40, 32)),	-- 2200
	std_logic_vector(to_unsigned(   8, 32)),	--   45
	std_logic_vector(to_unsigned(  24, 32)),	-- 1125
	std_logic_vector(to_unsigned(   0, 32)),	-- 2400
	std_logic_vector(to_unsigned(   4, 32)),	-- 2460

	std_logic_vector(to_unsigned(   0, 32)),	-- 1160
	std_logic_vector(to_unsigned(   2, 32)),	-- 1165
	std_logic_vector(to_unsigned(   4, 32)),	--    5
	std_logic_vector(to_unsigned(   6, 32)),	--    6
	std_logic_vector(to_unsigned(   8, 32)),	--  512
	std_logic_vector(to_unsigned(  40, 32)),	-- 1536
	std_logic_vector(to_unsigned(   8, 32)),	--  256
	std_logic_vector(to_unsigned(  24, 32)) );	--  768

	
end RTL;





















