#include <stdio.h>
#include <stdlib.h>
#include "stdint.h"

typedef int bool;
#define true 1
#define false 0

// TODO
char* int2binary (uint16_t in) {
	return "00000000 00000000";
}

uint16_t swap_endian (uint16_t in) {
	return (in>>8) | (in<<8);
}

bool get_bit (uint16_t in, int bit) {
	return (in & (1 << bit));
}

// extract range of bits with offset and length from LSB
uint16_t get_bits (uint16_t in, int offset, int length) {
	uint16_t in1 = in >> offset;	
	uint16_t in2 = in1 << 16-length;	
	uint16_t in3 = in2 >> 16-length;	
	return in3;
}


int main (int argc, char* argv[]) {
	uint16_t registers[128];

	// read std in
	int n;
	n = read(0, registers, sizeof(registers));
	printf ("%u bytes read from stdin\n", n);

	// Header
	printf ("------------------------------------------------------------------------------\n");
	printf ("Register\tBinary 16bit\t\tHex\tDecimal\tComment\n");
	printf ("------------------------------------------------------------------------------\n");

	int i;
	for (i=0; i < 128; i++) {
		//Register Number
   		printf ("%d:\t\t", i);
	
		//Binary
		//TODO
		//printf ("%d:\t", Char2Binary(registers[i]));
		printf (int2binary(registers[i]));
		//Char2Binary(registers[i+1]);
		

		//Hex
		printf ("\t%04X\t", (unsigned int)(swap_endian(registers[i]) & 0xFFFF));

				
		//Decimal
		printf ("%u\t", (unsigned int)(swap_endian(registers[i]) & 0xFFFF));


		//Comment
		if (i == 0)
			printf("not used");
		if (i == 1)
			printf("\n1[15:0]\t\tNumber_lines_tot:\t%d\tnumber of used sensor lines\n", swap_endian(registers[i]));
		if (i > 1 && i < 34)
			printf("Y_start");
		if (i > 33  && i < 66)
			printf("Y_size");
		if (i == 68) {
			printf("\n");
			if ((get_bit(swap_endian(registers[i]), 3)))
				printf("68[3]\t\tColor_exp:\t1\tmonochrome sensor");
			else
				printf("68[3]\t\tColor_exp:\t0\tcolor sensor");
			printf("\n");
			if ((get_bit(swap_endian(registers[i]), 2)))
				printf("68[2]\t\tBin_en:\t\t1\tbinning enabled");
			else
				printf("68[2]\t\tBin_en:\t\t0\tbinning disabled");
			printf("\n");
			if ((get_bit(swap_endian(registers[i]), 1)))
				printf("68[1]\t\tSub_en:\t\t1\timage subsampling enabled");
			else
				printf("68[1]\t\tSub_en:\t\t0\timage subsampling disabled");
			printf("\n");
			if ((get_bit(swap_endian(registers[i]), 0)))
				printf("68[0]\t\tColor:\t\t1\tmonochrome sensor");
			else
				printf("68[0]\t\tColor:\t\t0\tcolor sensor");
		}
		if (i == 115) {
			printf("\n115[2:0]\tPGA_gain():\t\t%d\t", get_bits(swap_endian(registers[i]), 0, 3));
			switch (get_bits(swap_endian(registers[i]), 0, 3)) {
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
			printf("\n116[7:0]\tADC_range:\t\t%d\t", get_bits(swap_endian(registers[i]), 0, 8));
			switch (get_bits(swap_endian(registers[i]), 0, 8)) {
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

			printf("116[9:8]\tADC_range_mult:\t\t%d\t", get_bits(swap_endian(registers[i]), 8, 2));
			switch (get_bits(swap_endian(registers[i]), 8, 2)) {
				case 1:
					printf("8 bit mode");
					break;
				case 3:
					printf("10 bit mode");
					break;
				case 2:
					printf("12 bit mode");
					break;
			}
			printf("\n");
		}
		
		printf ("\n");
	}

   	return 0;
}