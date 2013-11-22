
create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} [get_ports clk_100]
set_property PACKAGE_PIN Y9 [get_ports clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100]

set_property PACKAGE_PIN V12 [get_ports spi_en]
set_property PACKAGE_PIN W11 [get_ports spi_clk]
set_property PACKAGE_PIN W10 [get_ports spi_in]
set_property PACKAGE_PIN W12 [get_ports spi_out]

set_property IOSTANDARD LVCMOS33 [get_ports {spi_*}]

set_property PACKAGE_PIN T22 [get_ports {led[0]}]
set_property PACKAGE_PIN T21 [get_ports {led[1]}]
set_property PACKAGE_PIN U22 [get_ports {led[2]}]
set_property PACKAGE_PIN U21 [get_ports {led[3]}]
set_property PACKAGE_PIN V22 [get_ports {led[4]}]
set_property PACKAGE_PIN W22 [get_ports {led[5]}]
set_property PACKAGE_PIN U19 [get_ports {led[6]}]
set_property PACKAGE_PIN U14 [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

set_property PACKAGE_PIN F22 [get_ports {swi[0]}]
set_property PACKAGE_PIN G22 [get_ports {swi[1]}]
set_property PACKAGE_PIN H22 [get_ports {swi[2]}]
set_property PACKAGE_PIN F21 [get_ports {swi[3]}]
set_property PACKAGE_PIN H19 [get_ports {swi[4]}]
set_property PACKAGE_PIN H18 [get_ports {swi[5]}]
set_property PACKAGE_PIN H17 [get_ports {swi[6]}]
set_property PACKAGE_PIN M15 [get_ports {swi[7]}]

set_property IOSTANDARD LVCMOS25 [get_ports {swi[*]}]

# set_false_path -from [get_pins -filter {IS_CLOCK} reg_file_inst*/oreg*/*]

set_multicycle_path 2 -from [get_pins */FIFO_addr_reset/*/C]
set_multicycle_path 1 -from [get_pins */FIFO_addr_reset/*/C] -hold

set_multicycle_path 2 -from [get_pins */FIFO_data_reset/*/C]
set_multicycle_path 1 -from [get_pins */FIFO_data_reset/*/C] -hold

set_multicycle_path 2 -from [get_pins scan_gen_inst/vconf*/C]
set_multicycle_path 1 -from [get_pins scan_gen_inst/vconf*/C] -hold
