----------------------------------------------------------------------------
--  top.vhd (for axi3_writer)
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
--    (cd build.vivado && promgen -w -b -p bin -u 0 axi3_writer.bit -data_width 32)
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

library unimacro;
use unimacro.VCOMPONENTS.all;

use work.axi3s_pkg.all;		-- AXI3 Slave Interface
use work.vivado_pkg.all;	-- Vivado Attributes


entity top is
    port (
	clk_100 : in std_logic;			-- input clock to FPGA
	--
	pmod_jcm : out std_logic_vector(3 downto 0);
	pmod_jca : out std_logic_vector(3 downto 0);
	--
	pmod_jdm : out std_logic_vector(3 downto 0);
	pmod_jda : out std_logic_vector(3 downto 0);
	--
	swi : in std_logic_vector(7 downto 0);
	led : out std_logic_vector(7 downto 0)
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    --------------------------------------------------------------------
    -- PS7 AXI Slave Signals
    --------------------------------------------------------------------

    signal s_axi_aclk : std_logic;
    signal s_axi_areset_n : std_logic;

    signal s_axi_ri : axi3s_read_in_r;
    signal s_axi_ro : axi3s_read_out_r;
    signal s_axi_wi : axi3s_write_in_r;
    signal s_axi_wo : axi3s_write_out_r;

    attribute DONT_TOUCH of s_axi_ri : signal is "TRUE";
    attribute DONT_TOUCH of s_axi_ro : signal is "TRUE";
    attribute DONT_TOUCH of s_axi_wi : signal is "TRUE";
    attribute DONT_TOUCH of s_axi_wo : signal is "TRUE";

    --------------------------------------------------------------------
    -- PLL Signals
    --------------------------------------------------------------------

    signal pll_clk : std_logic_vector(3 downto 0);

    signal pll_locked : std_logic;

    --------------------------------------------------------------------
    -- Writer Constants and Signals
    --------------------------------------------------------------------

    signal pc_status : std_logic_vector (96 downto 0);
    signal pc_asserted : std_logic;

    component checker
	port (
	    system_resetn : in std_logic;
	    --
	    aclk : in std_logic;
	    aresetn : in std_logic;
	    --
	    pc_axi_awaddr : in std_logic_vector(31 downto 0);
	    pc_axi_awlen : in std_logic_vector(3 downto 0);
	    pc_axi_awsize : in std_logic_vector(2 downto 0);
	    pc_axi_awburst : in std_logic_vector(1 downto 0);
	    pc_axi_awlock : in std_logic_vector(1 downto 0);
	    pc_axi_awcache : in std_logic_vector(3 downto 0);
	    pc_axi_awprot : in std_logic_vector(2 downto 0);
	    pc_axi_awqos : in std_logic_vector(3 downto 0);
	    pc_axi_awvalid : in std_logic;
	    pc_axi_awready : in std_logic;
	    --
	    pc_axi_wlast : in std_logic;
	    pc_axi_wdata : in std_logic_vector(63 downto 0);
	    pc_axi_wstrb : in std_logic_vector(7 downto 0);
	    pc_axi_wvalid : in std_logic;
	    pc_axi_wready : in std_logic;
	    --
	    pc_axi_bresp : in std_logic_vector(1 downto 0);
	    pc_axi_bvalid : in std_logic;
	    pc_axi_bready : in std_logic;
	    --
	    pc_status : out std_logic_vector(96 downto 0);
	    pc_asserted : out std_logic
	);
    end component checker;

    signal writer_enable : std_logic := '0';
    signal writer_inactive : std_logic;

    --------------------------------------------------------------------
    -- Debug Signals
    --------------------------------------------------------------------

    signal pmod_clk : std_logic;

    attribute DONT_TOUCH of pmod_clk : signal is "TRUE";

    signal pmod_v0 : std_logic_vector(63 downto 0);

    attribute DONT_TOUCH of pmod_dbg_jc_inst : label is "TRUE";
    attribute MARK_DEBUG of pmod_v0 : signal is "TRUE";

    signal pmod_v1 : std_logic_vector(63 downto 0);

    attribute DONT_TOUCH of pmod_dbg_jd_inst : label is "TRUE";
    attribute MARK_DEBUG of pmod_v1 : signal is "TRUE";

begin

    --------------------------------------------------------------------
    -- PS7 Interface
    --------------------------------------------------------------------

    ps7_stub_inst : entity work.ps7_stub
	port map (
	    s_axi0_aclk => s_axi_aclk,
	    s_axi0_areset_n => s_axi_areset_n,
	    --
	    s_axi0_arid => s_axi_ri.arid,
	    s_axi0_araddr => s_axi_ri.araddr,
	    s_axi0_arburst => s_axi_ri.arburst,
	    s_axi0_arlen => s_axi_ri.arlen,
	    s_axi0_arsize => s_axi_ri.arsize,
	    s_axi0_arprot => s_axi_ri.arprot,
	    s_axi0_arvalid => s_axi_ri.arvalid,
	    s_axi0_arready => s_axi_ro.arready,
	    s_axi0_racount => s_axi_ro.racount,
	    --
	    s_axi0_rid => s_axi_ro.rid,
	    s_axi0_rdata => s_axi_ro.rdata,
	    s_axi0_rlast => s_axi_ro.rlast,
	    s_axi0_rvalid => s_axi_ro.rvalid,
	    s_axi0_rready => s_axi_ri.rready,
	    s_axi0_rcount => s_axi_ro.rcount,
	    --
	    s_axi0_awid => s_axi_wi.awid,
	    s_axi0_awaddr => s_axi_wi.awaddr,
	    s_axi0_awburst => s_axi_wi.awburst,
	    s_axi0_awlen => s_axi_wi.awlen,
	    s_axi0_awsize => s_axi_wi.awsize,
	    s_axi0_awprot => s_axi_wi.awprot,
	    s_axi0_awvalid => s_axi_wi.awvalid,
	    s_axi0_awready => s_axi_wo.awready,
	    s_axi0_wacount => s_axi_wo.wacount,
	    --
	    s_axi0_wid => s_axi_wi.wid,
	    s_axi0_wdata => s_axi_wi.wdata,
	    s_axi0_wstrb => s_axi_wi.wstrb,
	    s_axi0_wlast => s_axi_wi.wlast,
	    s_axi0_wvalid => s_axi_wi.wvalid,
	    s_axi0_wready => s_axi_wo.wready,
	    s_axi0_wcount => s_axi_wo.wcount,
	    --
	    s_axi0_bid => s_axi_wo.bid,
	    s_axi0_bresp => s_axi_wo.bresp,
	    s_axi0_bvalid => s_axi_wo.bvalid,
	    s_axi0_bready => s_axi_wi.bready );

    --------------------------------------------------------------------
    -- AXIHP PLL
    --------------------------------------------------------------------

    axihp_pll_inst : entity work.axihp_pll
	port map (
	    ref_clk_in => clk_100,
	    --
	    pll_clk => pll_clk,
	    pll_locked => pll_locked );

    --------------------------------------------------------------------
    -- Memory Writers
    --------------------------------------------------------------------

    AXI_MWRT_inst : entity work.axi_mwrt
	generic map (
	    ADDR_MASK => x"00FFFFFF",
	    ADDR_BASE => x"1B000000",
	    DATA_MASK => x"0FFC0FFC0FFC0FFC",
	    DATA_MARK => x"B003B002B001B000" )
	port map (
	    m_axi_aclk => s_axi_aclk,
	    m_axi_areset_n => s_axi_areset_n,
	    enable => writer_enable,
	    inactive => writer_inactive,
	    --
	    m_axi_wo => s_axi_wi,
	    m_axi_wi => s_axi_wo );

    s_axi_aclk <= pll_clk(0);

    AXI_check_inst : checker
	port map (
	    system_resetn => '1',
	    --
	    aclk => s_axi_aclk,
	    aresetn => s_axi_areset_n,
	    --
	    pc_axi_awaddr => s_axi_wi.awaddr,
	    pc_axi_awlen => s_axi_wi.awlen,
	    pc_axi_awsize => "011",
	    pc_axi_awburst => s_axi_wi.awburst,
	    pc_axi_awlock => (others => '0'),
	    pc_axi_awcache => (others => '0'),
	    pc_axi_awprot => s_axi_wi.awprot,
	    pc_axi_awqos => (others => '0'),
	    pc_axi_awvalid => s_axi_wi.awvalid,
	    pc_axi_awready => s_axi_wo.awready,
	    --
	    pc_axi_wlast => s_axi_wi.wlast,
	    pc_axi_wdata => s_axi_wi.wdata,
	    pc_axi_wstrb => s_axi_wi.wstrb,
	    pc_axi_wvalid => s_axi_wi.wvalid,
	    pc_axi_wready => s_axi_wo.wready,
	    --
	    pc_axi_bresp => s_axi_wo.bresp,
	    pc_axi_bvalid => s_axi_wo.bvalid,
	    pc_axi_bready => s_axi_wi.bready,
	    --
	    pc_status => pc_status,
	    pc_asserted => pc_asserted );

    led(0) <= pc_asserted;

    delay_proc : process (pll_clk(0))
	variable cnt_v : natural := 0;
    begin
	if rising_edge(pll_clk(0)) then
	    if cnt_v = 1000 then
		writer_enable <= swi(4);

	    else
		if cnt_v = 100 then
		    writer_enable <= '1';
		elsif cnt_v = 800 then
		    writer_enable <= '0';
		end if;

		cnt_v := cnt_v + 1;
	    end if;
	end if;
    end process;

    led(4) <= writer_inactive;

    led(7 downto 5) <= (others => '0');
    led(3 downto 1) <= (others => '0');

    --------------------------------------------------------------------
    -- PMOD Debug
    --------------------------------------------------------------------

    pmod_clk <= clk_100;

    pmod_dbg_jd_inst : entity work.pmod_debug
	generic map (
	    PRESCALE => 12 )
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v0,
	    --
	    jxm => pmod_jdm,
	    jxa => pmod_jda );

    pmod_dbg_jc_inst : entity work.pmod_debug
	generic map (
	    PRESCALE => 12 )
	port map (
	    clk => pmod_clk,
	    --
	    value => pmod_v1,
	    --
	    jxm => pmod_jcm,
	    jxa => pmod_jca );

    pmod_proc : process (pmod_clk, swi, pc_status)
    begin
	case swi(3 downto 0) is
	    when "0000" =>
		pmod_v0(63 downto 33) <= (others => '0');
		pmod_v0(32 downto 0) <= pc_status(96 downto 64);
		pmod_v1 <= pc_status(63 downto 0);

	    when others =>
		pmod_v0 <= (others => '0');
		pmod_v1 <= (others => '0');

	end case;
    end process;

end RTL;
