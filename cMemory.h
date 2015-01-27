/* 
 * File:   cMemory.h
 * Author: dospro
 *
 * Created on 17 de enero de 2015, 09:08 PM
 */

#ifndef CMEMORY_H
#define	CMEMORY_H
#include "macros.h"

struct GBAHeader {
    char title[12];
	int romSize;
};

class cMemory {
public:
    cMemory();
    ~cMemory();

    bool loadRom(char *fileName);

	byte readByte(u32 address);
	void writeByte(u32 address, byte data);

	word readWord(u32 address);
	void writeWord(u32 address, word data);

	u32 readDword(u32 address);
	void writeDword(u32 address, u32 data);

private:
    GBAHeader header;
    byte *BIOSMemory; //16 KB
    byte *RomMemory; //Max 32MB
    byte *EWorkRam; //256 KB On board
    byte *IWorkRam; //32 KB on CPU
};

#endif	/* CMEMORY_H */

