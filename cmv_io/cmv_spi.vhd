----------------------------------------------------------------------------
--  cmv_spi.vhd
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
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity cmv_spi is
    port (
	spi_clk_in : in std_logic;
	--
	spi_write : in std_logic;
	spi_addr : in std_logic_vector(6 downto 0);
	spi_din : in std_logic_vector(15 downto 0);
	spi_go : in std_logic;
	--
	spi_dout : out std_logic_vector(15 downto 0);
	spi_active : out std_logic;
	--
	spi_clk : out std_logic;
	spi_en : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic
    );
end entity cmv_spi;


architecture RTL of cmv_spi is
begin

    spi_proc : process (
	spi_clk_in, spi_go, spi_out )

	type spi_state_t is (idle_s,
	    enab_s, addr_s, read_s, write_s, done_s);

	variable state : spi_state_t := idle_s;

	variable seq : natural range 0 to 15 := 0;

	variable spi_en_v : std_logic := '0';
	variable spi_in_v : std_logic := '0';

	variable spi_active_v : std_logic := '0';
	variable spi_dout_v : std_logic_vector(15 downto 0);

    begin
	if rising_edge(spi_clk_in) then
	    case state is
		when idle_s =>
		    spi_active_v := '0';
		    spi_en_v := '0';
		    seq := 0;

		    if spi_go = '1' then
			spi_active_v := '1';
			state := enab_s;
		    end if;

		when addr_s =>
		    if seq = 7 then
			if spi_write = '1' then
			    state := write_s;
			else
			    state := read_s;
			end if;
			seq := 0;
		    else
			seq := seq + 1;
		    end if;

		when read_s =>
		    spi_dout_v(15 - seq) := spi_out;

		    if seq = 15 then
			state := done_s;
		    else
			seq := seq + 1;
		    end if;

		when write_s =>
		    if seq = 15 then
			state := done_s;
		    else
			seq := seq + 1;
		    end if;

		when done_s =>
		    spi_en_v := '0';
		    spi_active_v := '0';

		    if spi_go = '0' then
			state := idle_s;
		    end if;

		when others =>
		    null;
	    end case;
	end if;

	if falling_edge(spi_clk_in) then
	    case state is
		when enab_s =>
		    spi_en_v := '1';
		    spi_in_v := spi_write;
		    state := addr_s;

		when addr_s =>
		    spi_in_v := spi_addr(7 - seq);

		when read_s =>
		    spi_in_v := '0';

		when write_s =>
		    spi_in_v := spi_din(15 - seq);

		when others =>
		    null;
	    end case;
	end if;

	if spi_en_v = '1' then
	    spi_clk <= spi_clk_in;
	else
	    spi_clk <= '0';
	end if;

	spi_en <= spi_en_v;
	spi_in <= spi_in_v;

	spi_active <= spi_active_v;
	spi_dout <= spi_dout_v;

    end process;

end RTL;
