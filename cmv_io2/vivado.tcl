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
read_vhdl ../pp_sync.vhd
read_vhdl ../pp_reg_sync.vhd
read_vhdl ../ps7_stub.vhd
read_vhdl ../axi_lite.vhd
read_vhdl ../axi_split.vhd
read_vhdl ../axi_split4.vhd
read_vhdl ../reg_spi.vhd
read_vhdl ../reg_delay.vhd
read_vhdl ../reg_lut5.vhd
read_vhdl ../reg_file.vhd
read_vhdl ../pmod_debug.vhd
read_vhdl ../lvds_pll.vhd
read_vhdl ../cfg_lut5.vhd
read_vhdl ../cmv_pll.vhd
read_vhdl ../cmv_spi.vhd
read_vhdl ../cmv_serdes.vhd
read_vhdl ../ser_to_par.vhd
read_vhdl ../dsp48_wrap.vhd
read_vhdl ../addr_gen.vhd
read_vhdl ../fifo_reset.vhd
read_vhdl ../fifo_chop.vhd
read_vhdl ../par_match.vhd
read_vhdl ../data_filter.vhd
read_vhdl ../axihp_writer.vhd
read_vhdl ../pixel_remap.vhd
read_vhdl ../ram_sdp_reg.vhd

read_vhdl ../vivado_pkg.vhd
read_vhdl ../axi3_pkg.vhd
read_vhdl ../axi3_lite_pkg.vhd
read_vhdl ../reduce_pkg.vhd
read_vhdl ../fifo_pkg.vhd
read_vhdl ../top.vhd

read_xdc ../pmod_debug.xdc
read_xdc ../cmv.xdc
read_xdc ../top.xdc

set_property PART xc7z020clg484-1 [current_project]
set_property BOARD em.avnet.com:zynq:zed:c [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]

# STEP#1.1: setup IP cores

# create_ip -vlnv xilinx.com:ip:axi_protocol_checker:1.1 -module_name checker
# set_property CONFIG.PROTOCOL {AXI3} [get_ips checker]
# set_property CONFIG.READ_WRITE_MODE {READ_WRITE} [get_ips checker]
# set_property CONFIG.DATA_WIDTH {32} [get_ips checker]
# set_property CONFIG.MAX_RD_BURSTS {4} [get_ips checker]
# set_property CONFIG.MAX_WR_BURSTS {4} [get_ips checker]
# set_property CONFIG.HAS_SYSTEM_RESET {1} [get_ips checker]


# report_property -all [get_ips checker]
# set_property GENERATE_SYNTH_CHECKPOINT false \
# 	[get_files [get_property IP_FILE [get_ips checker]]]
# generate_target {synthesis} [get_ips checker]

# STEP#2: run synthesis, write checkpoint design

#synth_design -top top -flatten rebuilt -directive RuntimeOptimized
synth_design -top top -flatten rebuilt
write_checkpoint -force $ODIR/post_synth
write_verilog -force -quiet -mode timesim -sdf_anno true post_synth.v
write_sdf -force -quiet post_synth.sdf

# STEP#3: run placement and logic optimzation, write checkpoint design

# opt_design -resynth_area
# opt_design -resynth_seq_area -propconst -sweep -retarget -remap

# opt_design -propconst -sweep -retarget -remap
opt_design -directive RuntimeOptimized
# power_opt_design

write_checkpoint -force $ODIR/post_opt
write_verilog -force -quiet -mode timesim -sdf_anno true post_opt.v
write_sdf -force -quiet post_opt.sdf

# place_design -directive Quick
# place_design -directive RuntimeOptimized
place_design -directive Explore
# place_design -directive ExtraNetDelay_high
# place_design -directive SpreadLogic_high

# phys_opt_design -placement_opt -critical_pin_opt -hold_fix -rewire -retime
phys_opt_design -critical_cell_opt -placement_opt -hold_fix -rewire -retime
write_checkpoint -force $ODIR/post_place
write_verilog -force -quiet -mode timesim -sdf_anno true post_place.v
write_sdf -force -quiet post_place.sdf

# STEP#4: run router, write checkpoint design

# route_design
# route_design -directive Quick
# route_design -directive Explore
# route_design -directive RuntimeOptimized
# route_design -directive NoTimingRelaxation -free_resource_mode
route_design -directive HigherDelayCost -free_resource_mode
# route_design -directive AdvancedSkewModeling
write_checkpoint -force $ODIR/post_route
write_verilog -force -quiet -mode timesim -sdf_anno true post_route.v
write_sdf -force -quiet post_route.sdf

# STEP#4b: rerun router
# place_design -directive ExtraNetDelay_high
# place_design -directive ExtraPostPlacementOpt
# place_design -post_place_opt
# route_design -directive HigherDelayCost
# route_design -directive NoTimingRelaxation -free_resource_mode
# route_design -directive AdvancedSkewModeling -free_resource_mode
# route_design -directive MoreGlobalIterations -free_resource_mode



# STEP#5: generate a bitstream

write_bitstream -force $ODIR/cmv_io2.bit

# STEP#6: generate reports

report_clocks

report_utilization -hierarchical -file utilization.rpt
report_clock_utilization -file utilization.rpt -append
report_datasheet -file datasheet.rpt
report_timing_summary -file timing.rpt

report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -setup
report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -hold

# highlight_objects -rgb {128 128 128} [get_cells]
# highlight_objects -rgb {64 64 64} [get_nets]

highlight_objects -rgb {128 0 255}	[get_cells reg_delay_inst/*]
highlight_objects -rgb {255 0 0}	[get_cells ser_to_par_inst/*]
highlight_objects -rgb {255 64 0}	[get_cells par_match_inst/*]
highlight_objects -rgb {255 128 0}	[get_cells fifo_chop_inst/*]

source ../vivado_program.tcl
# start_gui
