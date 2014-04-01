
# set_property PACKAGE_PIN AA9 [get_ports {pmod_jal[0]}]
# set_property PACKAGE_PIN Y10 [get_ports {pmod_jal[1]}]
set_property PACKAGE_PIN V20 [get_ports {pmod_jal[0]}]
set_property PACKAGE_PIN U20 [get_ports {pmod_jal[1]}]
set_property PACKAGE_PIN AA11 [get_ports {pmod_jal[2]}]
set_property PACKAGE_PIN Y11 [get_ports {pmod_jal[3]}]
# set_property PACKAGE_PIN AA8 [get_ports {pmod_jal[4]}]
# set_property PACKAGE_PIN AB9 [get_ports {pmod_jal[5]}]
set_property PACKAGE_PIN Y21 [get_ports {pmod_jal[4]}]
set_property PACKAGE_PIN Y20 [get_ports {pmod_jal[5]}]
set_property PACKAGE_PIN AB10 [get_ports {pmod_jal[6]}]
set_property PACKAGE_PIN AB11 [get_ports {pmod_jal[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports pmod_ja*]
set_property SLEW SLOW [get_ports pmod_ja*]

set_false_path -to [get_pins pmod_jal*/D]
