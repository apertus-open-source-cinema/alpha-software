
create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} [get_ports clk_100]
set_property PACKAGE_PIN Y9 [get_ports clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100]

set_property PACKAGE_PIN Y16 [get_ports i2c0_sda]
set_property PACKAGE_PIN AA18 [get_ports i2c0_scl]

set_property IOSTANDARD LVCMOS33 [get_ports {i2c0_*}]

set_property PACKAGE_PIN U7 [get_ports i2c1_sda]
set_property PACKAGE_PIN R7 [get_ports i2c1_scl]

set_property IOSTANDARD LVCMOS33 [get_ports {i2c1_*}]

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

set_property PACKAGE_PIN P16 [get_ports btn_c]
set_property PACKAGE_PIN N15 [get_ports btn_l]
set_property PACKAGE_PIN R18 [get_ports btn_r]
set_property PACKAGE_PIN T18 [get_ports btn_u]
set_property PACKAGE_PIN R16 [get_ports btn_d]

set_property IOSTANDARD LVCMOS25 [get_ports btn_*]


create_pblock pblock_delay
add_cells_to_pblock [get_pblocks pblock_delay] [get_cells -quiet [list reg_delay_inst]]
resize_pblock [get_pblocks pblock_delay] -add {SLICE_X102Y55:SLICE_X105Y144}

create_pblock pblock_spi
add_cells_to_pblock [get_pblocks pblock_spi] [get_cells -quiet [list reg_spi_inst]]
resize_pblock [get_pblocks pblock_spi] -add {SLICE_X0Y40:SLICE_X3Y49}

# create_pblock pblock_file
# add_cells_to_pblock [get_pblocks pblock_file] [get_cells reg_file_inst]
# resize_pblock [get_pblocks pblock_file] -add {SLICE_X86Y55:SLICE_X101Y144}


create_pblock pblock_div0
add_cells_to_pblock [get_pblocks pblock_div0] [get_cells -quiet [list div_lvds_inst0]]
resize_pblock [get_pblocks pblock_div0] -add {SLICE_X106Y43:SLICE_X109Y49}

create_pblock pblock_div1
add_cells_to_pblock [get_pblocks pblock_div1] [get_cells -quiet [list div_lvds_inst1]]
resize_pblock [get_pblocks pblock_div1] -add {SLICE_X110Y43:SLICE_X113Y49}


# set_property LOC PLLE2_ADV_X1Y1 [get_cells lvds_pll_inst/lvds_pll_inst]
# set_property LOC MMCME2_ADV_X1Y1 [get_cells lvds_pll_inst/lvds_mmcm_inst]

