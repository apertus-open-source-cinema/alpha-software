----------------------------------------------------------------------------
--  reg_pll.vhd
--	PLL DRP Register Interface
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.all;

use work.axi3ml_pkg.all;	-- AXI3 Lite Master


entity reg_pll is
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	pll_dclk : out std_logic;
	pll_den : out std_logic;
	pll_dwe : out std_logic;
	pll_drdy : in std_logic;
	--
	pll_daddr : out std_logic_vector(6 downto 0);
	pll_dout : in std_logic_vector(15 downto 0);
	pll_din : out std_logic_vector(15 downto 0)
    );
end entity reg_pll;


architecture RTL of reg_pll is

begin

    reg_rwseq_proc : process (
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, pll_dout )

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

	variable pll_den_v : std_logic := '0';
	variable pll_dwe_v : std_logic := '0';

	type rw_state is (
	    idle,
	    r_addr, r_drdy, r_data, r_done,
	    w_addr, w_data, w_drdy, w_resp, w_done);

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

		pll_den_v := '0';
		pll_dwe_v := '0';

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
			arready_v := '1';		-- ready for transfer

			pll_dwe_v := '0';
			pll_den_v := '1';		-- trigger pll read

			state := r_drdy;

		    when r_drdy =>			-- wait for drdy
			arready_v := '0';		-- done with addr
			pll_den_v := '0';		-- done with den

			if pll_drdy = '1' then		-- pll data ready
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

			    pll_dwe_v := '1';		-- write enable
			    pll_den_v := '1';		-- trigger pll write

			    state := w_drdy;
			end if;

		    when w_drdy =>
			wready_v := '0';		-- done with write
			pll_den_v := '0';		-- done with den

			if pll_drdy = '1' then		-- pll data ready
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

	pll_daddr <= addr_v(8 downto 2);
	pll_din <= wdata_v(15 downto 0);
	s_axi_ro.rdata(15 downto 0) <= pll_dout;

	pll_dwe <= pll_dwe_v;
	pll_den <= pll_den_v;

	pll_dclk <= s_axi_aclk;

    end process;

end RTL;
