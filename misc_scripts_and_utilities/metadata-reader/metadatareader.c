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
			printf("number of used sensor lines (1..3072");
		if (i > 1 && i < 34)
			printf("Y_start");
		if (i > 33  && i < 66)
			printf("Y_size");
		if (i == 68) { // Color_exp[3] Bin_en[2] Sub_en[1] Color[0] 
			if ((get_bit(swap_endian(registers[i]), 3)))
				printf("Color_exp[3]: 1 - monochrome sensor, ");
			else
				printf("Color_exp[3]: 0 - color sensor, ");
			if ((get_bit(swap_endian(registers[i]), 2)))
				printf("Bin_en[2]: 1 - binning enabled, ");
			else
				printf("Bin_en[2]: 0 - binning disabled, ");
			if ((get_bit(swap_endian(registers[i]), 1)))
				printf("Sub_en[1]: 1 - image subsampling enabled, ");
			else
				printf("Sub_en[1]: 0 - image subsampling disabled, ");
			if ((get_bit(swap_endian(registers[i]), 0)))
				printf("Color[0]: 1 - monochrome sensor");
			else
				printf("Color[0]: 0 - color sensor");
		}
		if (i == 116) {
			printf("ADC_range - slope of the ramp used by the ADC: %d - ", get_bits(swap_endian(registers[i]), 0, 8));
			switch (get_bits(swap_endian(registers[i]), 0, 8)) {
				case 205:
					printf("8 bit mode, ");
					break;
				case 155:
					printf("10 bit mode, ");
					break;
				case 255:
					printf("12 bit mode, ");
					break;
			}
			printf("ADC_range_mult - slope of the ramp used by the ADC:  %d - ", get_bits(swap_endian(registers[i]), 8, 2));
			switch (get_bits(swap_endian(registers[i]), 8, 2)) {
				case 1:
					printf("8 bit mode, ");
					break;
				case 3:
					printf("10 bit mode, ");
					break;
				case 2:
					printf("12 bit mode, ");
					break;
			}	
		}
		
		printf ("\n");
	}

   	return 0;
}