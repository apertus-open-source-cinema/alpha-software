----------------------------------------------------------------------------
--  lutm_lut.vhd
--	LUTM RAM Based LUT
--	Version 1.1
--
--  Copyright (C) 2014 H.Poetzl
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

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity lutm_lut is
    generic (
	DATA_WIDTH : natural := 8;
	ADDR_WIDTH : natural := 6
    );
    port (
	lut_clk : in std_logic;
	--
	lut_addr0 : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	lut_dout0 : out std_logic_vector (DATA_WIDTH - 1 downto 0);
	--
	lut_addr1 : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	lut_dout1 : out std_logic_vector (DATA_WIDTH - 1 downto 0);
	--
	lut_addr2 : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	lut_dout2 : out std_logic_vector (DATA_WIDTH - 1 downto 0);
	--
	mem_clk : in std_logic;
	mem_re : in std_logic;
	mem_we : in std_logic;
	--
	mem_addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	mem_din : in std_logic_vector (DATA_WIDTH - 1 downto 0);
	mem_dout : out std_logic_vector (DATA_WIDTH - 1 downto 0)
    );
end entity lutm_lut;


architecture RTL of bram_lut is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant MEM_SIZE : natural := 2 ** ADDR_WIDTH;

    type mem_r is array (natural range <>) of
        std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal mem : mem_r (0 to MEM_SIZE - 1)
	:= (others => (others => '0'));

    attribute RAM_STYLE of mem : signal is "distributed";

begin

    port_a_proc : process (lut_clk)
    begin
	if rising_edge(lut_clk) then
	    lut_dout0 <= mem(to_integer(unsigned(lut_addr0)));
	end if;
    end process;

    port_b_proc : process (lut_clk)
    begin
	if rising_edge(lut_clk) then
	    lut_dout1 <= mem(to_integer(unsigned(lut_addr1)));
	end if;
    end process;

    port_c_proc : process (lut_clk)
    begin
	if rising_edge(lut_clk) then
	    lut_dout2 <= mem(to_integer(unsigned(lut_addr2)));
	end if;
    end process;

    port_d_proc : process (mem_clk)
    begin
	if rising_edge(mem_clk) then
	    if mem_we = '1' then
		mem(to_integer(unsigned(mem_addr))) <= mem_din;

	    elsif mem_re = '1' then
		mem_dout <= mem(to_integer(unsigned(mem_addr)));
	    end if;
	end if;
    end process;

end RTL;
