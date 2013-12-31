/*
 * IFD.cpp
 *
 *  Created on: Dec 27, 2013
 *      Author: gcolburn
 */

#include "IFD.h"

IFD::IFD() {
	// TODO Auto-generated constructor stub

}

IfdEntry IFD::getIFDEntry(int tag) {
	IfdEntry *foundEntry = 0;
	list<IfdEntry>::iterator entry;

	for( entry = entries.begin(); entry != entries.end(); ++entry) {
		if( (*entry).tag == tag ) {
			foundEntry = &(*entry);
		}
	}

	return *foundEntry;
}

void IFD::printIFDEntries() {
	list<IfdEntry>::iterator entry;

	printf("** Begin IFD **\n");
	for( entry = entries.begin(); entry != entries.end(); ++entry)
		(*entry).print();
	printf("** End IFD **\n\n");
}

void IFD::printSubIFDs() {
	list<IFD>::iterator ifd;

	for( ifd = subIFDs.begin(); ifd != subIFDs.end(); ++ifd)
		(*ifd).printIFDEntries();
}

IFD::~IFD() {
	// TODO Auto-generated destructor stub
}

