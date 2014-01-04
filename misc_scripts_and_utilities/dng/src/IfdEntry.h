/*
 * TiffIfd.h
 *
 *  Created on: Oct 21, 2013
 *      Author: gcolburn
 */

#ifndef IFDENTRY_H_
#define IFDENTRY_H_
#include "stdint.h"

class IfdEntry {
public:
	IfdEntry();
	IfdEntry(const IfdEntry &copyin);
	IfdEntry &operator=(const IfdEntry &rhs);
	int operator==(const IfdEntry &rhs) const;
	int operator<(const IfdEntry &rhs) const;
	virtual ~IfdEntry();

	uint16 tag;
	uint16 type;
	uint32 count;
	uint32 offset;
	uint32 tell;

	void print();
};

#endif /* IFD_H_ */
