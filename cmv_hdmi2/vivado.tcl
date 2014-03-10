# vivado.tcl
#	ZedBoard simple build script
#	Version 1.0
# 
# Copyright (C) 2013 H.Poetzl

set ODIR .
set_param messaging.defaultLimit 10000
set_param place.sliceLegEffortLimit 2000

# STEP#1: setup design sources and constraints

read_vhdl ../addr_gen.vhd
read_vhdl ../addr_dbuf.vhd
read_vhdl ../addr_qbuf.vhd
read_vhdl ../async_div.vhd
read_vhdl ../axihp_reader.vhd
read_vhdl ../axihp_writer.vhd
read_vhdl ../axi_lite.vhd
read_vhdl ../axi_split.vhd
read_vhdl ../axi_split4.vhd
read_vhdl ../axi_split8.vhd
read_vhdl ../bram_lut.vhd
read_vhdl ../cfg_lut5.vhd
read_vhdl ../cmv_pll.vhd
read_vhdl ../cmv_serdes.vhd
read_vhdl ../cmv_spi.vhd
read_vhdl ../color_matrix.vhd
read_vhdl ../data_filter.vhd
read_vhdl ../data_sync.vhd
read_vhdl ../dsp48_wrap.vhd
read_vhdl ../fifo_chop.vhd
read_vhdl ../fifo_reset.vhd
read_vhdl ../hdmi_pll.vhd
read_vhdl ../lvds_pll.vhd
read_vhdl ../overlay.vhd
read_vhdl ../par_match.vhd
read_vhdl ../pixel_remap.vhd
read_vhdl ../pmod_debug.vhd
read_vhdl ../pp_reg_sync.vhd
read_vhdl ../pp_sync.vhd
read_vhdl ../ps7_stub.vhd
read_vhdl ../pulse_sync.vhd
read_vhdl ../ram_sdp_reg.vhd
read_vhdl ../reg_lut.vhd
read_vhdl ../reg_delay.vhd
read_vhdl ../reg_file.vhd
read_vhdl ../reg_lut5.vhd
read_vhdl ../reg_pll.vhd
read_vhdl ../reg_spi.vhd
read_vhdl ../remap_4x4.vhd
read_vhdl ../remap_shuffle.vhd
read_vhdl ../reset_sync.vhd
read_vhdl ../row_col_noise.vhd
read_vhdl ../scan_comp.vhd
read_vhdl ../scan_hdmi.vhd
read_vhdl ../scan_event.vhd
read_vhdl ../ser_to_par.vhd
read_vhdl ../sync_delay.vhd
read_vhdl ../sync_div.vhd

read_vhdl ../axi3_lite_pkg.vhd
read_vhdl ../axi3_pkg.vhd
read_vhdl ../fifo_pkg.vhd
read_vhdl ../helper_pkg.vhd
read_vhdl ../reduce_pkg.vhd
read_vhdl ../vivado_pkg.vhd
read_vhdl ../minmax.vhd
read_vhdl ../top.vhd

read_xdc ../pmod_debug.xdc
read_xdc ../pmod_logic.xdc
read_xdc ../hdmi.xdc
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

opt_design -propconst -sweep -retarget -remap
# opt_design -directive RuntimeOptimized
# power_opt_design

write_checkpoint -force $ODIR/post_opt
write_verilog -force -quiet -mode timesim -sdf_anno true post_opt.v
write_sdf -force -quiet post_opt.sdf

if { [file exists $ODIR/post_route.dcp] == 1 } {
    read_checkpoint -incremental $ODIR/post_route.dcp
}

# place_design -directive Quick
# place_design -directive RuntimeOptimized
# place_design -directive Explore
place_design -directive ExtraNetDelay_high
# place_design -directive SpreadLogic_high

# phys_opt_design -placement_opt -critical_pin_opt -hold_fix -rewire -retime
phys_opt_design -critical_cell_opt -critical_pin_opt -placement_opt -hold_fix -rewire -retime
power_opt_design
write_checkpoint -force $ODIR/post_place
write_verilog -force -quiet -mode timesim -sdf_anno true post_place.v
write_sdf -force -quiet post_place.sdf

# STEP#4: run router, write checkpoint design

# route_design
# route_design -directive Quick
# route_design -directive Explore
# route_design -directive RuntimeOptimized
# route_design -directive NoTimingRelaxation -free_resource_mode
route_design -directive HigherDelayCost
# route_design -directive HigherDelayCost -free_resource_mode
# route_design -directive AdvancedSkewModeling
write_checkpoint -force $ODIR/post_route
write_verilog -force -quiet -mode timesim -sdf_anno true post_route.v
write_sdf -force -quiet post_route.sdf

# STEP#4b: rerun router
# place_design -directive ExtraNetDelay_high
# place_design -directive ExtraPostPlacementOpt
# place_design -post_place_opt
# phys_opt_design -directive ExploreWithHoldFix
# route_design -directive HigherDelayCost
# route_design -directive NoTimingRelaxation -free_resource_mode
# route_design -directive AdvancedSkewModeling -free_resource_mode
# route_design -directive MoreGlobalIterations -free_resource_mode


report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -setup
report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -hold


# STEP#5: generate a bitstream

set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property BITSTREAM.CONFIG.USERID "DEADC0DE" [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.READBACK.ACTIVERECONFIG Yes [current_design]

# write_bitstream -force -bin_file $ODIR/cmv_hdmi.bit
write_bitstream -force $ODIR/cmv_hdmi.bit

# write_bitstream -raw_bitfile -reference_bitfile $ODIR/cmv_hdmi.bit -mask_file -logic_location_file -bin_file $ODIR/cmv_hdmi_partial.bit 
# write_bmm -force $ODIR/cmv_hdmi.bmm

# STEP#6: generate reports

report_clocks

report_utilization -hierarchical -file utilization.rpt
report_clock_utilization -file utilization.rpt -append
report_datasheet -file datasheet.rpt
report_timing_summary -file timing.rpt


# highlight_objects -rgb {128 128 128} [get_cells]
# highlight_objects -rgb {64 64 64} [get_nets]

# highlight_objects -rgb {128 0 255}	[get_cells reg_delay_inst/*]
# highlight_objects -rgb {255 0 0}	[get_cells ser_to_par_inst/*]
# highlight_objects -rgb {255 64 0}	[get_cells par_match_inst/*]
# highlight_objects -rgb {255 128 0}	[get_cells fifo_chop_inst/*]

# source ../vivado_program.tcl
# start_gui
