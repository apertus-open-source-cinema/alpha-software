----------------------------------------------------------------------------
--  sim_ps7_stub.vhd
--	Processing System 7 Stub (AXIHP Simulation)
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

begin
    s_axi0_areset_n <= '1';

    s_axi0_awready <= '1';
    s_axi0_wready <= '1';
    s_axi0_wacount <= (others => '0');

    s_axi0_bid <= (others => '0');
    s_axi0_bresp <= (others => '0');
    s_axi0_bvalid <= '1';

    s_axi1_areset_n <= '1';

    s_axi1_awready <= '1';
    s_axi1_wready <= '1';
    s_axi1_wacount <= (others => '0');

    s_axi1_bid <= (others => '0');
    s_axi1_bresp <= (others => '0');
    s_axi1_bvalid <= '1';

    s_axi2_areset_n <= '1';

    s_axi2_awready <= '1';
    s_axi2_wready <= '1';
    s_axi2_wacount <= (others => '0');

    s_axi2_bid <= (others => '0');
    s_axi2_bresp <= (others => '0');
    s_axi2_bvalid <= '1';

    s_axi3_areset_n <= '1';

    s_axi3_awready <= '1';
    s_axi3_wready <= '1';
    s_axi3_wacount <= (others => '0');

    s_axi3_bid <= (others => '0');
    s_axi3_bresp <= (others => '0');
    s_axi3_bvalid <= '1';

end RTL;
