/*
 * DNGReader.cpp
 *
 *  Created on: Oct 21, 2013
 *      Author: gcolburn
 */

#include "DNGReader.h"
#include "IFD.h"
#include "IfdEntry.h"

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <float.h>
#include <limits.h>
#include <math.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>

DNGReader::DNGReader(const char *fileName) {
	ifname = fileName;
	this->ifd0 = IFD();
}

int DNGReader::read() {
	if (!(ifp = fopen (ifname, "rb"))) {
		perror (ifname);
		printf("Cannot read file ");
		return 0;
	}

	if(!readHeader())
		printf("Invalid DNG file.\n");
	if(!readIFDs())
		printf("Error reading IFDs!\n");
	return 1;
}

int DNGReader::readHeader() {
	bool valid = false;
	fseek (ifp, 0, SEEK_SET);
	fread (endian, 1, 2, ifp);
	valid = (endian[0] == 0x49 && endian[1] == 0x49);

	fread (magicNum, 1, 2, ifp);
	valid = valid && magicNum[0] == 0x2a && magicNum[1] == 0x00;
	fread (&ifd0offset, sizeof(ifd0offset), 1, ifp);

	return valid;
}

int DNGReader::readIFDs() {
	uint32 offset;
	uint32 tell;
	IFD *ifd;
	IFD newIFD;

	// Read first IFD
	offset = ifd0offset;
	ifd = &this->ifd0;

	readIFDFromOffset(*ifd, offset);
	fread (&offset, sizeof(offset), 1, ifp);
	if( offset != 0 )
		printf("Warning no end zero bytes\n");

	// Read subIFDs
	if( offset == 0) {
		IfdEntry subIFDEntry = ifd->getIFDEntry(330);
		offset = subIFDEntry.offset;
		fseek(ifp, offset, SEEK_SET);

		for( unsigned int i = 0; i < subIFDEntry.count; i++) {
			fread (&offset, sizeof(offset), 1, ifp);
			tell = ftell(ifp);

			newIFD = IFD();
			readIFDFromOffset(newIFD, offset);
			ifd->subIFDs.push_back(newIFD);

			fseek(ifp, tell, SEEK_SET);
		}
	}

	return 1;
}

int DNGReader::readIFDFromOffset(IFD &ifd, unsigned int offset) {

	fseek (ifp, offset, SEEK_SET);
	fread (&ifd.count, sizeof(ifd.count), 1, ifp);
	printf ("Count: %i\n", ifd.count);
	for( int i = 0; i < ifd.count; i++ ) {
		IfdEntry entry = IfdEntry();
		readIFDEntry(entry);
		ifd.entries.push_back(entry);
	}

	return 1;
}

int DNGReader::readIFDEntry(IfdEntry &entry) {
	entry.tell = ftell (ifp);
	fread (&entry.tag, sizeof(entry.tag), 1, ifp);
	fread (&entry.type, sizeof(entry.type), 1, ifp);
	fread (&entry.count, sizeof(entry.count), 1, ifp);
	fread (&entry.offset, sizeof(entry.offset), 1, ifp);
	return 1;
}

void DNGReader::printIFDs() {
	this->ifd0.printIFDEntries();
	this->ifd0.printSubIFDs();
}

int DNGReader::close() {
	fclose(ifp);
	return 0;
}

DNGReader::~DNGReader() {
	// TODO Auto-generated destructor stub
}

