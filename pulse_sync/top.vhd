----------------------------------------------------------------------------
--  top.vhd (for pulse_sync)
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
--  Vivado 2013.3:
--    mkdir -p build.vivado
--    (cd build.vivado && vivado -mode tcl -source ../vivado.tcl)
--    (cd build.vivado && promgen -w -b -p bin -u 0 pulse_sync.bit -data_width 32)
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity top is
    port (
	clk_100 : in std_logic;			-- input clock to FPGA
	--
	btn_c : in std_logic;
	--
	led : out std_logic_vector(1 downto 0)
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    data_sync_inst : entity work.data_sync
	port map (
	    clk => clk_100,
	    async_in => btn_c,
	    sync_out => led(0) );

    reset_sync_inst : entity work.reset_sync
	port map (
	    clk => clk_100,
	    async_in => btn_c,
	    sync_out => led(1) );


end RTL;
