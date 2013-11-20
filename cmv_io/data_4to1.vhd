----------------------------------------------------------------------------
--  data_4to1.vhd
--	Data Collector
--	Version 1.0
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

entity data_4to1 is
    generic (
	DI_WIDTH : natural := 16;
	DI_BLOCK : natural := 16;
	DO_WIDTH : natural := 64
    );
    port (
	clk : in std_logic;
	rst : in std_logic;
	--
	data_in0 : in std_logic_vector(DI_WIDTH - 1 downto 0);
	data_in1 : in std_logic_vector(DI_WIDTH - 1 downto 0);
	data_in2 : in std_logic_vector(DI_WIDTH - 1 downto 0);
	data_in3 : in std_logic_vector(DI_WIDTH - 1 downto 0);
	--
	push_in : in std_logic_vector(3 downto 0);
	--
	data_out : out std_logic_vector(DO_WIDTH - 1 downto 0);
	push_out : out std_logic
    );

end entity data_4to1;


architecture RTL of data_4to1 is
begin

    combine_proc : process(rst, clk, push_in)

	constant ones_c : std_logic_vector(push_in'range)
	    := (others => '1');

	variable valid_v : std_logic_vector(push_in'range)
	    := (others => '0');

	variable data_v : std_logic_vector(data_out'range)
	    := (others => '0');

	variable push_v : std_logic := '0';
	variable pos_v : natural;

    begin

	if rising_edge(clk) then
	    if push_in(0) = '1' then
		pos_v := 0 * DI_BLOCK;
		data_v(pos_v + DI_WIDTH - 1 downto pos_v) := data_in0;
		valid_v(0) := '1';
	    end if;

	    if push_in(1) = '1' then
		pos_v := 1 * DI_BLOCK;
		data_v(pos_v + DI_WIDTH - 1 downto pos_v) := data_in1;
		valid_v(1) := '1';
	    end if;

	    if push_in(2) = '1' then
		pos_v := 2 * DI_BLOCK;
		data_v(pos_v + DI_WIDTH - 1 downto pos_v) := data_in2;
		valid_v(2) := '1';
	    end if;

	    if push_in(3) = '1' then
		pos_v := 3 * DI_BLOCK;
		data_v(pos_v + DI_WIDTH - 1 downto pos_v) := data_in3;
		valid_v(3) := '1';
	    end if;

	    if rst = '1' then
		push_v := '0';
		valid_v := (others => '0');

	    elsif valid_v = ones_c then
		push_v := '1';
		valid_v := (others => '0');

	    else
		push_v := '0';
	    end if;
	end if;

	if falling_edge(clk) then
	    push_out <= push_v;
	end if;

	data_out <= data_v;

    end process;

end RTL;
