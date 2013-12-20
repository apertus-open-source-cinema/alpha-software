#include <stdio.h>
#include <stdlib.h>

// TODO
char* Char2Binary (char c) {
	return c;
}

int main (int argc, char* argv[]) {
	char registers[256];
	char buff[8];
	ssize_t   n;
  	int total = 0;
	// read std in
	//fgets(registers, 256, stdin);
	int j = 0;
	while((n = fread(buff, 1, 1, stdin)) > 0) {
    		printf("+++%s+++\n",strlen(buff));
    		registers[j] = buff[0];
		j++;
	}
	registers[j] = "\n";

	//fread(registers, 256, 1, stdin);
   	//cin >> registers;

	printf ("%u bytes read from stdin\n", strlen(registers));

	// Header
	printf ("------------------------------------------------------------------------------\n");
	printf ("Register\tBinary 16bit\t\tHex\tDecimal\tComment\n");
	printf ("------------------------------------------------------------------------------\n");

	int i;
	for (i=0; i < strlen(registers); i++) {
		// two registers per line as we have 128x 16 bit registers
   		printf ("%d:\t", i/2);
	
		//Binary
		//TODO
		//printf ("%d:\t", Char2Binary(registers[i]));
		printf ("00000000 00000000");
		//Char2Binary(registers[i+1]);
		
		//Hex
		printf ("\t%X", registers[i]);
		printf (" ");
		printf ("%02X\t", (unsigned int)(registers[i+1] & 0xFF));

		/*		
		//Decimal
		printf ("%u\t", (unsigned int)(registers.at(i) & 0xFF)*256+(unsigned int)(registers.at(i+1) & 0xFF));

		//Comment
		if (i/2 == 0)
			printf("not used");
		if (i/2 == 1)
			printf("Number_lines_tot");
		if (i/2 > 1 && i/2 < 34)
			printf("Y_start");
		if (i/2 > 33  && i/2 < 66)
			printf("Y_size");*/

		
		printf ("\n");
		i++;
	}

   	return 0;
}
