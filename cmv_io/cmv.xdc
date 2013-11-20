
create_clock -period 6.666 -name lvds_outclk -waveform {0.000 3.333} [get_ports cmv_lvds_outclk*]

set_input_delay -clock lvds_outclk -max 2.5 [get_ports cmv_lvds_data*]
set_input_delay -clock lvds_outclk -max 2.5 [get_ports cmv_lvds_data*] -clock_fall -add_delay
set_input_delay -clock lvds_outclk -min 0.8 [get_ports cmv_lvds_data*]
set_input_delay -clock lvds_outclk -min 0.8 [get_ports cmv_lvds_data*] -clock_fall -add_delay


set_property PACKAGE_PIN W8 [get_ports cmv_clk]
set_property PACKAGE_PIN V10 [get_ports cmv_t_exp1]
set_property PACKAGE_PIN V9 [get_ports cmv_t_exp2]
set_property PACKAGE_PIN V8 [get_ports cmv_frame_req]

set_property IOSTANDARD LVCMOS33 [get_ports cmv_*]


set_property PACKAGE_PIN L19 [get_ports cmv_lvds_clk_n]
set_property PACKAGE_PIN L18 [get_ports cmv_lvds_clk_p]

set_property PACKAGE_PIN C19 [get_ports cmv_lvds_outclk_n]
set_property PACKAGE_PIN D18 [get_ports cmv_lvds_outclk_p]

set_property PACKAGE_PIN N20 [get_ports cmv_lvds_ctrl_n]
set_property PACKAGE_PIN N19 [get_ports cmv_lvds_ctrl_p]

set_property PACKAGE_PIN M22 [get_ports {cmv_lvds_data_n[0]}]
set_property PACKAGE_PIN K18 [get_ports {cmv_lvds_data_n[1]}]
set_property PACKAGE_PIN T17 [get_ports {cmv_lvds_data_n[2]}]
set_property PACKAGE_PIN R21 [get_ports {cmv_lvds_data_n[3]}]
set_property PACKAGE_PIN M17 [get_ports {cmv_lvds_data_n[4]}]
set_property PACKAGE_PIN N18 [get_ports {cmv_lvds_data_n[5]}]
set_property PACKAGE_PIN B20 [get_ports {cmv_lvds_data_n[6]}]
set_property PACKAGE_PIN J17 [get_ports {cmv_lvds_data_n[7]}]
set_property PACKAGE_PIN G16 [get_ports {cmv_lvds_data_n[8]}]
set_property PACKAGE_PIN E20 [get_ports {cmv_lvds_data_n[9]}]
set_property PACKAGE_PIN D15 [get_ports {cmv_lvds_data_n[10]}]
set_property PACKAGE_PIN A19 [get_ports {cmv_lvds_data_n[11]}]
set_property PACKAGE_PIN E18 [get_ports {cmv_lvds_data_n[12]}]
set_property PACKAGE_PIN A17 [get_ports {cmv_lvds_data_n[13]}]
set_property PACKAGE_PIN B15 [get_ports {cmv_lvds_data_n[14]}]
set_property PACKAGE_PIN A22 [get_ports {cmv_lvds_data_n[15]}]
set_property PACKAGE_PIN M20 [get_ports {cmv_lvds_data_n[16]}]
set_property PACKAGE_PIN P22 [get_ports {cmv_lvds_data_n[17]}]
set_property PACKAGE_PIN L22 [get_ports {cmv_lvds_data_n[18]}]
set_property PACKAGE_PIN J22 [get_ports {cmv_lvds_data_n[19]}]
set_property PACKAGE_PIN T19 [get_ports {cmv_lvds_data_n[20]}]
set_property PACKAGE_PIN P21 [get_ports {cmv_lvds_data_n[21]}]
set_property PACKAGE_PIN K20 [get_ports {cmv_lvds_data_n[22]}]
set_property PACKAGE_PIN K21 [get_ports {cmv_lvds_data_n[23]}]
set_property PACKAGE_PIN G21 [get_ports {cmv_lvds_data_n[24]}]
set_property PACKAGE_PIN C20 [get_ports {cmv_lvds_data_n[25]}]
set_property PACKAGE_PIN F19 [get_ports {cmv_lvds_data_n[26]}]
set_property PACKAGE_PIN D21 [get_ports {cmv_lvds_data_n[27]}]
set_property PACKAGE_PIN C22 [get_ports {cmv_lvds_data_n[28]}]
set_property PACKAGE_PIN C18 [get_ports {cmv_lvds_data_n[29]}]
set_property PACKAGE_PIN B17 [get_ports {cmv_lvds_data_n[30]}]
set_property PACKAGE_PIN B22 [get_ports {cmv_lvds_data_n[31]}]

