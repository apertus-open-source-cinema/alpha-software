----------------------------------------------------------------------------
--  pmod_debug.vhd
--	ZedBoard simple VHDL example
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

entity pmod_encode is
    generic (
	PRESCALE : natural := 6;
	DATA_WIDTH : natural := 256
    );
    port (
	clk	: in std_logic;				-- base clock
	--
	value	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
	--
	jxc	: out std_logic_vector(3 downto 0);	-- control
	jxd	: out std_logic_vector(3 downto 0)	-- data
    );

end entity pmod_encode;

architecture RTL of pmod_encode is

    signal blk_clk : std_logic;

begin

    async_div_inst : entity work.async_div
	generic map (STAGES => PRESCALE)
	port map (clk_in => clk, clk_out => blk_clk);

    pmod_enc: process(blk_clk, value)

	constant blocks_c : natural := DATA_WIDTH / 4;

	variable snap_v	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	variable grey_v : unsigned(2 downto 0) := "100";

	variable cycle_v : natural range 0 to blocks_c;
	variable count_v : unsigned(3 downto 0) := x"0";
	variable sync_v : std_logic;

    begin
	if rising_edge(blk_clk) then
	    if cycle_v = blocks_c then
		sync_v := '1';
		snap_v := value;
		jxd <= std_logic_vector(count_v);
		count_v := count_v + "1";
		cycle_v := 0;
	    else
		sync_v := '0';
		jxd <= snap_v(cycle_v * 4 + 3 downto cycle_v * 4);
		cycle_v := cycle_v + 1;
	    end if;
	end if;


	if falling_edge(blk_clk) then
	    case grey_v is
		when "000" => grey_v := "001";
		when "001" => grey_v := "011";
		when "011" => grey_v := "010";
		when "010" => grey_v := "110";
		when "110" => grey_v := "111";
		when "111" => grey_v := "101";
		when "101" => grey_v := "100";
		when "100" => grey_v := "000";
	    end case;
	end if;

	jxc <= sync_v & std_logic_vector(grey_v);

    end process;

end RTL;
