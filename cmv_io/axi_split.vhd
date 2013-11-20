----------------------------------------------------------------------------
--  axi_split.vhd
--	AXI3-Lite Address Splitter (single bit based)
--	Version 1.1
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

use work.axi3ml_pkg.all;	-- AXI3 Lite Master


entity axi_split is
    generic (
	SPLIT_BIT : natural := 16
    );
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	m_axi0_aclk : out std_logic;
	m_axi0_areset_n : out std_logic;
	--
	m_axi0_ri : in axi3ml_read_in_r;
	m_axi0_ro : out axi3ml_read_out_r;
	m_axi0_wi : in axi3ml_write_in_r;
	m_axi0_wo : out axi3ml_write_out_r;
	--
	m_axi1_aclk : out std_logic;
	m_axi1_areset_n : out std_logic;
	--
	m_axi1_ri : in axi3ml_read_in_r;
	m_axi1_ro : out axi3ml_read_out_r;
	m_axi1_wi : in axi3ml_write_in_r;
	m_axi1_wo : out axi3ml_write_out_r );

end entity axi_split;


architecture RTL of axi_split is

    constant bit_mask_c : std_logic_vector(31 downto 0) :=
	std_logic_vector(to_unsigned(2 ** SPLIT_BIT, 32))
	xor x"FFFFFFFF";

    signal rsel0 : boolean := false;
    signal rsel1 : boolean := false;

    signal wsel0 : boolean := false;
    signal wsel1 : boolean := false;

begin

    split_proc : process(s_axi_aclk)

	type arb_state is ( idle_s, sel0_s, sel1_s );

	variable rstate : arb_state := idle_s;
	variable wstate : arb_state := idle_s;

	variable rsel0_v : boolean := false;
	variable rsel1_v : boolean := false;

	variable wsel0_v : boolean := false;
	variable wsel1_v : boolean := false;

    begin


	if rising_edge(s_axi_aclk) then
	    case rstate is
		when idle_s =>
		    rsel0_v := false;
		    rsel1_v := false;

		    if s_axi_ri.arvalid = '1' then
			if s_axi_ri.araddr(SPLIT_BIT) = '0' then
			    rstate := sel0_s;
			else
			    rstate := sel1_s;
			end if;
		    end if;

		when sel0_s =>
		    rsel0_v := true;

		    if m_axi0_ri.rvalid = '1' then
			rstate := idle_s;
		    end if;

		when sel1_s =>
		    rsel1_v := true;

		    if m_axi1_ri.rvalid = '1' then
			rstate := idle_s;
		    end if;

	    end case;

	    case wstate is
		when idle_s =>
		    wsel0_v := false;
		    wsel1_v := false;

		    if s_axi_wi.awvalid = '1' then
			if s_axi_wi.awaddr(SPLIT_BIT) = '0' then
			    wstate := sel0_s;
			else
			    wstate := sel1_s;
			end if;
		    end if;

		when sel0_s =>
		    wsel0_v := true;

		    if m_axi0_wi.bvalid = '1' then
			wstate := idle_s;
		    end if;

		when sel1_s =>
		    wsel1_v := true;

		    if m_axi1_wi.bvalid = '1' then
			wstate := idle_s;
		    end if;

	    end case;
	end if;

	rsel0 <= rsel0_v;
	rsel1 <= rsel1_v;

	wsel0 <= wsel0_v;
	wsel1 <= wsel1_v;

    end process;

    m_axi0_ro.arvalid <= s_axi_ri.arvalid  when rsel0 else '0';
    m_axi1_ro.arvalid <= s_axi_ri.arvalid  when rsel1 else '0';
    s_axi_ro.arready  <= m_axi0_ri.arready when rsel0 
    		    else m_axi1_ri.arready when rsel1 else '0';
    --
    m_axi0_ro.rready  <= s_axi_ri.rready   when rsel0 else '0';
    m_axi1_ro.rready  <= s_axi_ri.rready   when rsel1 else '0';
    s_axi_ro.rdata    <= m_axi0_ri.rdata   when rsel0
    		    else m_axi1_ri.rdata   when rsel1
		    else (others => '0');
    s_axi_ro.rresp    <= m_axi0_ri.rresp   when rsel0
		    else m_axi1_ri.rresp   when rsel1
		    else (others => '0');
    s_axi_ro.rvalid   <= m_axi0_ri.rvalid  when rsel0
    		    else m_axi1_ri.rvalid  when rsel1 else '0';
    --
    m_axi0_wo.awvalid <= s_axi_wi.awvalid  when wsel0 else '0';
    m_axi1_wo.awvalid <= s_axi_wi.awvalid  when wsel1 else '0';
    s_axi_wo.awready  <= m_axi0_wi.awready when wsel0
		    else m_axi1_wi.awready when wsel1 else '0';
    --
    m_axi0_wo.wvalid  <= s_axi_wi.wvalid   when wsel0 else '0';
    m_axi1_wo.wvalid  <= s_axi_wi.wvalid   when wsel1 else '0';
    s_axi_wo.wready   <= m_axi0_wi.wready  when wsel0
    		    else m_axi1_wi.wready  when wsel1 else '0';
    --
    m_axi0_wo.bready  <= s_axi_wi.bready   when wsel0 else '0';
    m_axi1_wo.bready  <= s_axi_wi.bready   when wsel1 else '0';
    s_axi_wo.bresp    <= m_axi0_wi.bresp   when wsel0
    		    else m_axi1_wi.bresp   when wsel1
		    else (others => '0');
    s_axi_wo.bvalid   <= m_axi0_wi.bvalid  when wsel0
    		    else m_axi1_wi.bvalid  when wsel1 else '0';

    m_axi0_aclk <= s_axi_aclk;
    m_axi0_areset_n <= s_axi_areset_n;

    m_axi0_ro.araddr <= s_axi_ri.araddr and bit_mask_c;
    m_axi0_ro.arprot <= (others => '0');

    m_axi0_wo.awaddr <= s_axi_wi.awaddr and bit_mask_c;
    m_axi0_wo.wdata <= s_axi_wi.wdata;
    m_axi0_wo.wstrb <= s_axi_wi.wstrb;
    m_axi0_wo.awprot <= (others => '0');

    m_axi1_aclk <= s_axi_aclk;
    m_axi1_areset_n <= s_axi_areset_n;

    m_axi1_ro.araddr <= s_axi_ri.araddr and bit_mask_c;
    m_axi1_ro.arprot <= (others => '0');

    m_axi1_wo.awaddr <= s_axi_wi.awaddr and bit_mask_c;
    m_axi1_wo.wdata <= s_axi_wi.wdata;
    m_axi1_wo.wstrb <= s_axi_wi.wstrb;
    m_axi1_wo.awprot <= (others => '0');

end RTL;