set_property PACKAGE_PIN M21 [get_ports {cmv_lvds_data_p[0]}]
set_property PACKAGE_PIN J18 [get_ports {cmv_lvds_data_p[1]}]
set_property PACKAGE_PIN T16 [get_ports {cmv_lvds_data_p[2]}]
set_property PACKAGE_PIN R20 [get_ports {cmv_lvds_data_p[3]}]
set_property PACKAGE_PIN L17 [get_ports {cmv_lvds_data_p[4]}]
set_property PACKAGE_PIN N17 [get_ports {cmv_lvds_data_p[5]}]
set_property PACKAGE_PIN B19 [get_ports {cmv_lvds_data_p[6]}]
set_property PACKAGE_PIN J16 [get_ports {cmv_lvds_data_p[7]}]
set_property PACKAGE_PIN G15 [get_ports {cmv_lvds_data_p[8]}]
set_property PACKAGE_PIN E19 [get_ports {cmv_lvds_data_p[9]}]
set_property PACKAGE_PIN E15 [get_ports {cmv_lvds_data_p[10]}]
set_property PACKAGE_PIN A18 [get_ports {cmv_lvds_data_p[11]}]
set_property PACKAGE_PIN F18 [get_ports {cmv_lvds_data_p[12]}]
set_property PACKAGE_PIN A16 [get_ports {cmv_lvds_data_p[13]}]
set_property PACKAGE_PIN C15 [get_ports {cmv_lvds_data_p[14]}]
set_property PACKAGE_PIN A21 [get_ports {cmv_lvds_data_p[15]}]
set_property PACKAGE_PIN M19 [get_ports {cmv_lvds_data_p[16]}]
set_property PACKAGE_PIN N22 [get_ports {cmv_lvds_data_p[17]}]
set_property PACKAGE_PIN L21 [get_ports {cmv_lvds_data_p[18]}]
set_property PACKAGE_PIN J21 [get_ports {cmv_lvds_data_p[19]}]
set_property PACKAGE_PIN R19 [get_ports {cmv_lvds_data_p[20]}]
set_property PACKAGE_PIN P20 [get_ports {cmv_lvds_data_p[21]}]
set_property PACKAGE_PIN K19 [get_ports {cmv_lvds_data_p[22]}]
set_property PACKAGE_PIN J20 [get_ports {cmv_lvds_data_p[23]}]
set_property PACKAGE_PIN G20 [get_ports {cmv_lvds_data_p[24]}]
set_property PACKAGE_PIN D20 [get_ports {cmv_lvds_data_p[25]}]
set_property PACKAGE_PIN G19 [get_ports {cmv_lvds_data_p[26]}]
set_property PACKAGE_PIN E21 [get_ports {cmv_lvds_data_p[27]}]
set_property PACKAGE_PIN D22 [get_ports {cmv_lvds_data_p[28]}]
set_property PACKAGE_PIN C17 [get_ports {cmv_lvds_data_p[29]}]
set_property PACKAGE_PIN B16 [get_ports {cmv_lvds_data_p[30]}]
set_property PACKAGE_PIN B21 [get_ports {cmv_lvds_data_p[31]}]

set_property IOSTANDARD LVDS_25 [get_ports cmv_lvds_*]


create_pblock pblock_lvds0
add_cells_to_pblock [get_pblocks pblock_lvds0] [get_cells GEN_LVDS[0]*/*]
resize_pblock [get_pblocks pblock_lvds0] -add {SLICE_X106Y69:SLICE_X113Y70}

create_pblock pblock_lvds1
add_cells_to_pblock [get_pblocks pblock_lvds1] [get_cells GEN_LVDS[1]*/*]
resize_pblock [get_pblocks pblock_lvds1] -add {SLICE_X106Y85:SLICE_X113Y86}

