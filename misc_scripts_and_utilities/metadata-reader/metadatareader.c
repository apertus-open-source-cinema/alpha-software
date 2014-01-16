/*
----------------------------------------------------------------------------
-- metadatareader.c
--        read the 128x16bit block via piped stdin and display it in a human
--	      readable format
--        Version 1.1
--
-- Copyright (C) 2013 Sebastian Pichelhofer,
--                    Simon Larcher
--
--        This program is free software: you can redistribute it and/or
--        modify it under the terms of the GNU General Public License
--        as published by the Free Software Foundation, either version
--        2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------
*/


#include <stdio.h>
#include <stdlib.h>
#include "stdint.h"

typedef int bool;
#define true 1
#define false 0

uint16_t swap_endian (uint16_t in, bool swap) {
	if (swap)
		return (in>>8) | (in<<8);
	else
		return in;
}

bool get_bit (uint16_t in, int bit) {
	return (in & (1 << bit)) >> bit;
}

void print_binary (uint16_t in, bool swap) {
	int bit;
	char returnvalue[16];
	for(bit=0; bit < 16; bit++) {
		if (bit == 8)
			printf(" %d", get_bit(swap_endian(in, swap), 15-bit));
		else
			printf("%d", get_bit(swap_endian(in, swap), 15-bit));

	}
}

// extract range of bits with offset and length from LSB
uint16_t get_bits (uint16_t in, int offset, int length) {
	uint16_t in1 = in >> offset;	
	uint16_t in2 = in1 << 16-length;	
	uint16_t in3 = in2 >> 16-length;	
	return in3;
}


