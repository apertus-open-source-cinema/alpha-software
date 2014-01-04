----------------------------------------------------------------------------
--  fifo_chop.vhd
--	FIFO Data Serializer
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.fifo_pkg.ALL;		-- FIFO Functions
use work.par_array_pkg.ALL;	-- Parallel Data


entity fifo_chop is
    port (
	par_clk		: in  std_logic;
	par_enable	: in  std_logic;
	par_data	: in  par12_a (31 downto 0);
	--
	par_ctrl	: in  std_logic_vector (11 downto 0);
	--
	fifo_clk	: out std_logic;
	fifo_enable	: out std_logic;
	fifo_data	: out std_logic_vector (63 downto 0);
	--
	fifo_ctrl	: out std_logic_vector (11 downto 0)
    );

end entity fifo_chop;


architecture RTL of fifo_chop is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    fifo_proc : process (par_clk)
	variable shift_v : std_logic_vector (32 * 12 - 1 downto 0);
	variable shift_cnt_v : std_logic_vector (6 downto 0)
	    := (0 => '0', others => '1');
	variable ctrl_v : std_logic_vector (11 downto 0);
    begin
	if rising_edge(par_clk) then
	    if par_enable = '1' then
		for I in 31 downto 0 loop
		    shift_v(I*12 + 11 downto I*12) := par_data(I);
		    -- shift_v(I*12 + 11 downto I*12 + 4) :=
			-- std_logic_vector(to_unsigned(I, 8));
		end loop;
		shift_cnt_v := (0 => '0', others => '1');
		ctrl_v := par_ctrl;
	    else
		for I in 0 to 4 loop
		    if shift_cnt_v(0) = '1' then
			shift_v(I * 64 + 63 downto I * 64) :=
			    shift_v((I + 1) * 64 + 63 downto (I + 1) * 64);
		    end if;
		end loop;
		shift_cnt_v := '0' &
		    shift_cnt_v(shift_cnt_v'high downto 1);
	    end if;
	end if;

	fifo_data <= shift_v(63 downto 0);
	fifo_enable <= shift_cnt_v(0);
	fifo_ctrl <= ctrl_v;
    end process;

    fifo_clk <= par_clk;

end RTL;
