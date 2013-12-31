/*
 * DNGReader.h
 *
 *  Created on: Oct 21, 2013
 *      Author: gcolburn
 */

#ifndef DNGREADER_H_
#define DNGREADER_H_

#include <stdio.h>
#include "IFD.h"
#include "IfdEntry.h"

class DNGReader {
public:
	DNGReader(const char*);
	int read();
	int close();
	void printIFDs();
	virtual ~DNGReader();
protected:
	FILE *ifp;
	const char *ifname;
	unsigned char endian[2];
	unsigned char magicNum[2];
	unsigned int ifd0offset;

	IFD ifd0;

	int readHeader();
	int readIFDs();
	int readIFDFromOffset(IFD &ifd, unsigned int offset);
	int readIFDEntry(IfdEntry &ifd);
};

#endif /* DNGREADER_H_ */
