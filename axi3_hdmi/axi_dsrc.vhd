----------------------------------------------------------------------------
--  axi_dsrc.vhd
--	AXI Based Data Source
--	Version 1.3
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.axi3s_pkg.ALL;		-- AXI3 Slave Interface

use work.fifo_pkg.ALL;		-- FIFO Functions


entity axi_dsrc is
    generic (
	ADDR_MASK : std_logic_vector(31 downto 0) := x"00FFFFFF";
	ADDR_DATA : std_logic_vector(31 downto 0) := x"1B000000" );
    port (
	m_axi_aclk	: in std_logic;
	m_axi_areset_n	: in std_logic;
	enable		: in std_logic;
	reset		: in std_logic;		-- async
	--
	m_axi_ro	: out axi3s_read_in_r;
	m_axi_ri	: in axi3s_read_out_r;
	--
	addr_clk	: in std_logic;
	addr_enable	: in std_logic;
	addr_full	: out std_logic;
	addr_in		: in std_logic_vector(31 downto 0);
	--
	data_clk	: in std_logic;
	data_enable	: in std_logic;
	data_empty	: out std_logic;
	data_out	: out std_logic_vector(15 downto 0);
	--
	reader_data	: out std_logic_vector(63 downto 0);
	reader_addr	: out std_logic_vector(31 downto 0);
	reader_state	: out std_logic_vector(7 downto 0)
    );

end entity axi_dsrc;


architecture RTL of axi_dsrc is

    attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    attribute DONT_TOUCH : string;
    attribute MARK_DEBUG : string;

    signal reset_axi : std_logic;
    signal reset_addr : std_logic;
    signal reset_data : std_logic;

    --------------------------------------------------------------------
    -- Data FIFO Signals
    --------------------------------------------------------------------

    constant DATA_WIDTH : natural := 64;

    signal rdata_clk : std_logic;
    signal rdata_enable : std_logic;
    signal rdata_out : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal rdata_full : std_logic;

    signal data64_enable : std_logic;
    signal data64_empty : std_logic;
    signal data64_out : std_logic_vector(63 downto 0);

    -- attribute DONT_TOUCH of data64_enable : signal is "TRUE";
    -- attribute DONT_TOUCH of data64_empty : signal is "TRUE";
    -- attribute DONT_TOUCH of data64_out: signal is "TRUE";

    signal fifo_data_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal fifo_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);

    constant DATA_CWIDTH : natural := cwidth_f(DATA_WIDTH, "36Kb");

    signal fifo_data_rdcount : std_logic_vector (DATA_CWIDTH - 1 downto 0);
    signal fifo_data_wrcount : std_logic_vector (DATA_CWIDTH - 1 downto 0);

    signal fifo_data_wclk : std_logic;
    signal fifo_data_wen : std_logic;
    signal fifo_data_high : std_logic;
    signal fifo_data_full : std_logic;
    signal fifo_data_wrerr : std_logic;

    signal fifo_data_rclk : std_logic;
    signal fifo_data_ren : std_logic;
    signal fifo_data_low : std_logic;
    signal fifo_data_empty : std_logic;
    signal fifo_data_rderr : std_logic;

    signal fifo_data_rst : std_logic;
    signal fifo_data_rdy : std_logic;

    --------------------------------------------------------------------
    -- Address FIFO Signals
    --------------------------------------------------------------------

    constant ADDR_WIDTH : natural := 32;

    signal raddr_clk : std_logic;
    signal raddr_enable : std_logic;
    signal raddr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal raddr_empty : std_logic;

    constant ADDR_CWIDTH : natural := cwidth_f(ADDR_WIDTH, "18Kb");

    signal fifo_addr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal fifo_addr_out : std_logic_vector (ADDR_WIDTH - 1 downto 0);

    signal fifo_addr_rdcount : std_logic_vector (ADDR_CWIDTH - 1 downto 0);
    signal fifo_addr_wrcount : std_logic_vector (ADDR_CWIDTH - 1 downto 0);

    signal fifo_addr_wclk : std_logic;
    signal fifo_addr_wen : std_logic;
    signal fifo_addr_full : std_logic;
    signal fifo_addr_wrerr : std_logic;

    signal fifo_addr_rclk : std_logic;
    signal fifo_addr_ren : std_logic;
    signal fifo_addr_empty : std_logic;
    signal fifo_addr_rderr : std_logic;

    signal fifo_addr_rst : std_logic;
    signal fifo_addr_rdy : std_logic;

    --------------------------------------------------------------------
    -- Reader Signals
    --------------------------------------------------------------------

    signal reader_enable : std_logic;

    signal div_wclk : std_logic;
    signal div_rclk : std_logic;

