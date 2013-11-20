library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--Capossio Leonardo for Axiom Project
--FIFO Asynchronous reset synchronization

--This module asserts the reset of the FIFO and holds it during
--5 clock cycles of the slowest clock.

entity fifo_reset is
	generic(
			--!Reset Polarity (both Input and Output)
			ACTIVE_HIGH : boolean := true;
			--!Define Output Synchronous Reset Latency (how many Cycles Sync Reset remains Active)
			LATENCY		: integer := 5;
			--!Output Synchronizer delay (more is lower fanout)
			OUTPUT_DELAY : integer range 1 to integer'high := 1
	);
	
   port (
		wclk	: in std_logic;
		rclk	: in std_logic;
		reset	: in std_logic;
		--
		fifo_rst : out std_logic;
		fifo_rd_rdy : out std_logic; --'1':ready, '0'
		fifo_wr_rdy : out std_logic 
	);

end entity fifo_reset;

architecture Behavioral of fifo_reset is

	component reset_synchronizer is
		GENERIC(
			--!Reset Polarity (both Input and Output)
			ACTIVE_HIGH : boolean := true;
			--!Define Output Synchronous Reset Latency (how many Cycles Sync Reset remains Active)
			LATENCY		: integer := 4
		);
		PORT(
			CLK	  :	in std_logic;	--!Clock Input
			
			async_reset_in		: in std_logic; --!Asynchronous Reset Input
			sync_reset_out		: out std_logic --!Synchronous Reset Output
		);
	end component reset_synchronizer;

signal sgn_fifo_rd_rst	: std_logic;
signal sgn_fifo_wr_rst	: std_logic;
signal sgn_fifo_rst	: std_logic;

signal delay_ff_rclk : std_logic;
signal delay_ff_wclk : std_logic;

begin	

	Inst_RD_reset_synchronizer : reset_synchronizer
	GENERIC MAP(
	
		ACTIVE_HIGH => ACTIVE_HIGH,
		LATENCY => LATENCY
	)
	PORT MAP(
		CLK => rclk,
		async_reset_in => reset,
		sync_reset_out => sgn_fifo_rd_rst
	);
	
	Inst_WR_reset_synchronizer : reset_synchronizer
	GENERIC MAP(
	
		ACTIVE_HIGH => ACTIVE_HIGH,
		LATENCY => LATENCY
	)
	PORT MAP(
		CLK => wclk,
		async_reset_in => reset,
		sync_reset_out => sgn_fifo_wr_rst
	);
	
	--Since the FIFO reset is asynchronous, the ORing of two signals from two
	--different clock domains won't produce any unexpected behavior
	--if the reset were synchronous, a synchronizer should be used after the OR
	sgn_fifo_rst <= sgn_fifo_rd_rst OR sgn_fifo_wr_rst;
	fifo_rst <= sgn_fifo_rst;
	
	--Delay one Write Cycle just in case
	DELAY_WR_PROC:process(wclk,sgn_fifo_rst)
	begin
	
		if sgn_fifo_rst = '1' then
		
			delay_ff_wclk <= '0';
		
		elsif rising_edge(wclk) then
		
			delay_ff_wclk <= '1';
		
		end if;
	
	end process;
	
	
	fifo_wr_rdy <= delay_ff_wclk;
	
	--Delay one Read Cycle just in case
	DELAY_RD_PROC:process(rclk,sgn_fifo_rst)
	begin
	
		if sgn_fifo_rst = '1' then
		
			delay_ff_rclk <= '0';
		
		elsif rising_edge(rclk) then
		
			delay_ff_rclk <= '1';
		
		end if;
	
	end process;

	fifo_rd_rdy <= delay_ff_rclk;

end Behavioral;