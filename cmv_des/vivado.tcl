# vivado.tcl
#	ZedBoard simple build script
#	Version 1.0
# 
# Copyright (C) 2013 H.Poetzl

set ODIR .
set_param messaging.defaultLimit 10000

# STEP#1: setup design sources and constraints

read_vhdl ../async_div.vhd
read_vhdl ../sync_div.vhd
read_vhdl ../data_sync.vhd
read_vhdl ../ping_pong.vhd
read_vhdl ../ps7_stub.vhd
read_vhdl ../axi_lite.vhd
read_vhdl ../axi_split.vhd
read_vhdl ../reg_spi.vhd
read_vhdl ../reg_delay.vhd
read_vhdl ../pmod_debug.vhd
read_vhdl ../lvds_pll.vhd
read_vhdl ../cmv_pll.vhd
read_vhdl ../cmv_spi.vhd
read_vhdl ../cmv_serdes.vhd

read_vhdl ../vivado_pkg.vhd
read_vhdl ../axi3_pkg.vhd
read_vhdl ../axi3_lite_pkg.vhd
read_vhdl ../reduce_pkg.vhd
read_vhdl ../top.vhd

read_xdc ../pmod_debug.xdc
read_xdc ../cmv.xdc
read_xdc ../top.xdc

set_property PART xc7z020clg484-1 [current_project]
set_property BOARD em.avnet.com:zynq:zed:c [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]

# STEP#1.1: setup IP cores

create_ip -vlnv xilinx.com:ip:axi_protocol_checker:1.1 -module_name checker
set_property CONFIG.PROTOCOL {AXI3} [get_ips checker]
set_property CONFIG.READ_WRITE_MODE {READ_WRITE} [get_ips checker]
set_property CONFIG.DATA_WIDTH {32} [get_ips checker]
set_property CONFIG.MAX_RD_BURSTS {4} [get_ips checker]
set_property CONFIG.MAX_WR_BURSTS {4} [get_ips checker]
set_property CONFIG.HAS_SYSTEM_RESET {1} [get_ips checker]


report_property -all [get_ips checker]
set_property GENERATE_SYNTH_CHECKPOINT false \
	[get_files [get_property IP_FILE [get_ips checker]]]
generate_target {synthesis} [get_ips checker]

# STEP#2: run synthesis, write checkpoint design

synth_design -top top -flatten rebuilt
write_checkpoint -force $ODIR/post_synth
write_verilog -force -quiet -mode timesim -sdf_anno true post_synth.v
write_sdf -force -quiet post_synth.sdf

# STEP#3: run placement and logic optimzation, write checkpoint design

# opt_design -resynth_area
opt_design -propconst -sweep -retarget -remap
# power_opt_design

write_checkpoint -force $ODIR/post_opt
write_verilog -force -quiet -mode timesim -sdf_anno true post_opt.v
write_sdf -force -quiet post_opt.sdf

place_design

# phys_opt_design -placement_opt -critical_pin_opt -hold_fix -rewire -retime
phys_opt_design -rewire -retime
write_checkpoint -force $ODIR/post_place
write_verilog -force -quiet -mode timesim -sdf_anno true post_place.v
write_sdf -force -quiet post_place.sdf

# STEP#4: run router, write checkpoint design

route_design
write_checkpoint -force $ODIR/post_route
write_verilog -force -quiet -mode timesim -sdf_anno true post_route.v
write_sdf -force -quiet post_route.sdf

# STEP#5: generate a bitstream

write_bitstream -force $ODIR/cmv_des.bit

# STEP#6: generate reports

report_clocks

report_utilization -hierarchical -file utilization.rpt
report_clock_utilization -file utilization.rpt -append
report_datasheet -file datasheet.rpt
report_timing_summary -file timing.rpt

source ../vivado_program.tcl
# start_gui
