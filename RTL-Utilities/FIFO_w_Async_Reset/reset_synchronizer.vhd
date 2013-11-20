library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--! @brief Reset Synchronizer, define Polarity and Latency.
--! @author Eng. Leonardo Capossio
--! @email capossio.leonardo@gmail.com

entity reset_synchronizer is
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
end reset_synchronizer;

architecture Behavioral of reset_synchronizer is

	signal async_regs	: std_logic_vector(LATENCY-1 downto 0); --No init value helps
	
--OPTIMIZE ONLY SYNC REGS, NOT ASYNC REGS
attribute REGISTER_BALANCING : string;
attribute REGISTER_BALANCING of async_regs: signal is "NO";
attribute REGISTER_DUPLICATION : string;
attribute REGISTER_DUPLICATION of async_regs: signal is "NO";

begin

	--Active HIGH
	GEN_ACTIVE_HIGH:if ACTIVE_HIGH = true generate

		ASYNC_REGS_PROC:process(CLK,async_reset_in)
		begin
		
			if async_reset_in = '1' then
			
				async_regs <= (others => '1');
				
			elsif rising_edge(CLK) then
			
				async_regs <= async_regs(async_regs'high-1 downto async_regs'low) & '0';
		
			end if;
		end process;
		
	end generate;
	
	
	--Active LOW
	GEN_ACTIVE_LOW:if ACTIVE_HIGH /= true generate
	
		ASYNC_REGS_PROC:process(CLK,async_reset_in)
		begin
		
			if async_reset_in = '0' then
			
				async_regs <= (others => '0');
				
			elsif rising_edge(CLK) then
			
				async_regs <= async_regs(async_regs'high-1 downto async_regs'low) & '1';
		
			end if;
		end process;
		
	end generate;
	
	--Assign Output
	sync_reset_out <= async_regs(async_regs'high);


end Behavioral;