create_pblock pblock_lvds2
add_cells_to_pblock [get_pblocks pblock_lvds2] [get_cells GEN_LVDS[2]*/*]
resize_pblock [get_pblocks pblock_lvds2] -add {SLICE_X106Y57:SLICE_X113Y58}

create_pblock pblock_lvds3
add_cells_to_pblock [get_pblocks pblock_lvds3] [get_cells GEN_LVDS[3]*/*]
resize_pblock [get_pblocks pblock_lvds3] -add {SLICE_X106Y65:SLICE_X113Y66}

create_pblock pblock_lvds4
add_cells_to_pblock [get_pblocks pblock_lvds4] [get_cells GEN_LVDS[4]*/*]
resize_pblock [get_pblocks pblock_lvds4] -add {SLICE_X106Y91:SLICE_X113Y92}

create_pblock pblock_lvds5
add_cells_to_pblock [get_pblocks pblock_lvds5] [get_cells GEN_LVDS[5]*/*]
resize_pblock [get_pblocks pblock_lvds5] -add {SLICE_X106Y89:SLICE_X113Y90}

create_pblock pblock_lvds6
add_cells_to_pblock [get_pblocks pblock_lvds6] [get_cells GEN_LVDS[6]*/*]
resize_pblock [get_pblocks pblock_lvds6] -add {SLICE_X106Y123:SLICE_X113Y124}

create_pblock pblock_lvds7
add_cells_to_pblock [get_pblocks pblock_lvds7] [get_cells GEN_LVDS[7]*/*]
resize_pblock [get_pblocks pblock_lvds7] -add {SLICE_X106Y95:SLICE_X113Y96}

create_pblock pblock_lvds8
add_cells_to_pblock [get_pblocks pblock_lvds8] [get_cells GEN_LVDS[8]*/*]
resize_pblock [get_pblocks pblock_lvds8] -add {SLICE_X106Y141:SLICE_X113Y142}

create_pblock pblock_lvds9
add_cells_to_pblock [get_pblocks pblock_lvds9] [get_cells GEN_LVDS[9]*/*]
resize_pblock [get_pblocks pblock_lvds9] -add {SLICE_X106Y107:SLICE_X113Y108}

create_pblock pblock_lvds10
add_cells_to_pblock [get_pblocks pblock_lvds10] [get_cells GEN_LVDS[10]*/*]
resize_pblock [get_pblocks pblock_lvds10] -add {SLICE_X106Y143:SLICE_X113Y144}

create_pblock pblock_lvds11
add_cells_to_pblock [get_pblocks pblock_lvds11] [get_cells GEN_LVDS[11]*/*]
resize_pblock [get_pblocks pblock_lvds11] -add {SLICE_X106Y129:SLICE_X113Y130}

create_pblock pblock_lvds12
add_cells_to_pblock [get_pblocks pblock_lvds12] [get_cells GEN_LVDS[12]*/*]
resize_pblock [get_pblocks pblock_lvds12] -add {SLICE_X106Y139:SLICE_X113Y140}

create_pblock pblock_lvds13
add_cells_to_pblock [get_pblocks pblock_lvds13] [get_cells GEN_LVDS[13]*/*]
resize_pblock [get_pblocks pblock_lvds13] -add {SLICE_X106Y131:SLICE_X113Y132}

create_pblock pblock_lvds14
add_cells_to_pblock [get_pblocks pblock_lvds14] [get_cells GEN_LVDS[14]*/*]
resize_pblock [get_pblocks pblock_lvds14] -add {SLICE_X106Y135:SLICE_X113Y136}

create_pblock pblock_lvds15
add_cells_to_pblock [get_pblocks pblock_lvds15] [get_cells GEN_LVDS[15]*/*]
resize_pblock [get_pblocks pblock_lvds15] -add {SLICE_X106Y119:SLICE_X113Y120}

create_pblock pblock_lvds16
add_cells_to_pblock [get_pblocks pblock_lvds16] [get_cells GEN_LVDS[16]*/*]
resize_pblock [get_pblocks pblock_lvds16] -add {SLICE_X106Y73:SLICE_X113Y74}

create_pblock pblock_lvds17
add_cells_to_pblock [get_pblocks pblock_lvds17] [get_cells GEN_LVDS[17]*/*]
resize_pblock [get_pblocks pblock_lvds17] -add {SLICE_X106Y67:SLICE_X113Y68}

