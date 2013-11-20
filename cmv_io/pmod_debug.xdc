
set_property PACKAGE_PIN AB7 [get_ports {pmod_jcm[0]}]
set_property PACKAGE_PIN AB6 [get_ports {pmod_jcm[1]}]
set_property PACKAGE_PIN AA4 [get_ports {pmod_jcm[2]}]
set_property PACKAGE_PIN Y4 [get_ports {pmod_jcm[3]}]

set_property PACKAGE_PIN U4 [get_ports {pmod_jca[0]}]
set_property PACKAGE_PIN T4 [get_ports {pmod_jca[1]}]
set_property PACKAGE_PIN T6 [get_ports {pmod_jca[2]}]
set_property PACKAGE_PIN R6 [get_ports {pmod_jca[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports pmod_jc*]
set_property SLEW SLOW [get_ports pmod_jc*]

create_pblock pblock_pmod_jc
add_cells_to_pblock [get_pblocks pblock_pmod_jc] \
	[get_cells pmod_dbg_jc_inst]
resize_pblock [get_pblocks pblock_pmod_jc] -replace \
	-add {SLICE_X0Y9:SLICE_X3Y16}

set_property PACKAGE_PIN V7 [get_ports {pmod_jdm[0]}]
set_property PACKAGE_PIN W7 [get_ports {pmod_jdm[1]}]
set_property PACKAGE_PIN V4 [get_ports {pmod_jdm[2]}]
set_property PACKAGE_PIN V5 [get_ports {pmod_jdm[3]}]

set_property PACKAGE_PIN U5 [get_ports {pmod_jda[0]}]
set_property PACKAGE_PIN U6 [get_ports {pmod_jda[1]}]
set_property PACKAGE_PIN W5 [get_ports {pmod_jda[2]}]
set_property PACKAGE_PIN W6 [get_ports {pmod_jda[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports pmod_jd*]
set_property SLEW SLOW [get_ports pmod_jd*]

create_pblock pblock_pmod_jd
add_cells_to_pblock [get_pblocks pblock_pmod_jd] \
	[get_cells pmod_dbg_jd_inst]
resize_pblock [get_pblocks pblock_pmod_jd] -replace \
	-add {SLICE_X0Y1:SLICE_X3Y8}


set_property DONT_TOUCH TRUE [get_cells pmod_dbg*]

