----------------------------------------------------------------------------
--  cmv_deser.vhd
--	LVDS Deserializer
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
--  Heavily based on Version 2.0 of the CMOSIS reference code by
--  Gerrit Van de Velde / Bart Ceulemans
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity cmv_deser is
    port (
	serdes_clk	: in  std_logic;
	rst		: in  std_logic;

	width		: in  unsigned (1 downto 0);

	data_ser	: in  std_logic;
	data_par	: out std_logic_vector (11 downto 0);
	push		: out std_logic;

	pattern		: in  std_logic_vector (11 downto 0);
	match		: out std_logic;
	fail_cnt	: out std_logic_vector (7 downto 0);

	delay_clk	: in  std_logic;
	delay_ce	: in  std_logic;
	delay_inc	: in  std_logic;
	delay_rst	: in  std_logic;
	delay_ld	: in  std_logic;
	delay_val	: in  std_logic_vector (4 downto 0);
	delay_oval	: out std_logic_vector (4 downto 0);

	bitslip		: in  std_logic );

end entity cmv_deser;


--------------------------------------------------------------------------------
architecture RTL of cmv_deser is

    signal rst_sync	: std_logic	:= '1';

    signal data_ser_del : std_logic;

    signal bitslip_q	: std_logic	:= '0';
    signal bitslip_qq	: std_logic	:= '0';
    signal bitslip_req	: std_logic	:= '0';
    signal bitslip_even : std_logic	:= '0';

    signal iddr_q1	: std_logic;
    signal iddr_q2	: std_logic;

    signal data_1	: std_logic;
    signal data_2	: std_logic;
    signal data_2_q	: std_logic;
    signal data_1_q	: std_logic;

    signal load_parallel: std_logic	:= '0';
    signal shift_timer	: std_logic_vector ( 4 downto 0):= (others => '1');
    signal shift_data	: std_logic_vector (11 downto 0):= (others => '0');

