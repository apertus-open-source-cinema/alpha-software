# vivado_program.tcl
#	ZedBoard simple program script
#	Version 1.0
# 
# Copyright (C) 2013 H.Poetzl

set ODIR .

open_hw
connect_hw_server
open_hw_target
set_property PROGRAM.FILE $ODIR/cmv_io.bit [get_hw_devices XC*]
program_hw_devices [get_hw_devices XC*]

return 0
