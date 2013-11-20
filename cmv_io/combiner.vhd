----------------------------------------------------------------------------
--  combiner.vhd
--	Data Combiner (has to wait for VHDL 2008+)
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

entity combiner is
    generic (
	DI_WIDTH : natural := 16;
	DI_BLOCK : natural := 16;
	DI_COUNT : natural := 4;
	DO_WIDTH : natural := 64
    );
    port (
	clk : in std_logic;
	rst : in std_logic;
	--
	data_in : in data_in_t(DI_COUNT - 1 downto 0);
	push_in : in std_logic_vector(DI_COUNT - 1 downto 0);
	--
	data_out : out std_logic_vector(DO_WIDTH - 1 downto 0);
	push_out : out std_logic
    );

end entity combiner;


architecture RTL of combiner is
begin

    combine_proc : process(rst, clk, push_in)

	constant ones_c : std_logic_vector(data_in'range)
	    := (others => '1');

	variable data_v : std_logic_vector(data_out'range)
	    := (others => '0');

	variable valid_v : std_logic_vector(data_in'range);
	variable push_v : std_logic := '0';

    begin
	for I in data_in'range loop
	    constant pos_c : natural := I * DI_BLOCK;
	begin
	    if rising_edge(push_in(I)) then
	    	data_v(pos_c + DI_WIDTH - 1 downto pos_c) := data_in(I);
	    	valid_v(I) := '1';
	    end if;
	end loop;

	if rising_edge(clk) then
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

	data_out <= data_v;
	push_out <= push_v;

    end process;

end RTL;
