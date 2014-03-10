
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
add_cells_to_pblock [get_pblocks pblock_pmod_jc] [get_cells pmod_dbg_jc_inst]
resize_pblock [get_pblocks pblock_pmod_jc] -add {SLICE_X54Y0:SLICE_X57Y9}
#resize_pblock [get_pblocks pblock_pmod_jc] -add {SLICE_X54Y10:SLICE_X57Y19}

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
add_cells_to_pblock [get_pblocks pblock_pmod_jd] [get_cells pmod_dbg_jd_inst]
resize_pblock [get_pblocks pblock_pmod_jd] -add {SLICE_X58Y0:SLICE_X61Y9}
#resize_pblock [get_pblocks pblock_pmod_jd] -add {SLICE_X58Y10:SLICE_X61Y19}


set_property DONT_TOUCH TRUE [get_cells pmod_dbg*]

create_pblock pblock_pmod
add_cells_to_pblock [get_pblocks pblock_pmod] [get_cells pmod_v0*]
add_cells_to_pblock [get_pblocks pblock_pmod] [get_cells pmod_v1*]
resize_pblock [get_pblocks pblock_pmod] -add {SLICE_X62Y0:SLICE_X69Y9}
#resize_pblock [get_pblocks pblock_pmod] -add {SLICE_X62Y10:SLICE_X69Y19}


set_false_path -to [get_pins pmod_v*/D]