begin

    --------------------------------------
    -- 32-TAP	DELAY: IDELAY PRIMITIVE --
    --------------------------------------
    IDELAY_inst : IDELAYE2
	generic map (
	    HIGH_PERFORMANCE_MODE   => "FALSE",
	    IDELAY_TYPE		    => "VAR_LOAD",
	    IDELAY_VALUE	    => 0,
	    REFCLK_FREQUENCY	    => 200.0,
	    SIGNAL_PATTERN	    => "DATA" )
	port map (
	    IDATAIN	=> data_ser,
	    DATAIN	=> '0',
	    DATAOUT	=> data_ser_del,
	    CINVCTRL	=> '0',
	    CNTVALUEIN	=> delay_val,
	    CNTVALUEOUT	=> delay_oval,
	    LD		=> delay_ld,
	    LDPIPEEN	=> '0',
	    C		=> delay_clk,
	    CE		=> delay_ce,
	    INC		=> delay_inc,
	    REGRST	=> delay_rst );
	
    -----------------------------------------
    -- DDR INPUT FLIPFLOPS: IDDR PRIMITIVE --
    -----------------------------------------
    IDDR_inst : IDDR
	generic map (
	    DDR_CLK_EDGE    => "SAME_EDGE_PIPELINED",
	    INIT_Q1	    => '0',
	    INIT_Q2	    => '0',
	    SRTYPE	    => "SYNC" )
	port map (
	    D	=> data_ser_del,
	    Q1	=> iddr_q1,
	    Q2	=> iddr_q2,
	    C	=> serdes_clk,
	    R	=> '0',
	    S	=> '0',
	    CE	=> '1' );

    ------------------
    -- CONTROLLER   --
    ------------------
    control_proc : process (serdes_clk)

	variable match_cnt_v : unsigned (7 downto 0) := x"00";
	variable fail_cnt_v : unsigned (7 downto 0) := x"00";
	variable push_v : std_logic := '0';

    begin
	if rising_edge(serdes_clk) then
	    rst_sync	  <= rst;

	    if (rst_sync = '1') then

		bitslip_q	<= '0';
		bitslip_qq	<= '0';
		bitslip_req	<= '0';
		bitslip_even	<= '0';
	
		load_parallel	<= '0';
	
		data_1		<= '0';
		data_2		<= '0';
		data_2_q	<= '0';
	
		shift_timer	<= (others => '1');
		shift_data	<= (others => '0');
		data_par	<= (others => '0');

	    else

		------------------------------------------------------------------------
		-- RISING EDGE DETECTOR ON BITSLIP
		bitslip_q	<= bitslip;
		bitslip_qq	<= bitslip_q;


		------------------------------------------------------------------------
		-- ASSERT BITSLIP REQUEST
		-- The receiver sampled 2 bits per clock period. At the rising edge of
		-- clk_ser, these two bits are shifted into the shift_data shift reg.
		-- The actual bitslip shifts 2 bits at once (one clk_ser cycle slipped).
		-- Therefore, every other bitslip_request, the bitslip will not be
		-- executed. Instead bits 12 downto 1 instead of 11 downto 0 will be
		-- assigned to the parallel output.

		if (bitslip_q = '1' and bitslip_qq = '0') then
		    if (bitslip_even = '0') then
			bitslip_even  <= '1';
			bitslip_req   <= '1';
		    else
			bitslip_even  <= '0';
		    end if;
		    fail_cnt_v := x"00";
		end if;


		------------------------------------------------------------------------
		-- TIMER
		-- The timer will count the required number of clocks to receive one
		-- data word. At the end of a timer period, the data is copied from the
		-- shift register to the parallel data output.
		-- When a bitslip request is high, the timer will count one clock less
		-- in a timer period. This means that the word sampling window will move
		-- by 2 bits.

		load_parallel <= '0';
		shift_timer   <= '0' & shift_timer(shift_timer'high downto 1);
		
		case width is
		    when "10" =>
			if (shift_timer (3 downto 0) = "0011")	then
			    shift_timer	  <= (others => '1');
			    load_parallel <= '1';

			elsif (shift_timer (3 downto 0) = "0111") then
			    if (bitslip_req = '1') then
				shift_timer <= (others => '1');
				bitslip_req <= '0';
			    end if;
			end if;

		    when "01" =>
			if (shift_timer (3 downto 0) = "0001")	then
			    shift_timer	  <= (others => '1');
			    load_parallel <= '1';

			elsif (shift_timer (3 downto 0) = "0011") then
			    if (bitslip_req = '1') then
				shift_timer <= (others => '1');
				bitslip_req <= '0';
			    end if;
			end if;

		    when "00" =>
			if (shift_timer (3 downto 0) = "0000")	then
			    shift_timer	  <= (others => '1');
			    load_parallel <= '1';

			elsif (shift_timer (3 downto 0) = "0001") then
			    if (bitslip_req = '1') then
				shift_timer <= (others => '1');
				bitslip_req <= '0';
			    end if;
			end if;
	
		    when others =>
			null;

		end case;

		-- Safety measure to prevent lock-up situations
		if (shift_timer (3 downto 0) = "0000") then
		   shift_timer	 <= (others => '1');
		   load_parallel <= '1';
		end	if;


		------------------------------------------------------------------------
		-- SHIFT IN DATA
		data_1	 <= iddr_q1;
		data_2	 <= iddr_q2;
		data_2_q <= data_2;


		if (bitslip_even = '1') then
		    shift_data <= data_2     &
				  data_1     &
				  shift_data(shift_data'high downto 2);

		else
		    shift_data <= data_1     &
				  data_2_q   &
				  shift_data(shift_data'high downto 2);

		end if;


		------------------------------------------------------------------------
		-- COPY SHIFT REGISTER TO PARALLEL DATA OUTPUT
		------------------------------------------------------------------------

		if (load_parallel =	'1') then
		    case width is
			when  "10" => data_par <= "0000" & shift_data(11 downto 4);
			when  "01" => data_par <= "00" & shift_data(11 downto 2);
			when  "00" => data_par <= shift_data;
			when others => data_par <= (others => '0');
		    end case;

		    push_v := '1';

		    if shift_data = pattern then
			if match_cnt_v /= x"FF" then
			    match_cnt_v := match_cnt_v + "1";
			end if;
		    else
			if match_cnt_v(7 downto 4) /= x"0" then
			    match_cnt_v := match_cnt_v - x"10";
			end if;
			fail_cnt_v := fail_cnt_v + "1";
		    end if;
		else
		    push_v := '0';
		end if;

	    end if;
	end if;

	if falling_edge(serdes_clk) then
	    push <= push_v;
	end if;

	match <= match_cnt_v(7);
	fail_cnt <= std_logic_vector(fail_cnt_v);
    end process;

end RTL;
