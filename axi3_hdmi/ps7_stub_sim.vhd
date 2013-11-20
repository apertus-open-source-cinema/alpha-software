----------------------------------------------------------------------------
--  ps7_stub_sim.vhd
--	Processing System 7 Stub (Simulation)
--	Version 1.1
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

library unisim;
use unisim.VCOMPONENTS.all;

use work.axi3m_pkg.all;		-- AXI3 Master
use work.axi3s_pkg.all;		-- AXI3 Slave Interface


entity ps7_stub is
    port (
	ddr_addr	: inout std_logic_vector(14 downto 0)	:= (others => '0');
	ddr_bankaddr	: inout std_logic_vector(2 downto 0)	:= (others => '0');
	ddr_cas_n	: inout std_ulogic			:= '0';
	ddr_cke		: inout std_ulogic			:= '0';
	ddr_clk		: inout std_ulogic			:= '0';
	ddr_clk_n	: inout std_ulogic			:= '0';
	ddr_cs_n	: inout std_ulogic			:= '0';
	ddr_dm		: inout std_logic_vector(3 downto 0)	:= (others => '0');
	ddr_dq		: inout std_logic_vector(31 downto 0)	:= (others => '0');
	ddr_dqs		: inout std_logic_vector(3 downto 0)	:= (others => '0');
	ddr_dqs_n	: inout std_logic_vector(3 downto 0)	:= (others => '0');
	ddr_drstb	: inout std_ulogic			:= '0';
	ddr_odt		: inout std_ulogic			:= '0';
	ddr_ras_n	: inout std_ulogic			:= '0';
	ddr_vr_n	: inout std_ulogic			:= '0';
	ddr_vr		: inout std_ulogic			:= '0';
	ddr_web		: inout std_ulogic			:= '0';
	--
	ps_mio		: inout std_logic_vector(53 downto 0);
	--
	ps_clk		: inout std_ulogic			:= '0';
	ps_porb		: inout std_ulogic			:= '0';
	ps_srstb	: inout std_ulogic			:= '0';
	--
	ps_fclk		: out std_logic_vector(3 downto 0);
	ps_reset_n	: out std_logic_vector(3 downto 0);
	--
	emio_gpio_i	: in std_logic_vector(63 downto 0)	:= (others => '0');
	emio_gpio_o	: out std_logic_vector(63 downto 0);
	emio_gpio_t_n	: out std_logic_vector(63 downto 0);
	--
	i2c0_sda_i	: in std_ulogic				:= '0';
	i2c0_sda_o	: out std_ulogic;
	i2c0_sda_t_n	: out std_ulogic;
	--
	i2c0_scl_i	: in std_ulogic				:= '0';
	i2c0_scl_o	: out std_ulogic;
	i2c0_scl_t_n	: out std_ulogic;
	--
	i2c1_sda_i	: in std_ulogic				:= '0';
	i2c1_sda_o	: out std_ulogic;
	i2c1_sda_t_n	: out std_ulogic;
	--
	i2c1_scl_i	: in std_ulogic				:= '0';
	i2c1_scl_o	: out std_ulogic;
	i2c1_scl_t_n	: out std_ulogic;
	--
	m_axi0_aclk	: in std_ulogic				:= '0';
	m_axi0_areset_n : out std_ulogic;
	--	read address
	m_axi0_arid	: out std_logic_vector(11 downto 0);
	m_axi0_araddr	: out std_logic_vector(31 downto 0);
	m_axi0_arburst	: out std_logic_vector(1 downto 0);
	m_axi0_arlen	: out std_logic_vector(3 downto 0);
	m_axi0_arsize	: out std_logic_vector(1 downto 0);
	m_axi0_arlock	: out std_logic_vector(1 downto 0);
	m_axi0_arprot	: out std_logic_vector(2 downto 0);
	m_axi0_arcache	: out std_logic_vector(3 downto 0);
	m_axi0_arqos	: out std_logic_vector(3 downto 0);
	m_axi0_arvalid	: out std_ulogic;
	m_axi0_arready	: in std_ulogic				:= '0';
	--	read data
	m_axi0_rid	: in std_logic_vector(11 downto 0)	:= (others => '0');
	m_axi0_rdata	: in std_logic_vector(31 downto 0)	:= (others => '0');
	m_axi0_rlast	: in std_ulogic				:= '1';
	m_axi0_rresp	: in std_logic_vector(1 downto 0)	:= (others => '0');
	m_axi0_rvalid	: in std_ulogic				:= '0';
	m_axi0_rready	: out std_ulogic;
	--	write address
	m_axi0_awid	: out std_logic_vector(11 downto 0);
	m_axi0_awaddr	: out std_logic_vector(31 downto 0);
	m_axi0_awburst	: out std_logic_vector(1 downto 0);
	m_axi0_awlen	: out std_logic_vector(3 downto 0);
	m_axi0_awsize	: out std_logic_vector(1 downto 0);
	m_axi0_awlock	: out std_logic_vector(1 downto 0);
	m_axi0_awprot	: out std_logic_vector(2 downto 0);
	m_axi0_awcache	: out std_logic_vector(3 downto 0);
	m_axi0_awqos	: out std_logic_vector(3 downto 0);
	m_axi0_awvalid	: out std_ulogic;
	m_axi0_awready	: in std_ulogic				:= '0';
	--	write data
	m_axi0_wid	: out std_logic_vector(11 downto 0);
	m_axi0_wdata	: out std_logic_vector(31 downto 0);
	m_axi0_wstrb	: out std_logic_vector(3 downto 0);
	m_axi0_wlast	: out std_ulogic;
	m_axi0_wvalid	: out std_ulogic;
	m_axi0_wready	: in std_ulogic				:= '0';
	--	write response
	m_axi0_bid	: in std_logic_vector(11 downto 0)	:= (others => '0');
	m_axi0_bresp	: in std_logic_vector(1 downto 0)	:= (others => '0');
	m_axi0_bvalid	: in std_ulogic				:= '0';
	m_axi0_bready	: out std_ulogic;
	--
	m_axi1_aclk	: in std_ulogic				:= '0';
	m_axi1_areset_n : out std_ulogic;
	--	read address
	m_axi1_arid	: out std_logic_vector(11 downto 0);
	m_axi1_araddr	: out std_logic_vector(31 downto 0);
	m_axi1_arburst	: out std_logic_vector(1 downto 0);
	m_axi1_arlen	: out std_logic_vector(3 downto 0);
	m_axi1_arsize	: out std_logic_vector(1 downto 0);
	m_axi1_arlock	: out std_logic_vector(1 downto 0);
	m_axi1_arprot	: out std_logic_vector(2 downto 0);
	m_axi1_arcache	: out std_logic_vector(3 downto 0);
	m_axi1_arqos	: out std_logic_vector(3 downto 0);
	m_axi1_arvalid	: out std_logic;
	m_axi1_arready	: in std_ulogic				:= '0';
	--	read data
	m_axi1_rid	: in std_logic_vector(11 downto 0)	:= (others => '0');
	m_axi1_rdata	: in std_logic_vector(31 downto 0)	:= (others => '0');
	m_axi1_rlast	: in std_ulogic				:= '1';
	m_axi1_rresp	: in std_logic_vector(1 downto 0)	:= (others => '0');
	m_axi1_rvalid	: in std_ulogic				:= '0';
	m_axi1_rready	: out std_ulogic;
	--	write address
	m_axi1_awid	: out std_logic_vector(11 downto 0);
	m_axi1_awaddr	: out std_logic_vector(31 downto 0);
	m_axi1_awburst	: out std_logic_vector(1 downto 0);
	m_axi1_awlen	: out std_logic_vector(3 downto 0);
	m_axi1_awsize	: out std_logic_vector(1 downto 0);
	m_axi1_awlock	: out std_logic_vector(1 downto 0);
	m_axi1_awprot	: out std_logic_vector(2 downto 0);
	m_axi1_awcache	: out std_logic_vector(3 downto 0);
	m_axi1_awqos	: out std_logic_vector(3 downto 0);
	m_axi1_awvalid	: out std_ulogic;
	m_axi1_awready	: in std_ulogic				:= '0';
	--	write data
	m_axi1_wid	: out std_logic_vector(11 downto 0);
	m_axi1_wdata	: out std_logic_vector(31 downto 0);
	m_axi1_wstrb	: out std_logic_vector(3 downto 0);
	m_axi1_wlast	: out std_ulogic;
	m_axi1_wvalid	: out std_ulogic;
	m_axi1_wready	: in std_ulogic				:= '0';
	--	write response
	m_axi1_bid	: in std_logic_vector(11 downto 0)	:= (others => '0');
	m_axi1_bresp	: in std_logic_vector(1 downto 0)	:= (others => '0');
	m_axi1_bvalid	: in std_ulogic				:= '0';
	m_axi1_bready	: out std_ulogic;
	--
	s_axi0_aclk	: in std_ulogic				:= '0';
	s_axi0_areset_n : out std_ulogic;
	--	read address
	s_axi0_arid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi0_araddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi0_arburst	: in std_logic_vector(1 downto 0)	:= "01";
	s_axi0_arlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi0_arsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi0_arlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi0_arprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi0_arcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi0_arqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi0_arvalid	: in std_ulogic				:= '0';
	s_axi0_arready	: out std_ulogic;
	s_axi0_racount	: out std_logic_vector(2 downto 0);
	--	read data
	s_axi0_rid	: out std_logic_vector(5 downto 0);
	s_axi0_rdata	: out std_logic_vector(63 downto 0);
	s_axi0_rlast	: out std_ulogic;
	s_axi0_rresp	: out std_logic_vector(1 downto 0);
	s_axi0_rvalid	: out std_ulogic;
	s_axi0_rready	: in std_ulogic				:= '0';
	s_axi0_rcount	: out std_logic_vector(7 downto 0);
	--	write address
	s_axi0_awid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi0_awaddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi0_awburst	: in std_logic_vector(1 downto 0)	:= "01";
	s_axi0_awlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi0_awsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi0_awlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi0_awprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi0_awcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi0_awqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi0_awvalid	: in std_ulogic				:= '0';
	s_axi0_awready	: out std_ulogic;
	s_axi0_wacount	: out std_logic_vector(5 downto 0);
	--	write data
	s_axi0_wid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi0_wdata	: in std_logic_vector(63 downto 0)	:= (others => '0');
	s_axi0_wstrb	: in std_logic_vector(7 downto 0)	:= (others => '0');
	s_axi0_wlast	: in std_ulogic				:= '0';
	s_axi0_wvalid	: in std_ulogic				:= '0';
	s_axi0_wready	: out std_ulogic			:= '0';
	s_axi0_wcount	: out std_logic_vector(7 downto 0);
	--	write response
	s_axi0_bid	: out std_logic_vector(5 downto 0);
	s_axi0_bresp	: out std_logic_vector(1 downto 0);
	s_axi0_bvalid	: out std_ulogic;
	s_axi0_bready	: in std_ulogic				:= '0';
	--
	s_axi1_aclk	: in std_ulogic				:= '0';
	s_axi1_areset_n : out std_ulogic;
	--	read address
	s_axi1_arid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi1_araddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi1_arburst	: in std_logic_vector(1 downto 0)	:= "01";
	s_axi1_arlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi1_arsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi1_arlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi1_arprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi1_arcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi1_arqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi1_arvalid	: in std_ulogic				:= '0';
	s_axi1_arready	: out std_ulogic;
	s_axi1_racount	: out std_logic_vector(2 downto 0);
	--	read data
	s_axi1_rid	: out std_logic_vector(5 downto 0);
	s_axi1_rdata	: out std_logic_vector(63 downto 0);
	s_axi1_rlast	: out std_ulogic;
	s_axi1_rresp	: out std_logic_vector(1 downto 0);
	s_axi1_rvalid	: out std_ulogic;
	s_axi1_rready	: in std_ulogic				:= '0';
	s_axi1_rcount	: out std_logic_vector(7 downto 0);
	--	write address
	s_axi1_awid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi1_awaddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi1_awburst	: in std_logic_vector(1 downto 0)	:= "01";
	s_axi1_awlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi1_awsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi1_awlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi1_awprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi1_awcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi1_awqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi1_awvalid	: in std_ulogic				:= '0';
	s_axi1_awready	: out std_ulogic;
	s_axi1_wacount	: out std_logic_vector(5 downto 0);
	--	write data
	s_axi1_wid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi1_wdata	: in std_logic_vector(63 downto 0)	:= (others => '0');
	s_axi1_wstrb	: in std_logic_vector(7 downto 0)	:= (others => '0');
	s_axi1_wlast	: in std_ulogic				:= '0';
	s_axi1_wvalid	: in std_ulogic				:= '0';
	s_axi1_wready	: out std_ulogic			:= '0';
	s_axi1_wcount	: out std_logic_vector(7 downto 0);
	--	write response
	s_axi1_bid	: out std_logic_vector(5 downto 0);
	s_axi1_bresp	: out std_logic_vector(1 downto 0);
	s_axi1_bvalid	: out std_ulogic;
	s_axi1_bready	: in std_ulogic				:= '0';
	--
	s_axi2_aclk	: in std_ulogic				:= '0';
	s_axi2_areset_n : out std_ulogic;
	--	read address
	s_axi2_arid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi2_araddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi2_arburst	: in std_logic_vector(1 downto 0)	:= "01";
	s_axi2_arlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi2_arsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi2_arlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi2_arprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi2_arcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi2_arqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi2_arvalid	: in std_ulogic				:= '0';
	s_axi2_arready	: out std_ulogic;
	s_axi2_racount	: out std_logic_vector(2 downto 0);
	--	read data
	s_axi2_rid	: out std_logic_vector(5 downto 0);
	s_axi2_rdata	: out std_logic_vector(63 downto 0);
	s_axi2_rlast	: out std_ulogic;
	s_axi2_rresp	: out std_logic_vector(1 downto 0);
	s_axi2_rvalid	: out std_ulogic;
	s_axi2_rready	: in std_ulogic				:= '0';
	s_axi2_rcount	: out std_logic_vector(7 downto 0);
	--	write address
	s_axi2_awid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi2_awaddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi2_awburst	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi2_awlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi2_awsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi2_awlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi2_awprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi2_awcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi2_awqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi2_awvalid	: in std_ulogic				:= '0';
	s_axi2_awready	: out std_ulogic;
	s_axi2_wacount	: out std_logic_vector(5 downto 0);
	--	write data
	s_axi2_wid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi2_wdata	: in std_logic_vector(63 downto 0)	:= (others => '0');
	s_axi2_wstrb	: in std_logic_vector(7 downto 0)	:= (others => '0');
	s_axi2_wlast	: in std_ulogic				:= '0';
	s_axi2_wvalid	: in std_ulogic				:= '0';
	s_axi2_wready	: out std_ulogic			:= '0';
	s_axi2_wcount	: out std_logic_vector(7 downto 0);
	--	write response
	s_axi2_bid	: out std_logic_vector(5 downto 0);
	s_axi2_bresp	: out std_logic_vector(1 downto 0);
	s_axi2_bvalid	: out std_ulogic;
	s_axi2_bready	: in std_ulogic				:= '0';
	--
	s_axi3_aclk	: in std_ulogic				:= '0';
	s_axi3_areset_n : out std_ulogic;
	--	read address
	s_axi3_arid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi3_araddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi3_arburst	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi3_arlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi3_arsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi3_arlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi3_arprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi3_arcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi3_arqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi3_arvalid	: in std_ulogic				:= '0';
	s_axi3_arready	: out std_ulogic;
	s_axi3_racount	: out std_logic_vector(2 downto 0);
	--	read data
	s_axi3_rid	: out std_logic_vector(5 downto 0);
	s_axi3_rdata	: out std_logic_vector(63 downto 0);
	s_axi3_rlast	: out std_ulogic;
	s_axi3_rresp	: out std_logic_vector(1 downto 0);
	s_axi3_rvalid	: out std_ulogic;
	s_axi3_rready	: in std_ulogic				:= '0';
	s_axi3_rcount	: out std_logic_vector(7 downto 0);
	--	write address
	s_axi3_awid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi3_awaddr	: in std_logic_vector(31 downto 0)	:= (others => '0');
	s_axi3_awburst	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi3_awlen	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi3_awsize	: in std_logic_vector(1 downto 0)	:= "11";
	s_axi3_awlock	: in std_logic_vector(1 downto 0)	:= (others => '0');
	s_axi3_awprot	: in std_logic_vector(2 downto 0)	:= (others => '0');
	s_axi3_awcache	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi3_awqos	: in std_logic_vector(3 downto 0)	:= (others => '0');
	s_axi3_awvalid	: in std_ulogic				:= '0';
	s_axi3_awready	: out std_ulogic;
	s_axi3_wacount	: out std_logic_vector(5 downto 0);
	--	write data
	s_axi3_wid	: in std_logic_vector(5 downto 0)	:= (others => '0');
	s_axi3_wdata	: in std_logic_vector(63 downto 0)	:= (others => '0');
	s_axi3_wstrb	: in std_logic_vector(7 downto 0)	:= (others => '0');
	s_axi3_wlast	: in std_ulogic				:= '0';
	s_axi3_wvalid	: in std_ulogic				:= '0';
	s_axi3_wready	: out std_ulogic			:= '0';
	s_axi3_wcount	: out std_logic_vector(7 downto 0);
	--	write response
	s_axi3_bid	: out std_logic_vector(5 downto 0);
	s_axi3_bresp	: out std_logic_vector(1 downto 0);
	s_axi3_bvalid	: out std_ulogic;
	s_axi3_bready	: in std_ulogic				:= '0'
    );
