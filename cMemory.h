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
};

class cMemory {
public:
    cMemory();
    ~cMemory();

    bool loadRom(char *fileName);
private:
    GBAHeader header;
    u32 *BIOSMemory; //16 KB
    word *RomMemory; //Max 32MB
    word *EWorkRam; //256 KB On board
    u32 *IWorkRam; //32 KB on CPU
};

#endif	/* CMEMORY_H */