begin

    --------------------------------------------------------------------
    -- Reset Synchronizers
    --------------------------------------------------------------------

    sync_aclk_inst : entity work.synchronizer
	port map (
	    clk => m_axi_aclk,
	    async_in => reset,
	    sync_out => reset_axi );

    sync_addr_inst : entity work.synchronizer
	port map (
	    clk => addr_clk,
	    async_in => reset,
	    sync_out => reset_addr );

    sync_data_inst : entity work.synchronizer
	port map (
	    clk => data_clk,
	    async_in => reset,
	    sync_out => reset_data );

    --------------------------------------------------------------------
    -- Data FIFO
    --------------------------------------------------------------------

    FIFO_data_inst : FIFO_DUALCLOCK_MACRO
	generic map (
	    DEVICE => "7SERIES",
	    DATA_WIDTH => DATA_WIDTH,
	    ALMOST_FULL_OFFSET => x"020",
	    FIFO_SIZE => "36Kb",
	    FIRST_WORD_FALL_THROUGH => TRUE )
	port map (
	    DI => fifo_data_in,
	    WRCLK => fifo_data_wclk,
	    WREN => fifo_data_wen,
	    FULL => fifo_data_full,
	    ALMOSTFULL => fifo_data_high,
	    WRERR => fifo_data_wrerr,
	    WRCOUNT => fifo_data_wrcount,
	    --
	    DO => fifo_data_out,
	    RDCLK => fifo_data_rclk,
	    RDEN => fifo_data_ren,
	    EMPTY => fifo_data_empty,
	    RDERR => fifo_data_rderr,
	    RDCOUNT => fifo_data_rdcount,
	    --
	    RST => fifo_data_rst );

    FIFO_data_reset : entity work.fifo_reset
	port map (
	    clk => fifo_data_rclk,		-- assumed slower
	    reset => reset_data,
	    --
	    fifo_rst => fifo_data_rst,
	    fifo_rdy => fifo_data_rdy );

    fifo_data_wclk <= rdata_clk;
    fifo_data_wen <= rdata_enable when fifo_data_rdy = '1' else '0';
    rdata_full <= fifo_data_high when fifo_data_rdy = '1' else '1';
    fifo_data_in <= rdata_out;

    fifo_data_rclk <= data_clk;
    fifo_data_ren <= data64_enable when fifo_data_rdy = '1' else '0';
    data64_empty <= fifo_data_empty when fifo_data_rdy = '1' else '1';
    data64_out <= fifo_data_out;


    data_proc : process(data_clk, reset_data, data_enable, data64_out)
	variable cnt_v : unsigned(1 downto 0) := "00";
	variable pos_v : natural range 0 to 255 := 0;

    begin
	if reset_data = '1' then
	    cnt_v := "00";

	elsif rising_edge(data_clk) then
	    if data_enable = '1' then
		pos_v := to_integer(cnt_v(1 downto 1)) * 32;
		cnt_v := cnt_v + "1";

	    end if;
	end if;

	data_out <=
	    data64_out(pos_v + 31 downto pos_v + 24) &
	    data64_out(pos_v + 15 downto pos_v + 8);

    end process;

    data64_proc : process(data_clk, reset_data, data_enable)
	variable cnt_v : unsigned(1 downto 0) := "00";
	variable ren_v : std_logic := '0';
    begin
	if reset_data = '1' then
	    cnt_v := "00";
	    ren_v := '0';

	elsif rising_edge(data_clk) then
	    if data_enable = '1' then
		if cnt_v = "11" then
		    ren_v := '1';
		else
		    ren_v := '0';
		end if;
		
		cnt_v := cnt_v + "1";

	    else
		ren_v := '0';

	    end if;
	end if;

	data64_enable <= ren_v;

    end process;

    data_empty <= data64_empty;

    --------------------------------------------------------------------
    -- Address FIFO
    --------------------------------------------------------------------

    FIFO_addr_inst : FIFO_DUALCLOCK_MACRO
	generic map (
	    DEVICE => "7SERIES",
	    DATA_WIDTH => 32,
	    FIFO_SIZE => "18Kb",
	    FIRST_WORD_FALL_THROUGH => TRUE )
	port map (
	    DI => fifo_addr_in,
	    WRCLK => fifo_addr_wclk,
	    WREN => fifo_addr_wen,
	    FULL => fifo_addr_full,
	    WRERR => fifo_addr_wrerr,
	    WRCOUNT => fifo_addr_wrcount,
	    --
	    DO => fifo_addr_out,
	    RDCLK => fifo_addr_rclk,
	    RDEN => fifo_addr_ren,
	    EMPTY => fifo_addr_empty,
	    RDERR => fifo_addr_rderr,
	    RDCOUNT => fifo_addr_rdcount,
	    --
	    RST => fifo_addr_rst );

    FIFO_addr_reset : entity work.fifo_reset
	port map (
	    clk => fifo_addr_wclk,		-- assumed slower
	    reset => reset_addr,
	    --
	    fifo_rst => fifo_addr_rst,
	    fifo_rdy => fifo_addr_rdy );

    fifo_addr_wclk <= addr_clk;
    fifo_addr_wen <= addr_enable when fifo_addr_rdy = '1' else '0';
    addr_full <= fifo_addr_full when fifo_addr_rdy = '1' else '1';
    fifo_addr_in <= addr_in;

    fifo_addr_rclk <= raddr_clk;
    fifo_addr_ren <= raddr_enable when fifo_addr_rdy = '1' else '0';
    raddr_empty <= fifo_addr_empty when fifo_addr_rdy = '1' else '1';
    raddr_in <= fifo_addr_out;


    --------------------------------------------------------------------
    -- AXIHP Reader
    --------------------------------------------------------------------

    axihp_reader_inst : entity work.axihp_reader
	generic map (
	    DATA_WIDTH => 64,
	    DATA_COUNT => 16,
	    ADDR_MASK => ADDR_MASK,
	    ADDR_DATA => ADDR_DATA )
	port map (
	    m_axi_aclk => m_axi_aclk,
	    m_axi_areset_n => m_axi_areset_n,
	    enable => reader_enable,
	    --
	    m_axi_ro => m_axi_ro,
	    m_axi_ri => m_axi_ri,
	    --
	    data_clk => rdata_clk,		-- out
	    data_enable => rdata_enable,	-- out
	    data_out => rdata_out,		-- out
	    data_full => rdata_full,		-- in
	    --
	    addr_clk => raddr_clk,		-- out
	    addr_enable => raddr_enable,	-- out
	    addr_in => raddr_in,		-- in
	    addr_empty => raddr_empty,		-- in
	    --
	    reader_state => reader_state );

    reader_enable <= enable;
    reader_data <= fifo_data_in;
    reader_addr <= fifo_addr_out;

end RTL;
