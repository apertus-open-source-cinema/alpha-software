//============================================================================
// Name        : dngwriter.cpp
// Author      : 
// Version     :
// Copyright   : Gabriel Colburn
// Description : Writes CMV12000 data to DNG file
//============================================================================

#include <iostream>
#include "DNGReader.h"
using namespace std;

int main (int argc, const char **argv) {
	const char* ifname = argv[1];

	cout << "DNG Writer 0.1" << endl;

	DNGReader reader = DNGReader(ifname);

	printf("Reading dng: %s\n", ifname);
	reader.read();
	reader.printIFDs();
	reader.close();
	return 0;
}