int main (int argc, char* argv[]) {
	
	//Deal with argument
	bool raw_register = false;
	bool swap_endianess = false;
	if (argc > 1) {
		if (strcmp (argv[1], "-h") == 0) {	
			printf( "%s Version 0.1\noptions are:\n-h\tprint this help message\n-r\tprint raw registers\n-swap-endian\tswap endianess of piped binary input", argv[0]);
			return 0;
		} else {
			if (strcmp (argv[1], "-r") == 0)
				raw_register = true;
			if (strcmp (argv[1], "-swap-endian") == 0)
				swap_endianess = true;
		} 
	}


	uint16_t registers[128];

	// read std in
	int n;
	n = read(0, registers, sizeof(registers));
	printf ("%u bytes read from stdin\n", n);


	// Header
	if (raw_register) {
		printf ("\n-----------------------------------------------------------------------------------\n");
		printf ("Register\tBinary\t\t\tHex\tDecimal\n");
		printf ("Register\tName\t\t\tDecimal\t\tMeaning\t\tDescription\n");
		printf ("-----------------------------------------------------------------------------------\n");
	
	} else {
		printf ("\n-----------------------------------------------------------------------------------\n");
		printf ("Register\tName\t\t\tDecimal\t\tMeaning\t\tDescription\n");
		printf ("-----------------------------------------------------------------------------------\n");
	}
	int i;
	for (i=0; i < 128; i++) {
		// Raw Registers
 		if (raw_register) {
			printf ("\n");

			//Register Number
	   		printf ("%d:\t\t", i);
	
			//Binary
			print_binary(registers[i], swap_endianess);

			//Hex
			printf ("\t%04X\t", (unsigned int)(swap_endian(registers[i], swap_endianess) & 0xFFFF));
				
			//Decimal
			printf ("%u\t\n", (unsigned int)(swap_endian(registers[i], swap_endianess) & 0xFFFF));
		}

		// Human Readable Register 
		if (i == 0)
			printf("0\t\tnot used");
		if (i == 1)
			printf("\n1[15:0]\t\tNumber_lines_tot:\t%d\t\tnumber of used sensor lines\n", swap_endian(registers[i], swap_endianess));
		if (i > 1 && i < 10)
			printf("%u[15:0]\t\tY_start:\t\t%d\n",i ,swap_endian(registers[i], swap_endianess));
		if (i > 9 && i < 34)
			printf("%u[15:0]\tY_start:\t\t%d\n",i ,swap_endian(registers[i], swap_endianess));
		if (i > 33  && i < 66)
			printf("%u[15:0]\tY_size:\t\t\t%d\n",i ,swap_endian(registers[i], swap_endianess));

		if (i == 66) {
			// Repeat Header to increase readability
			if (raw_register) {
				printf ("\n-----------------------------------------------------------------------------------\n");
				printf ("Register\tBinary\t\t\tHex\tDecimal\n");
				printf ("Register\tName\t\t\tDecimal\t\tMeaning\t\tDescription\n");
				printf ("-----------------------------------------------------------------------------------\n");
	
			} else {
				printf ("\n-----------------------------------------------------------------------------------\n");
				printf ("Register\tName\t\t\tDecimal\t\tMeaning\t\tDescription\n");
				printf ("-----------------------------------------------------------------------------------\n");
			}

			printf("%u[15:0]\tSub_offset:\t\t%d\n",i ,swap_endian(registers[i], swap_endianess));
		}
		if (i == 67)
			printf("%u[15:0]\tSub_step:\t\t%d\n",i ,swap_endian(registers[i], swap_endianess));
		if (i == 68) {
			//printf("\n");
			if ((get_bit(swap_endian(registers[i], swap_endianess), 3)))
				printf("68[3]\t\tColor_exp:\t\t1\t\tmonochrome sensor");
			else
				printf("68[3]\t\tColor_exp:\t\t0\t\tcolor sensor");
			printf("\n");
			if ((get_bit(swap_endian(registers[i], swap_endianess), 2)))
				printf("68[2]\t\tBin_en:\t\t\t1\t\tbinning enabled");
			else
				printf("68[2]\t\tBin_en:\t\t\t0\t\tbinning disabled");
			printf("\n");
			if ((get_bit(swap_endian(registers[i], swap_endianess), 1)))
				printf("68[1]\t\tSub_en:\t\t\t1\t\timage subsampling enabled");
			else
				printf("68[1]\t\tSub_en:\t\t\t0\t\timage subsampling disabled");
			printf("\n");
			if ((get_bit(swap_endian(registers[i], swap_endianess), 0)))
				printf("68[0]\t\tColor:\t\t\t1\t\tmonochrome sensor");
			else
				printf("68[0]\t\tColor:\t\t\t0\t\tcolor sensor");
		}
		if (i == 69) {
			printf("\n%u[1:0]\t\tImage_flipping:\t\t%d\t\t",i ,get_bits(swap_endian(registers[i], swap_endianess), 0, 2));
			switch (get_bits(swap_endian(registers[i], swap_endianess), 0, 2)) {
				case 0:
					printf("No image flipping");
					break;
				case 1:
					printf("Image flipping in X");
					break;
				case 2:
					printf("Image flipping in Y");
					break;				
				case 3:
					printf("Image flipping in X and Y");
					break;
			}
		}
		if (i == 70) {
			printf("\n%u[0]\t\tExp_dual:\t\t%d\t\t",i ,get_bits(swap_endian(registers[i], swap_endianess), 0, 1));
			if (get_bits(swap_endian(registers[i], swap_endianess), 0, 1))
				printf("ON");
			else
				printf("OFF");
			printf("\t\tHDR interleaved coloumn mode\n");
			printf("%u[1]\t\tExp_ext:\t\t%d\t\t",i ,get_bits(swap_endian(registers[i], swap_endianess), 1, 1));
			if (get_bits(swap_endian(registers[i], swap_endianess), 1, 1))
				printf("External Exposure Mode");
			else
				printf("Internal Exposure Mode");
		}
		if (i == 71) {
			printf("\n%u[15:0]\tExp_time:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Time Part 1");
		}
		if (i == 72) {
			printf("\n%u[23:16]\tExp_time:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Time Part 2");
			printf("\n%u[23:0]\tExp_time:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess)*65536+swap_endian(registers[i-1], swap_endianess));
			printf("Exposure Time (combined)");
			//TODO:
			/*printf("\n\t\tExposure Time:\t\t%d\t\t", i, ?);
			printf("Exposure Time (ms)");*/
		}
if (i == 73) {
			// For dual exposure (?)
			printf("\n%u[15:0]\tExp_time2:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Time 2 Part 1");
		}
		if (i == 74) {
			// For dual exposure (?)
			printf("\n%u[23:16]\tExp_time2:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Time 2 Part 2");
			printf("\n%u[23:0]\tExp_time2:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess)*65536+swap_endian(registers[i-1], swap_endianess));
			printf("Exposure Time 2 (combined)");
			//TODO:
			/*printf("\n\t\tExposure Time 2:\t\t%d\t\t", i, ?);
			printf("Exposure Time 2 (ms)");*/
		}
		if (i == 75) {
			// For pseudo logatithmic response curve (SDR) (?)
			printf("\n%u[15:0]\tExp_kp1:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Knee Point 1 Part 1");
		}
		if (i == 76) {
			// For pseudo logatithmic response curve (SDR) (?)
			printf("\n%u[23:16]\tExp_kp1:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Knee Point 1 Part 2");
			printf("\n%u[23:0]\tExp_kp1:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess)*65536+swap_endian(registers[i-1], swap_endianess));
			printf("Exposure Knee Point 1 (combined)");
			//TODO:
			/*printf("\n\t\tExposure Knee Point 1:\t\t%d\t\t", i, ?);
			printf("Exposure Knee Point 1 (ms)");*/
		}
		if (i == 77) {
			// For pseudo logatithmic response curve (SDR) (?)
			printf("\n%u[15:0]\tExp_kp2:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Knee Point 2 Part 1");
		}
		if (i == 78) {
			// For pseudo logatithmic response curve (SDR) (?)
			printf("\n%u[23:16]\tExp_kp2:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("Exposure Knee Point 2 Part 2");
			printf("\n%u[23:0]\tExp_kp1:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess)*65536+swap_endian(registers[i-1], swap_endianess));
			printf("Exposure Knee Point 2 (combined)");
			//TODO:
			/*printf("\n\t\tExposure Knee Point 2:\t\t%d\t\t", i, ?);
			printf("Exposure Knee Point 2 (ms)");*/
		}
		if (i == 79) {
			printf("\n%u[1:0]\t\tNumber_slopes:\t\t%d\t\t", i, get_bits(swap_endian(registers[i], swap_endianess), 0, 2));
			switch (get_bits(swap_endian(registers[i], swap_endianess), 0, 2)) {
				case 1:
					printf("1 slope");
					break;
				case 2:
					printf("2 slopes");
					break;
				case 3:
					printf("3 slopes");
					break;
				}
		}
		if (i == 80) {
			printf("\n%u[15:0]\tNumber_frames:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("%d\t\tNumber of frames to grab and send (intern exp. only)", swap_endian(registers[i], swap_endianess));	
		}
		if (i == 81) {
			printf("\n%u[4:0]\t\tOutput_mode:\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 0, 5) );
			switch (get_bits(swap_endian(registers[i], swap_endianess), 0, 5)) {
				case 0:
					printf("32 outputs");
					break;
				case 1:
					printf("16 outputs");
					break;
				case 3:
					printf("8 outputs");
					break;
				case 7:
					printf("4 outputs");
					break;
				case 15:
					printf("2 outputs");
					break;
				case 31:
					printf("1 outputs");
					break;
				}
			printf("\tNumber of LVDS channels used on each side");
			printf("\n%u[5]\t\tDisable_top:\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 5, 1) );
			if (get_bits(swap_endian(registers[i], swap_endianess), 5, 1))
				printf("Bottom LVDS outputs only");
			else
				printf("Two sided read-out (top and bottom)");
		}
		if ( i == 82 ) {
			printf("\n%u[15:0]\tSetting_1:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("\t\tAdditional register setting 1");
		}
		if ( i == 83 ) {
			printf("\n%u[15:0]\tSetting_2:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("\t\tAdditional register setting 2");
		}
		if ( i == 84 ) {
			printf("\n%u[15:0]\tSetting_3:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("\t\tAdditional register setting 3");
		}
		if ( i == 85 ) {
			printf("\n%u[15:0]\tSetting_4:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("\t\tAdditional register setting 4");
		}
		if ( i == 86 ) {
			printf("\n%u[15:0]\tSetting_5:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("\t\tAdditional register setting 5");
		}
		// This is assuming all unused bits that are not in the given range are set to 0, for range [11:0] here bits 12 to 15.
		if ( i == 87 ) {
			printf("\n%u[11:0]\tOffset_bot:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("%d\t\tDark level offset on bottom output signal", swap_endian(registers[i], swap_endianess));
		}
		if ( i == 88 ) {
			printf("\n%u[11:0]\tOffset_top:\t\t%d\t\t", i, swap_endian(registers[i], swap_endianess));
			printf("%d\t\tDark level offset on top output signal", swap_endian(registers[i], swap_endianess));
		}
		if ( i == 89 ) {
			printf("\n%u[11:0]\tTraining_pattern:\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 0, 12) );
			printf("%d\t\tValue sent over LVDS when no valid image data is sent", get_bits(swap_endian(registers[i], swap_endianess), 0, 12));

			printf("\n%u[15]\t\tBlack_col_en:\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 15, 1) );
			if (get_bits(swap_endian(registers[i], swap_endianess), 5, 1))
				printf("Enabled");
			else
				printf("Disabled");
			printf("\t\tElectrical black reference columns");
		}
		if ( i == 90 ) {
			printf("\n%u[15:0]\tChannel_en_bot\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 0, 16) );
			printf("--\t\tBottom data output channel (See register 91)");
		}
		if ( i == 91 ) {
			printf("\n%u[31:16]\tChannel_en_bot\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 0, 16) );
			if ( get_bits(swap_endian(registers[i - 1], swap_endianess), 0, 16) || (get_bits(swap_endian(registers[i], swap_endianess), 0, 16) << 16))
				printf("Enabled\t\tBottom data output channel");
			else
				printf("Disabled\t\tBottom data output channel");
		}
		if ( i == 92 ) {
			printf("\n%u[15:0]\tChannel_en_top\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 0, 16) );
			printf("--\t\tTop data output channel (See register 93)");
		}
		if ( i == 93 ) {
			printf("\n%u[31:16]\tChannel_en_top\t\t%d\t\t", i,get_bits(swap_endian(registers[i], swap_endianess), 0, 16) );
			if ( get_bits(swap_endian(registers[i - 1], swap_endianess), 0, 16) || (get_bits(swap_endian(registers[i], swap_endianess), 0, 16) << 16))
				printf("Enabled\t\tTop data output channel");
			else
				printf("Disabled\t\tTop data output channel");
		}
		if (i == 115) {
			printf("\n115[3]\t\tPGA_div:\t\t%d\t\t", get_bits(swap_endian(registers[i], swap_endianess), 3, 1));
			if (get_bits(swap_endian(registers[i], swap_endianess), 3, 1))
				printf("ON");
			else
				printf("OFF");
			printf("\t\tdivide signal by 3");
			printf("\n115[2:0]\tPGA_gain:\t\t%d\t\t", get_bits(swap_endian(registers[i], swap_endianess), 0, 3));
			switch (get_bits(swap_endian(registers[i], swap_endianess), 0, 3)) {
				case 0:
					printf("unity gain");
					break;
				case 1:
					printf("x2 gain");
					break;
				case 3:
					printf("x3 gain");
					break;				
				case 7:
					printf("x4 gain");
					break;
			}
			printf("\n");
		}

		if (i == 116) {
			printf("116[7:0]\tADC_range:\t\t%d\t\t", get_bits(swap_endian(registers[i], swap_endianess), 0, 8));
			switch (get_bits(swap_endian(registers[i], swap_endianess), 0, 8)) {
				case 205:
					printf("8 bit mode");
					break;
				case 155:
					printf("10 bit mode");
					break;
				case 255:
					printf("12 bit mode");
					break;
				default:
					printf("no specific bit mode");
					break;
			}
			printf("\tslope of the ramp used by the ADC\n");

			printf("116[9:8]\tADC_range_mult:\t\t%d\t\t", get_bits(swap_endian(registers[i], swap_endianess), 8, 2));
			switch (get_bits(swap_endian(registers[i], swap_endianess), 8, 2)) {
				case 1:
					printf("8 bit mode");
					break;
				case 3:
					printf("10 bit mode");
					break;
				case 2: // TODO: this cant be right in the datasheet
					printf("12 bit mode");
					break;
			}
			printf("\n");
		}
		
		
	}
	printf("\n");
   	return 0;
}