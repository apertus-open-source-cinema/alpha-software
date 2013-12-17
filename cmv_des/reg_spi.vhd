----------------------------------------------------------------------------
--  reg_spi.vhd
--	AXI3 Lite CMV SPI Interface
--	Version 1.2
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
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity reg_spi is
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	spi_clk_in : in std_logic;
	--
	spi_clk : out std_logic;
	spi_en : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic
    );
end entity reg_spi;


architecture RTL of reg_spi is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

	-- s_axi_aclk domain
    signal axi_spi_go : std_logic := '0';
    signal axi_spi_done : std_logic;
    signal axi_spi_active : std_logic;

	-- spi_clk_in domain
    signal spi_go : std_logic;
    signal spi_done : std_logic := '0';
    signal spi_action : std_logic;
    signal spi_action_occ : std_logic := '0';
    signal spi_active : std_logic;

	-- mixed domain
    signal spi_write : std_logic;
    signal spi_addr : std_logic_vector(6 downto 0);
    signal spi_din : std_logic_vector(15 downto 0);

    signal spi_dout : std_logic_vector(15 downto 0);
    signal spi_latch : std_logic;

begin

    ping_pong_inst : entity work.ping_pong
	port map (
	    clk_a => s_axi_aclk,
	    ping_a => axi_spi_go,		-- in,  toggle
	    pong_a => axi_spi_done,		-- out, toggle
	    active => axi_spi_active,		-- out
	    --
	    clk_b => spi_clk_in,
	    ping_b => spi_go,			-- out, toggle
	    pong_b => spi_done,			-- in,  toggle
	    action => spi_action );		-- out

    spi_inst : entity work.cmv_spi
	port map (
	    spi_clk_in => spi_clk_in,
	    --
	    spi_action => spi_action_occ,
	    spi_active => spi_active,
	    --
	    spi_write => spi_write,
	    spi_addr => spi_addr,
	    spi_din => spi_din,
	    --
	    spi_dout => spi_dout,
	    spi_latch => spi_latch,
	    --
	    spi_clk => spi_clk,
	    spi_en => spi_en,
	    spi_in => spi_in,
	    spi_out => spi_out );

    --------------------------------------------------------------------
    -- One Clock Cycle Trigger
    --------------------------------------------------------------------

    action_proc : process (spi_clk_in, spi_action)
	variable spi_action_v : std_logic := '0';
    begin
	if rising_edge(spi_clk_in) then
	    spi_action_occ <= '0';

	    if spi_action = '1' and
		spi_action_v = '0' then
		spi_action_occ <= '1';
	    end if;

	    spi_action_v := spi_action;
	end if;
    end process;

    --------------------------------------------------------------------
    -- Falling Edge on Active
    --------------------------------------------------------------------

    done_proc : process (spi_clk_in, spi_latch)
	variable spi_active_v : std_logic := '0';
    begin
	if rising_edge(spi_clk_in) then
	    if spi_active = '0' and
		spi_active_v = '1' then
		spi_done <= spi_go;	-- turn around
	    end if;

	    spi_active_v := spi_active;
	end if;
    end process;

    --------------------------------------------------------------------
    -- AXI Read/Write
    --------------------------------------------------------------------

    reg_rwseq_proc : process (
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, spi_dout )

	variable addr_v : std_logic_vector(31 downto 0);

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rresp_v : std_logic_vector(1 downto 0) := "00";

	variable wdata_v : std_logic_vector(31 downto 0);
	variable wstrb_v : std_logic_vector(3 downto 0);
	variable bresp_v : std_logic_vector(1 downto 0) := "00";

	variable spi_write_v : std_logic := '1';

	type rw_state is (
	    idle,
	    r_addr, r_go, r_spi, r_data, r_done,
	    w_addr, w_data, w_go, w_spi, w_resp, w_done);

	variable state : rw_state := idle;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		state := idle;

	    else
		case state is
		    when idle =>
			if s_axi_ri.arvalid = '1' then	-- address _is_ valid
			    state := r_addr;

			elsif s_axi_wi.awvalid = '1' then -- address _is_ valid
			    state := w_addr;

			end if;

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when r_addr =>
			addr_v := s_axi_ri.araddr;
			arready_v := '1';		-- ready for transfer

			spi_write_v := '0';
			state := r_go;

		    when r_go =>			-- trigger spi action
			arready_v := '0';		-- done with addr

			axi_spi_go <= not axi_spi_go;	-- toggle trigger
			state := r_spi;

		    when r_spi =>			-- wait for spi
			if axi_spi_active = '0' then
			    state := r_data;
			end if;

		    when r_data =>			-- deliver data
			rresp_v := "00";

			if s_axi_ri.rready = '1' then	-- master ready
			    rvalid_v := '1';		-- data is valid

			    state := r_done;
			end if;

		    when r_done =>
			rvalid_v := '0';

			state := idle;

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when w_addr =>
			addr_v := s_axi_wi.awaddr;
			awready_v := '1';   		-- ready for transfer

			state := w_data;

		    when w_data =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- we are ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    bresp_v := "00";		-- transfer OK

			    spi_write_v := '1';
			    state := w_go;
			end if;

		    when w_go =>			-- trigger spi action
			wready_v := '0';		-- done with write

			axi_spi_go <= not axi_spi_go;	-- toggle trigger
			state := w_spi;

		    when w_spi =>			-- wait for spi
			if axi_spi_active = '0' then
			    state := w_resp;
			end if;

		    when w_resp =>
			if s_axi_wi.bready = '1' then	-- master ready
			    bvalid_v := '1';		-- response valid

			    state := w_done;
			end if;

		    when w_done =>
			bvalid_v := '0';

			state := idle;

		end case;
	    end if;
	end if;

	s_axi_ro.arready <= arready_v;
	s_axi_ro.rvalid <= rvalid_v;

	s_axi_wo.awready <= awready_v;
	s_axi_wo.wready <= wready_v;
	s_axi_wo.bvalid <= bvalid_v;

	s_axi_ro.rresp <= rresp_v;

	s_axi_wo.bresp <= bresp_v;

	spi_write <= spi_write_v;
	spi_addr <= addr_v(8 downto 2);
	spi_din <= wdata_v(15 downto 0);

	s_axi_ro.rdata(15 downto 0) <= spi_dout;

    end process;

end RTL;
