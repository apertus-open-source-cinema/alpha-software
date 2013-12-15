
set_property PACKAGE_PIN W8 [get_ports cmv_clk]
set_property PACKAGE_PIN V10 [get_ports cmv_t_exp1]
set_property PACKAGE_PIN V9 [get_ports cmv_t_exp2]
set_property PACKAGE_PIN V8 [get_ports cmv_frame_req]

set_property IOSTANDARD LVCMOS33 [get_ports cmv_*]

set_property PACKAGE_PIN L19 [get_ports cmv_lvds_clk_n]
set_property PACKAGE_PIN L18 [get_ports cmv_lvds_clk_p]

set_property IOSTANDARD LVDS_25 [get_ports cmv_lvds_*]

set_output_delay 0.0 -reference_pin [get_ports spi_clk] [get_ports spi_in]
set_output_delay 0.0 -reference_pin [get_ports spi_clk] [get_ports spi_en]

# set_input_delay 30.0 -reference_pin [get_ports spi_clk] [get_ports spi_out]

set_output_delay 0.0 -reference_pin [get_ports {pmod_jad[0]}] [get_ports {pmod_jad[2]}]
set_output_delay 0.0 -reference_pin [get_ports {pmod_jad[0]}] [get_ports {pmod_jad[1]}]
