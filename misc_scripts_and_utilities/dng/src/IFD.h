/*
 * IFD.h
 *
 *  Created on: Dec 27, 2013
 *      Author: gcolburn
 */

#ifndef IFD_H_
#define IFD_H_

#include <list>
#include "IfdEntry.h"

using namespace std;

class IFD {
public:
	IFD();
	void printIFDEntries();
	void printSubIFDs();
	IfdEntry getIFDEntry(int tag);
	virtual ~IFD();

	uint16 count;
	list<IfdEntry> entries;
	list<IFD> subIFDs;
};

#endif /* IFD_H_ */
