
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

set_property PACKAGE_PIN P16 [get_ports {btn[0]}]
set_property PACKAGE_PIN N15 [get_ports {btn[1]}]
set_property PACKAGE_PIN R18 [get_ports {btn[2]}]
set_property PACKAGE_PIN T18 [get_ports {btn[3]}]
set_property PACKAGE_PIN R16 [get_ports {btn[4]}]

set_property IOSTANDARD LVCMOS25 [get_ports {btn[*]}]


set_false_path -from [get_cells -hierarchical reg_ba_reg*]
set_false_path -from [get_cells -hierarchical reg_ab_reg*]

set_false_path -from [get_cells -hierarchical ping_a_d_reg*]
set_false_path -from [get_cells -hierarchical pong_b_d_reg*]

set_false_path -from [get_pins fifo_reset_inst/shift_*/C]

set_false_path -from [get_pins reg_file_inst/oreg_*/C]
set_false_path -to [get_pins reg_file_inst/rdata_*/D]

# set_multicycle_path 2 -from [get_pins phase_*/C] -to [get_pins shift_*/D]
# set_multicycle_path 1 -from [get_pins phase_*/C] -to [get_pins shift_*/D] -hold

# set_multicycle_path 2 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/S]
# set_multicycle_path 1 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/S] -hold

# set_multicycle_path 2 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/D]
# set_multicycle_path 1 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/D] -hold

# set_multicycle_path 2 -from [get_pins GEN_LVDS*/data_out*/C] -to [get_pins FIFO_ser_inst/*/D]
# set_multicycle_path 1 -from [get_pins GEN_LVDS*/data_out*/C] -to [get_pins FIFO_ser_inst/*/D] -hold



create_pblock pblock_writer
add_cells_to_pblock [get_pblocks pblock_writer] [get_cells axihp_writer_inst]
resize_pblock [get_pblocks pblock_writer] -add {SLICE_X26Y50:SLICE_X31Y59}

create_pblock pblock_agen
add_cells_to_pblock [get_pblocks pblock_agen] [get_cells addr_gen_inst]
resize_pblock [get_pblocks pblock_agen] -add {SLICE_X32Y50:SLICE_X35Y54}
resize_pblock [get_pblocks pblock_agen] -add {DSP48_X2Y20:DSP48_X2Y21}

create_pblock pblock_fifo
add_cells_to_pblock [get_pblocks pblock_fifo] [get_cells fifo_reset_inst]
add_cells_to_pblock [get_pblocks pblock_fifo] [get_cells FIFO_data_inst]
resize_pblock [get_pblocks pblock_fifo] -add {SLICE_X32Y65:SLICE_X49Y74}
resize_pblock [get_pblocks pblock_fifo] -add {RAMB18_X2Y26:RAMB18_X2Y29}
resize_pblock [get_pblocks pblock_fifo] -add {RAMB36_X2Y13:RAMB36_X2Y14}

create_pblock pblock_filter
add_cells_to_pblock [get_pblocks pblock_filter] [get_cells data_filter_inst]
resize_pblock [get_pblocks pblock_filter] -add {SLICE_X32Y95:SLICE_X35Y99}
resize_pblock [get_pblocks pblock_filter] -add {SLICE_X32Y75:SLICE_X35Y79}


create_pblock pblock_file
add_cells_to_pblock [get_pblocks pblock_file] [get_cells reg_file_inst]
resize_pblock [get_pblocks pblock_file] -add {SLICE_X32Y125:SLICE_X49Y149}

create_pblock pblock_lut
add_cells_to_pblock [get_pblocks pblock_lut] [get_cells reg_lut5_inst]
resize_pblock [get_pblocks pblock_lut] -add {SLICE_X32Y115:SLICE_X49Y119}

create_pblock pblock_spi
add_cells_to_pblock [get_pblocks pblock_spi] [get_cells reg_spi_inst]
resize_pblock [get_pblocks pblock_spi] -add {SLICE_X32Y110:SLICE_X49Y114}

create_pblock pblock_axi
add_cells_to_pblock [get_pblocks pblock_axi] [get_cells axi_lite_inst0]
add_cells_to_pblock [get_pblocks pblock_axi] [get_cells axi_split_inst]
resize_pblock [get_pblocks pblock_axi] -add {SLICE_X26Y100:SLICE_X31Y149}


create_pblock pblock_dly
add_cells_to_pblock [get_pblocks pblock_dly] [get_cells reg_delay_inst]
resize_pblock [get_pblocks pblock_dly] -add {SLICE_X50Y100:SLICE_X53Y104}
resize_pblock [get_pblocks pblock_dly] -add {SLICE_X110Y50:SLICE_X111Y149}

create_pblock pblock_par
add_cells_to_pblock [get_pblocks pblock_par] [get_cells ser_to_par_inst]
resize_pblock [get_pblocks pblock_par] -add {SLICE_X108Y50:SLICE_X109Y149}

create_pblock pblock_pat
add_cells_to_pblock [get_pblocks pblock_pat] [get_cells par_match_inst]
resize_pblock [get_pblocks pblock_pat] -add {SLICE_X98Y50:SLICE_X101Y99}

create_pblock pblock_reme
add_cells_to_pblock [get_pblocks pblock_reme] [get_cells pixel_remap_even_inst]
resize_pblock [get_pblocks pblock_reme] -add {SLICE_X80Y75:SLICE_X97Y99}

create_pblock pblock_remo
add_cells_to_pblock [get_pblocks pblock_remo] [get_cells pixel_remap_odd_inst]
resize_pblock [get_pblocks pblock_remo] -add {SLICE_X80Y50:SLICE_X97Y74}

create_pblock pblock_chop
add_cells_to_pblock [get_pblocks pblock_chop] [get_cells fifo_chop_inst]
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X64Y50:SLICE_X67Y99}



create_pblock pblock_div0
add_cells_to_pblock [get_pblocks pblock_div0] [get_cells -quiet [list div_lvds_inst0]]
resize_pblock [get_pblocks pblock_div0] -add {SLICE_X106Y43:SLICE_X109Y49}

create_pblock pblock_div1
add_cells_to_pblock [get_pblocks pblock_div1] [get_cells -quiet [list div_lvds_inst1]]
resize_pblock [get_pblocks pblock_div1] -add {SLICE_X110Y43:SLICE_X113Y49}


# set_property LOC PLLE2_ADV_X1Y1 [get_cells lvds_pll_inst/lvds_pll_inst]
# set_property LOC MMCME2_ADV_X1Y1 [get_cells lvds_pll_inst/lvds_mmcm_inst]