end entity ps7_stub;

architecture RTL of ps7_stub is

    signal s_axi0_areset : std_logic := '0';
    signal s_axi1_areset : std_logic := '0';
    signal s_axi2_areset : std_logic := '0';
    signal s_axi3_areset : std_logic := '0';

    type axi3s_read_in_t is array (natural range <>) of
	axi3s_read_in_r;

    signal s_axi_ri : axi3s_read_in_t(3 downto 0);

    type axi3s_read_out_t is array (natural range <>) of
	axi3s_read_out_r;

    signal s_axi_ro : axi3s_read_out_t(3 downto 0);

    type axi3s_write_in_t is array (natural range <>) of
	axi3s_write_in_r;

    signal s_axi_wi : axi3s_write_in_t(3 downto 0);

    type axi3s_write_out_t is array (natural range <>) of
	axi3s_write_out_r;

    signal s_axi_wo : axi3s_write_out_t(3 downto 0);

begin

    axihp_slave_inst0 : entity work.axihp_slave
	port map (
	    s_axi_aclk => s_axi0_aclk,
	    s_axi_areset => s_axi0_areset,
	    --
	    s_axi_ro => s_axi_ro(0),
	    s_axi_ri => s_axi_ri(0),
	    s_axi_wo => s_axi_wo(0),
	    s_axi_wi => s_axi_wi(0) );

    s_axi0_areset_n <= not s_axi0_areset;

    s_axi_ri(0).arid <= s_axi0_arid;
    s_axi_ri(0).araddr <= s_axi0_araddr;
    s_axi_ri(0).arburst <= s_axi0_arburst;
    s_axi_ri(0).arlen <= s_axi0_arlen;
    s_axi_ri(0).arsize <= s_axi0_arsize;
    s_axi_ri(0).arprot <= s_axi0_arprot;
    s_axi_ri(0).arvalid <= s_axi0_arvalid;
    s_axi0_arready <= s_axi_ro(0).arready;
    s_axi0_racount <= s_axi_ro(0).racount;

    s_axi0_rid <= s_axi_ro(0).rid;
    s_axi0_rdata <= s_axi_ro(0).rdata;
    s_axi0_rlast <= s_axi_ro(0).rlast;
    s_axi0_rvalid <= s_axi_ro(0).rvalid;
    s_axi0_rcount <= s_axi_ro(0).rcount;
    s_axi_ri(0).rready <= s_axi0_rready;

    s_axi_wi(0).awid <= s_axi0_awid;
    s_axi_wi(0).awaddr <= s_axi0_awaddr;
    s_axi_wi(0).awburst <= s_axi0_awburst;
    s_axi_wi(0).awlen <= s_axi0_awlen;
    s_axi_wi(0).awsize <= s_axi0_awsize;
    s_axi_wi(0).awprot <= s_axi0_awprot;
    s_axi_wi(0).awvalid <= s_axi0_awvalid;
    s_axi0_awready <= s_axi_wo(0).awready;
    s_axi0_wacount <= s_axi_wo(0).wacount;

    s_axi_wi(0).wid <= s_axi_wi(0).wid;
    s_axi_wi(0).wdata <= s_axi_wi(0).wdata;
    s_axi_wi(0).wstrb <= s_axi_wi(0).wstrb;
    s_axi_wi(0).wlast <= s_axi_wi(0).wlast;
    s_axi_wi(0).wvalid <= s_axi_wi(0).wvalid;
    s_axi0_wready <= s_axi_wo(0).wready;
    s_axi0_wcount <= s_axi_wo(0).wcount;

    s_axi0_bid <= s_axi_wo(0).bid;
    s_axi0_bresp <= s_axi_wo(0).bresp;
    s_axi0_bvalid <= s_axi_wo(0).bvalid;
    s_axi_wi(0).bready <= s_axi0_bready;

    axihp_slave_inst1 : entity work.axihp_slave
	port map (
	    s_axi_aclk => s_axi1_aclk,
	    s_axi_areset => s_axi1_areset,
	    --
	    s_axi_ro => s_axi_ro(1),
	    s_axi_ri => s_axi_ri(1),
	    s_axi_wo => s_axi_wo(1),
	    s_axi_wi => s_axi_wi(1) );

    s_axi1_areset_n <= not s_axi1_areset;

    s_axi_ri(1).arid <= s_axi1_arid;
    s_axi_ri(1).araddr <= s_axi1_araddr;
    s_axi_ri(1).arburst <= s_axi1_arburst;
    s_axi_ri(1).arlen <= s_axi1_arlen;
    s_axi_ri(1).arsize <= s_axi1_arsize;
    s_axi_ri(1).arprot <= s_axi1_arprot;
    s_axi_ri(1).arvalid <= s_axi1_arvalid;
    s_axi1_arready <= s_axi_ro(1).arready;
    s_axi1_racount <= s_axi_ro(1).racount;

    s_axi1_rid <= s_axi_ro(1).rid;
    s_axi1_rdata <= s_axi_ro(1).rdata;
    s_axi1_rlast <= s_axi_ro(1).rlast;
    s_axi1_rvalid <= s_axi_ro(1).rvalid;
    s_axi1_rcount <= s_axi_ro(1).rcount;
    s_axi_ri(1).rready <= s_axi1_rready;

    s_axi_wi(1).awid <= s_axi1_awid;
    s_axi_wi(1).awaddr <= s_axi1_awaddr;
    s_axi_wi(1).awburst <= s_axi1_awburst;
    s_axi_wi(1).awlen <= s_axi1_awlen;
    s_axi_wi(1).awsize <= s_axi1_awsize;
    s_axi_wi(1).awprot <= s_axi1_awprot;
    s_axi_wi(1).awvalid <= s_axi1_awvalid;
    s_axi1_awready <= s_axi_wo(1).awready;
    s_axi1_wacount <= s_axi_wo(1).wacount;

    s_axi_wi(1).wid <= s_axi_wi(1).wid;
    s_axi_wi(1).wdata <= s_axi_wi(1).wdata;
    s_axi_wi(1).wstrb <= s_axi_wi(1).wstrb;
    s_axi_wi(1).wlast <= s_axi_wi(1).wlast;
    s_axi_wi(1).wvalid <= s_axi_wi(1).wvalid;
    s_axi1_wready <= s_axi_wo(1).wready;
    s_axi1_wcount <= s_axi_wo(1).wcount;

    s_axi1_bid <= s_axi_wo(1).bid;
    s_axi1_bresp <= s_axi_wo(1).bresp;
    s_axi1_bvalid <= s_axi_wo(1).bvalid;
    s_axi_wi(1).bready <= s_axi1_bready;

    axihp_slave_inst2 : entity work.axihp_slave
	port map (
	    s_axi_aclk => s_axi2_aclk,
	    s_axi_areset => s_axi2_areset,
	    --
	    s_axi_ro => s_axi_ro(2),
	    s_axi_ri => s_axi_ri(2),
	    s_axi_wo => s_axi_wo(2),
	    s_axi_wi => s_axi_wi(2) );

    s_axi2_areset_n <= not s_axi2_areset;

    s_axi_ri(2).arid <= s_axi2_arid;
    s_axi_ri(2).araddr <= s_axi2_araddr;
    s_axi_ri(2).arburst <= s_axi2_arburst;
    s_axi_ri(2).arlen <= s_axi2_arlen;
    s_axi_ri(2).arsize <= s_axi2_arsize;
    s_axi_ri(2).arprot <= s_axi2_arprot;
    s_axi_ri(2).arvalid <= s_axi2_arvalid;
    s_axi2_arready <= s_axi_ro(2).arready;
    s_axi2_racount <= s_axi_ro(2).racount;

    s_axi2_rid <= s_axi_ro(2).rid;
    s_axi2_rdata <= s_axi_ro(2).rdata;
    s_axi2_rlast <= s_axi_ro(2).rlast;
    s_axi2_rvalid <= s_axi_ro(2).rvalid;
    s_axi2_rcount <= s_axi_ro(2).rcount;
    s_axi_ri(2).rready <= s_axi2_rready;

    s_axi_wi(2).awid <= s_axi2_awid;
    s_axi_wi(2).awaddr <= s_axi2_awaddr;
    s_axi_wi(2).awburst <= s_axi2_awburst;
    s_axi_wi(2).awlen <= s_axi2_awlen;
    s_axi_wi(2).awsize <= s_axi2_awsize;
    s_axi_wi(2).awprot <= s_axi2_awprot;
    s_axi_wi(2).awvalid <= s_axi2_awvalid;
    s_axi2_awready <= s_axi_wo(2).awready;
    s_axi2_wacount <= s_axi_wo(2).wacount;

    s_axi_wi(2).wid <= s_axi_wi(2).wid;
    s_axi_wi(2).wdata <= s_axi_wi(2).wdata;
    s_axi_wi(2).wstrb <= s_axi_wi(2).wstrb;
    s_axi_wi(2).wlast <= s_axi_wi(2).wlast;
    s_axi_wi(2).wvalid <= s_axi_wi(2).wvalid;
    s_axi2_wready <= s_axi_wo(2).wready;
    s_axi2_wcount <= s_axi_wo(2).wcount;

    s_axi2_bid <= s_axi_wo(2).bid;
    s_axi2_bresp <= s_axi_wo(2).bresp;
    s_axi2_bvalid <= s_axi_wo(2).bvalid;
    s_axi_wi(2).bready <= s_axi2_bready;

    axihp_slave_inst3 : entity work.axihp_slave
	port map (
	    s_axi_aclk => s_axi3_aclk,
	    s_axi_areset => s_axi3_areset,
	    --
	    s_axi_ro => s_axi_ro(3),
	    s_axi_ri => s_axi_ri(3),
	    s_axi_wo => s_axi_wo(3),
	    s_axi_wi => s_axi_wi(3) );

    s_axi3_areset_n <= not s_axi3_areset;

    s_axi_ri(3).arid <= s_axi3_arid;
    s_axi_ri(3).araddr <= s_axi3_araddr;
    s_axi_ri(3).arburst <= s_axi3_arburst;
    s_axi_ri(3).arlen <= s_axi3_arlen;
    s_axi_ri(3).arsize <= s_axi3_arsize;
    s_axi_ri(3).arprot <= s_axi3_arprot;
    s_axi_ri(3).arvalid <= s_axi3_arvalid;
    s_axi3_arready <= s_axi_ro(3).arready;
    s_axi3_racount <= s_axi_ro(3).racount;

    s_axi3_rid <= s_axi_ro(3).rid;
    s_axi3_rdata <= s_axi_ro(3).rdata;
    s_axi3_rlast <= s_axi_ro(3).rlast;
    s_axi3_rvalid <= s_axi_ro(3).rvalid;
    s_axi3_rcount <= s_axi_ro(3).rcount;
    s_axi_ri(3).rready <= s_axi3_rready;

    s_axi_wi(3).awid <= s_axi3_awid;
    s_axi_wi(3).awaddr <= s_axi3_awaddr;
    s_axi_wi(3).awburst <= s_axi3_awburst;
    s_axi_wi(3).awlen <= s_axi3_awlen;
    s_axi_wi(3).awsize <= s_axi3_awsize;
    s_axi_wi(3).awprot <= s_axi3_awprot;
    s_axi_wi(3).awvalid <= s_axi3_awvalid;
    s_axi3_awready <= s_axi_wo(3).awready;
    s_axi3_wacount <= s_axi_wo(3).wacount;

    s_axi_wi(3).wid <= s_axi_wi(3).wid;
    s_axi_wi(3).wdata <= s_axi_wi(3).wdata;
    s_axi_wi(3).wstrb <= s_axi_wi(3).wstrb;
    s_axi_wi(3).wlast <= s_axi_wi(3).wlast;
    s_axi_wi(3).wvalid <= s_axi_wi(3).wvalid;
    s_axi3_wready <= s_axi_wo(3).wready;
    s_axi3_wcount <= s_axi_wo(3).wcount;

    s_axi3_bid <= s_axi_wo(3).bid;
    s_axi3_bresp <= s_axi_wo(3).bresp;
    s_axi3_bvalid <= s_axi_wo(3).bvalid;
    s_axi_wi(3).bready <= s_axi3_bready;


    reset_proc : process
    begin
	ps_reset_n <= "1111";
	wait for 1000ns;

	ps_reset_n <= "0000";	-- reset all @ 1us
	wait for 100ns;
	ps_reset_n <= "1111";	-- @ 1.1us
	wait;
    end process;

end RTL;
