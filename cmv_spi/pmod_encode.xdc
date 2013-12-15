
set_property PACKAGE_PIN AA9 [get_ports {pmod_jad[0]}]
set_property PACKAGE_PIN Y10 [get_ports {pmod_jad[1]}]
set_property PACKAGE_PIN AA11 [get_ports {pmod_jad[2]}]
set_property PACKAGE_PIN Y11 [get_ports {pmod_jad[3]}]

set_property PACKAGE_PIN AA8 [get_ports {pmod_jac[0]}]
set_property PACKAGE_PIN AB9 [get_ports {pmod_jac[1]}]
set_property PACKAGE_PIN AB10 [get_ports {pmod_jac[2]}]
set_property PACKAGE_PIN AB11 [get_ports {pmod_jac[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports pmod_ja*]
set_property SLEW SLOW [get_ports pmod_ja*]

create_pblock pblock_pmod_ja
add_cells_to_pblock [get_pblocks pblock_pmod_ja] \
	[get_cells pmod_enc_ja_inst]
resize_pblock [get_pblocks pblock_pmod_ja] -replace \
	-add {SLICE_X0Y27:SLICE_X7Y34}

set_property DONT_TOUCH TRUE [get_cells pmod_enc*]