create_pblock pblock_lvds18
add_cells_to_pblock [get_pblocks pblock_lvds18] [get_cells GEN_LVDS[18]*/*]
resize_pblock [get_pblocks pblock_lvds18] -add {SLICE_X106Y79:SLICE_X113Y80}

create_pblock pblock_lvds19
add_cells_to_pblock [get_pblocks pblock_lvds19] [get_cells GEN_LVDS[19]*/*]
resize_pblock [get_pblocks pblock_lvds19] -add {SLICE_X106Y83:SLICE_X113Y84}

create_pblock pblock_lvds20
add_cells_to_pblock [get_pblocks pblock_lvds20] [get_cells GEN_LVDS[20]*/*]
resize_pblock [get_pblocks pblock_lvds20] -add {SLICE_X106Y55:SLICE_X113Y56}

create_pblock pblock_lvds21
add_cells_to_pblock [get_pblocks pblock_lvds21] [get_cells GEN_LVDS[21]*/*]
resize_pblock [get_pblocks pblock_lvds21] -add {SLICE_X106Y63:SLICE_X113Y64}

create_pblock pblock_lvds22
add_cells_to_pblock [get_pblocks pblock_lvds22] [get_cells GEN_LVDS[22]*/*]
resize_pblock [get_pblocks pblock_lvds22] -add {SLICE_X106Y77:SLICE_X113Y78}

create_pblock pblock_lvds23
add_cells_to_pblock [get_pblocks pblock_lvds23] [get_cells GEN_LVDS[23]*/*]
resize_pblock [get_pblocks pblock_lvds23] -add {SLICE_X106Y81:SLICE_X113Y82}

create_pblock pblock_lvds24
add_cells_to_pblock [get_pblocks pblock_lvds24] [get_cells GEN_LVDS[24]*/*]
resize_pblock [get_pblocks pblock_lvds24] -add {SLICE_X106Y105:SLICE_X113Y106}

create_pblock pblock_lvds25
add_cells_to_pblock [get_pblocks pblock_lvds25] [get_cells GEN_LVDS[25]*/*]
resize_pblock [get_pblocks pblock_lvds25] -add {SLICE_X106Y121:SLICE_X113Y122}

create_pblock pblock_lvds26
add_cells_to_pblock [get_pblocks pblock_lvds26] [get_cells GEN_LVDS[26]*/*]
resize_pblock [get_pblocks pblock_lvds26] -add {SLICE_X106Y109:SLICE_X113Y110}

create_pblock pblock_lvds27
add_cells_to_pblock [get_pblocks pblock_lvds27] [get_cells GEN_LVDS[27]*/*]
resize_pblock [get_pblocks pblock_lvds27] -add {SLICE_X106Y115:SLICE_X113Y116}

create_pblock pblock_lvds28
add_cells_to_pblock [get_pblocks pblock_lvds28] [get_cells GEN_LVDS[28]*/*]
resize_pblock [get_pblocks pblock_lvds28] -add {SLICE_X106Y117:SLICE_X113Y118}

create_pblock pblock_lvds29
add_cells_to_pblock [get_pblocks pblock_lvds29] [get_cells GEN_LVDS[29]*/*]
resize_pblock [get_pblocks pblock_lvds29] -add {SLICE_X106Y127:SLICE_X113Y128}

create_pblock pblock_lvds30
add_cells_to_pblock [get_pblocks pblock_lvds30] [get_cells GEN_LVDS[30]*/*]
resize_pblock [get_pblocks pblock_lvds30] -add {SLICE_X106Y133:SLICE_X113Y134}

create_pblock pblock_lvds31
add_cells_to_pblock [get_pblocks pblock_lvds31] [get_cells GEN_LVDS[31]*/*]
resize_pblock [get_pblocks pblock_lvds31] -add {SLICE_X106Y113:SLICE_X113Y114}

