#include <stdio.h>
#include <stdlib.h>
#include "stdint.h"


// TODO
char* Char2Binary (char c) {
	return c;
}

// TODO
uint16_t SwapEndian (uint16_t in) {
	return (in>>8) | (in<<8);
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
		printf ("00000000 00000000");
		//Char2Binary(registers[i+1]);
		

		//Hex
		printf ("\t%04X\t", (unsigned int)(SwapEndian(registers[i]) & 0xFFFF));

				
		//Decimal
		printf ("%u\t", (unsigned int)(SwapEndian(registers[i]) & 0xFFFF));


		//Comment
		if (i == 0)
			printf("not used");
		if (i == 1)
			printf("Number_lines_tot");
		if (i > 1 && i < 34)
			printf("Y_start");
		if (i > 33  && i < 66)
			printf("Y_size");
		
		printf ("\n");
	}

   	return 0;
}