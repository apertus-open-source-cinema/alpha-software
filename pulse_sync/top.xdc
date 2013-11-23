
create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} [get_ports clk_100]
set_property PACKAGE_PIN Y9 [get_ports clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100]

set_property PACKAGE_PIN T22 [get_ports {led[0]}]
set_property PACKAGE_PIN T21 [get_ports {led[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]


set_property PACKAGE_PIN P16 [get_ports btn_c]

set_property IOSTANDARD LVCMOS25 [get_ports btn_c]

