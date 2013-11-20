----------------------------------------------------------------------------
--  reg_spi.vhd
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

library unisim;
use unisim.VCOMPONENTS.all;

use work.axi3ml_pkg.all;	-- AXI3 Lite Master


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
	spi_bclk : in std_logic;
	--
	spi_clk : out std_logic;
	spi_en : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic
    );
end entity reg_spi;


architecture RTL of reg_spi is

    signal spi_clk_in : std_logic;

    signal spi_write : std_logic;
    signal spi_addr : std_logic_vector(6 downto 0);
    signal spi_din : std_logic_vector(15 downto 0);
    signal spi_go : std_logic;

    signal spi_dout : std_logic_vector(15 downto 0);
    signal spi_active : std_logic;

begin

    spi_inst : entity work.cmv_spi
	port map (
	    spi_clk_in => spi_bclk,

	    spi_write => spi_write,
	    spi_addr => spi_addr,
	    spi_din => spi_din,
	    spi_go => spi_go,

	    spi_dout => spi_dout,
	    spi_active => spi_active,

	    spi_clk => spi_clk,
	    spi_en => spi_en,
	    spi_in => spi_in,
	    spi_out => spi_out );

    reg_rwseq_proc : process (
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, spi_dout )

	variable rwid_v : std_logic_vector(11 downto 0);
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
	variable spi_go_v : std_logic := '0';

	type rw_state is (
	    idle,
	    r_addr, r_go, r_spi, r_data, r_done,
	    w_addr, w_data, w_go, w_spi, w_resp, w_done);

	variable state : rw_state := idle;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		-- rwid_v := (others => '0');
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		spi_go_v := '0';

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
			-- rwid_v := s_axi_ri.arid;
			addr_v := s_axi_ri.araddr;
			arready_v := '1';   		-- ready for transfer

			spi_write_v := '0';
			spi_go_v := '1';

			state := r_go;

		    when r_go =>			-- wait for spi to start
			arready_v := '0';		-- done with addr

			if spi_active = '1' then
			    spi_go_v := '0';

			    state := r_spi;
			end if;

		    when r_spi =>			-- wait for spi to finish
			if spi_active = '0' then
			    state := r_data;
			end if;

		    when r_data =>
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
			-- rwid_v := s_axi_wi.awid;
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
			    spi_go_v := '1';

			    state := w_go;
			end if;

		    when w_go =>
			wready_v := '0';		-- done with write

			if spi_active = '1' then	-- wait for spi to start
			    spi_go_v := '0';

			    state := w_spi;
			end if;

		    when w_spi =>
			if spi_active = '0' then	-- wait for spi to finish
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

	-- s_axi_ro.rid <= rwid_v;
	-- s_axi_wo.bid <= rwid_v;

	spi_addr <= addr_v(8 downto 2);
	spi_din <= wdata_v(15 downto 0);
	s_axi_ro.rdata(15 downto 0) <= spi_dout;

	spi_write <= spi_write_v;
	spi_go <= spi_go_v;

    end process;

end RTL;
