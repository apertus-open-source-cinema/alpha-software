/*
 * TiffIfd.cpp
 *
 *  Created on: Oct 21, 2013
 *      Author: gcolburn
 */

#include "IfdEntry.h"

#include <stdio.h>

IfdEntry::IfdEntry() {

}

IfdEntry::IfdEntry(const IfdEntry &copyin) {
	this->tag = copyin.tag;
	this->type = copyin.type;
	this->count = copyin.count;
	this->offset = copyin.offset;
	this->tell = copyin.tell;
}

void IfdEntry::print() {
	printf("IFD: %i, %i, %i, %i, %i\n",this->tag, this->type, this->count, this->offset, this->tell );
}

IfdEntry& IfdEntry::operator=(const IfdEntry &rhs) {
	this->tag = rhs.tag;
	this->type = rhs.type;
	this->count = rhs.count;
	this->offset = rhs.offset;
	this->tell = rhs.tell;

	return *this;
}

int IfdEntry::operator==(const IfdEntry &rhs) const {
	if( this->tag != rhs.tag ) return 0;
	if( this->type != rhs.type ) return 0;
	if( this->count != rhs.count ) return 0;
	if( this->offset != rhs.offset ) return 0;
	if( this->tell != rhs.tell ) return 0;

	return 1;
}

int IfdEntry::operator<(const IfdEntry &rhs) const {
	return this->tag < rhs.tag;
}

IfdEntry::~IfdEntry() {
	// TODO Auto-generated destructor stub
}

