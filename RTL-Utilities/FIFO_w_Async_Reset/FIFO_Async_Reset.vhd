library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

--Capossio Leonardo for Axiom Project
--Asynchronous FIFO with Reset Synchronization

entity FIFO_Async_Reset is

	generic(
		--------------------------------
		--FIFO RESET
		--!Reset Polarity (both Input and Output)
		ACTIVE_HIGH : boolean := true;
		--!Define Output Synchronous Reset Latency (how many Cycles Sync Reset remains Active)
		LATENCY		: integer := 5;
		--------------------------------
		--FIFO MACRO
		DEVICE 						: string := "7SERIES"; -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES"
		ALMOST_FULL_OFFSET 		: bit_vector(15 downto 0) := X"0080"; -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET 		: bit_vector(15 downto 0) := X"0080"; -- Sets the almost empty threshold
		DATA_WIDTH					: integer := 1; -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE 					: string := "18Kb"; -- Target BRAM, "18Kb" or "36Kb"
		FIRST_WORD_FALL_THROUGH : boolean := FALSE -- Sets the FIFO FWFT to TRUE or FALSE
	
	);
	port(
		ALMOSTEMPTY : out std_logic; -- 1-bit output almost empty
		ALMOSTFULL 	: out std_logic; -- 1-bit output almost full
		DO 			: out std_logic_vector(DATA_WIDTH-1 downto 0); -- Output data, width defined by DATA_WIDTH parameter
		EMPTY 		: out std_logic; -- 1-bit output empty
		FULL 			: out std_logic; -- 1-bit output full
		RDCOUNT 		: out std_logic_vector(11 downto 0); -- Output read count, width determined by FIFO depth
		RDERR 		: out std_logic; -- 1-bit output read error
		WRCOUNT 		: out std_logic_vector(11 downto 0); -- Output write count, width determined by FIFO depth
		WRERR 		: out std_logic; -- 1-bit output write error
		DI 			: in std_logic_vector(DATA_WIDTH-1 downto 0); -- Input data, width defined by DATA_WIDTH parameter
		RDCLK 		: in std_logic; -- 1-bit input read clock
		RDEN 			: in std_logic; -- 1-bit input read enable
		RST 			: in std_logic; -- 1-bit input reset
		WRCLK 		: in std_logic; -- 1-bit input write clock
		WREN 			: in std_logic -- 1-bit input write enable
	);
	
end FIFO_Async_Reset;

architecture Behavioral of FIFO_Async_Reset is

	component fifo_reset is
		generic(
				--!Reset Polarity (both Input and Output)
				ACTIVE_HIGH : boolean := true;
				--!Define Output Synchronous Reset Latency (how many Cycles Sync Reset remains Active)
				LATENCY		: integer := 5
		);
		
		port (
			wclk	: in std_logic;
			rclk	: in std_logic;
			reset	: in std_logic;
			--
			fifo_rst : out std_logic;
			fifo_rd_rdy : out std_logic;
			fifo_wr_rdy : out std_logic 
		);

	end component fifo_reset;
	
	signal sgn_RDEN	: std_logic;
	signal sgn_WREN	: std_logic;
	signal sgn_FULL	: std_logic;
	signal sgn_EMPTY	: std_logic;
	
	signal fifo_rst	: std_logic;
	signal fifo_rd_rdy	: std_logic;
	signal fifo_wr_rdy	: std_logic;

begin

	FIFO_DUALCLOCK_MACRO_inst : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE => DEVICE, -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES"
		ALMOST_FULL_OFFSET => ALMOST_FULL_OFFSET, -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET => ALMOST_EMPTY_OFFSET, -- Sets the almost empty threshold
		DATA_WIDTH => DATA_WIDTH, -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE => FIFO_SIZE, -- Target BRAM, "18Kb" or "36Kb"
		FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH) -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		ALMOSTEMPTY => ALMOSTEMPTY, -- 1-bit output almost empty
		ALMOSTFULL => ALMOSTFULL, -- 1-bit output almost full
		DO => DO, -- Output data, width defined by DATA_WIDTH parameter
		EMPTY => sgn_EMPTY, -- 1-bit output empty
		FULL => sgn_FULL, -- 1-bit output full
		RDCOUNT => RDCOUNT, -- Output read count, width determined by FIFO depth
		RDERR => RDERR, -- 1-bit output read error
		WRCOUNT => WRCOUNT, -- Output write count, width determined by FIFO depth
		WRERR => WRERR, -- 1-bit output write error
		DI => DI, -- Input data, width defined by DATA_WIDTH parameter
		RDCLK => RDCLK, -- 1-bit input read clock
		RDEN => sgn_RDEN, -- 1-bit input read enable
		RST => fifo_rst, -- 1-bit input reset
		WRCLK => WRCLK, -- 1-bit input write clock
		WREN => WREN -- 1-bit input write enable
	);
	-- End of FIFO_DUALCLOCK_MACRO_inst instantiation
	
	--Assert Full and Empty signals during reset and inhibit read enable and write enable
	sgn_RDEN <= RDEN AND fifo_rd_rdy;
	sgn_WREN <= WREN AND fifo_wr_rdy;
	FULL <= sgn_FULL OR NOT(fifo_wr_rdy);
	--EMPTY <= sgn_EMPTY OR NOT(fifo_rd_rdy);
	EMPTY <= sgn_EMPTY; --empty does not need special treatment
	
	-- Instantiate Fifo Reset Mechanism
   Inst_fifo_reset: fifo_reset 
	GENERIC MAP(
		ACTIVE_HIGH 	=> ACTIVE_HIGH,
		LATENCY 			=> LATENCY
	)
	PORT MAP (
		 wclk => WRCLK,
		 rclk => RDCLK,
		 reset => RST,
		 fifo_rst => fifo_rst,
		 fifo_rd_rdy => fifo_rd_rdy,
		 fifo_wr_rdy => fifo_wr_rdy
   );


end Behavioral;