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

entity pmod_debug is
    generic (
	PRESCALE : natural := 5
    );
    port (
	clk	: in std_logic;				-- base clock
	--
	value	: in std_logic_vector(63 downto 0);	-- '1' on '0' off
	--
	jxm	: out std_logic_vector(3 downto 0);	-- mask '0' = on
	jxa	: out std_logic_vector(3 downto 0)	-- address (inv)
    );

end entity pmod_debug;

architecture RTL of pmod_debug is

    signal vis_clk : std_logic;

    signal vis_addr : unsigned(3 downto 0);

begin

    async_div_inst : entity work.async_div
	generic map (STAGES => PRESCALE)
	port map (clk_in => clk, clk_out => vis_clk);

    pmod_vis: process(vis_clk, vis_addr, value)

	variable vis_cnt_v : unsigned(7 downto 0);

	variable index_v : natural range 0 to 15;

    begin
	if rising_edge(vis_clk) then
	    if vis_cnt_v = x"00" then
		vis_cnt_v := x"FF";
	    else
		vis_cnt_v := vis_cnt_v - "1";
	    end if;

	    vis_addr <= vis_cnt_v(7 downto 4);
	end if;

	jxa <= std_logic_vector(vis_addr);

	case vis_cnt_v(3 downto 0) is
	    when "0000" | "1111" =>
		jxm <= (others => '1');

	    when others =>
		jxm(0) <= not value(to_integer(vis_addr));
		jxm(1) <= not value(to_integer(vis_addr) + 16);
		jxm(2) <= not value(to_integer(vis_addr) + 32);
		jxm(3) <= not value(to_integer(vis_addr) + 48);

	end case;

    end process;

end RTL;