create_pblock pblock_lvds32
add_cells_to_pblock [get_pblocks pblock_lvds32] [get_cells GEN_LVDS[32]*/*]
resize_pblock [get_pblocks pblock_lvds32] -add {SLICE_X106Y71:SLICE_X113Y72}


# create_pblock pblock_comb0
# add_cells_to_pblock [get_pblocks pblock_comb0] [get_cells GEN_4TO1[0].*]
# resize_pblock [get_pblocks pblock_comb0] -add {SLICE_X54Y80:SLICE_X67Y84}
# resize_pblock [get_pblocks pblock_comb0] -add {RAMB36_X3Y16}

# create_pblock pblock_comb1
# add_cells_to_pblock [get_pblocks pblock_comb1] [get_cells GEN_4TO1[1].*]
# resize_pblock [get_pblocks pblock_comb1] -add {SLICE_X54Y85:SLICE_X67Y89}
# resize_pblock [get_pblocks pblock_comb1] -add {RAMB36_X3Y17}

# create_pblock pblock_comb2
# add_cells_to_pblock [get_pblocks pblock_comb2] [get_cells GEN_4TO1[2].*]
# resize_pblock [get_pblocks pblock_comb2] -add {SLICE_X54Y90:SLICE_X67Y94}
# resize_pblock [get_pblocks pblock_comb2] -add {RAMB36_X3Y18}

# create_pblock pblock_comb3
# add_cells_to_pblock [get_pblocks pblock_comb3] [get_cells GEN_4TO1[3].*]
# resize_pblock [get_pblocks pblock_comb3] -add {SLICE_X54Y95:SLICE_X67Y99}
# resize_pblock [get_pblocks pblock_comb3] -add {RAMB36_X3Y19}


# create_pblock pblock_comb4
# add_cells_to_pblock [get_pblocks pblock_comb4] [get_cells GEN_4TO1[4].*]
# resize_pblock [get_pblocks pblock_comb4] -add {SLICE_X54Y100:SLICE_X67Y104}
# resize_pblock [get_pblocks pblock_comb4] -add {RAMB36_X3Y20}

# create_pblock pblock_comb5
# add_cells_to_pblock [get_pblocks pblock_comb5] [get_cells GEN_4TO1[5].*]
# resize_pblock [get_pblocks pblock_comb5] -add {SLICE_X54Y105:SLICE_X67Y109}
# resize_pblock [get_pblocks pblock_comb5] -add {RAMB36_X3Y21}

# create_pblock pblock_comb6
# add_cells_to_pblock [get_pblocks pblock_comb6] [get_cells GEN_4TO1[6].*]
# resize_pblock [get_pblocks pblock_comb6] -add {SLICE_X54Y110:SLICE_X67Y114}
# resize_pblock [get_pblocks pblock_comb6] -add {RAMB36_X3Y22}

# create_pblock pblock_comb7
# add_cells_to_pblock [get_pblocks pblock_comb7] [get_cells GEN_4TO1[7].*]
# resize_pblock [get_pblocks pblock_comb7] -add {SLICE_X54Y115:SLICE_X67Y119}
# resize_pblock [get_pblocks pblock_comb7] -add {RAMB36_X3Y23}


# create_pblock pblock_writer0
# add_cells_to_pblock [get_pblocks pblock_writer0] [get_cells GEN_WRITER[0].*]
# resize_pblock [get_pblocks pblock_writer0] -add {SLICE_X80Y80:SLICE_X83Y99}
# resize_pblock [get_pblocks pblock_writer0] -add {SLICE_X28Y90:SLICE_X29Y99}
# resize_pblock [get_pblocks pblock_writer0] -add {RAMB36_X2Y18}
# resize_pblock [get_pblocks pblock_writer0] -add {RAMB18_X2Y36:RAMB18_X2Y37}

# create_pblock pblock_writer1
# add_cells_to_pblock [get_pblocks pblock_writer1] [get_cells GEN_WRITER[1].*]
# resize_pblock [get_pblocks pblock_writer1] -add {SLICE_X80Y100:SLICE_X83Y119}
# resize_pblock [get_pblocks pblock_writer1] -add {SLICE_X26Y90:SLICE_X27Y99}
# resize_pblock [get_pblocks pblock_writer1] -add {RAMB36_X2Y19}
# resize_pblock [get_pblocks pblock_writer1] -add {RAMB18_X2Y38:RAMB18_X2Y39}



# resize_pblock [get_pblocks pblock_fifo] -add {RAMB18_X5Y22:RAMB18_X5Y57}
# resize_pblock [get_pblocks pblock_fifo] -add {RAMB18_X4Y22:RAMB18_X4Y57}


set_property DONT_TOUCH TRUE [get_cells *.cmv_deser_inst*]

set_false_path -from [get_pins -filter {IS_CLOCK} reg_file_inst/oreg*/*]
