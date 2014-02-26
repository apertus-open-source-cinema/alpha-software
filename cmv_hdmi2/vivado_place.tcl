# vivado.tcl
#	ZedBoard simple build script
#	Version 1.0
# 
# Copyright (C) 2013 H.Poetzl

set ODIR .
set_param messaging.defaultLimit 10000
set_param place.sliceLegEffortLimit 2000

open_checkpoint $ODIR/post_opt.dcp

delete_pblock *

read_xdc ../pmod_debug.xdc
read_xdc ../hdmi.xdc
read_xdc ../cmv.xdc
read_xdc ../top.xdc

place_design -directive Quick
# place_design -directive RuntimeOptimized
# place_design -directive Explore
# place_design -directive ExtraNetDelay_high
# place_design -directive SpreadLogic_high

# phys_opt_design -placement_opt -critical_pin_opt -hold_fix -rewire -retime
phys_opt_design -critical_cell_opt -critical_pin_opt -placement_opt -hold_fix -rewire -retime
write_checkpoint -force $ODIR/post_place
write_verilog -force -quiet -mode timesim -sdf_anno true post_place.v
write_sdf -force -quiet post_place.sdf

# STEP#4: run router, write checkpoint design

# route_design
route_design -directive Quick
# route_design -directive Explore
# route_design -directive RuntimeOptimized
# route_design -directive NoTimingRelaxation -free_resource_mode
# route_design -directive HigherDelayCost -free_resource_mode
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

report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -setup
report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -hold

start_gui
