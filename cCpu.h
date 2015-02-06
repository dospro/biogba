/* 
 * File:   cCpu.h
 * Author: dospro
 *         Jonatan Mendez Lopez
 * Created on 31 de enero de 2015, 09:29 PM
 */

#ifndef CCPU_H
#define	CCPU_H

#include"cMemory.h"

#define ARM_MODE 0
#define THUMB_MODE 1

class cCpu {
public:
    cCpu();
    cCpu(const cCpu& orig);
    virtual ~cCpu();
    
    bool initCpu();
private:
    
    void executeOpcode();

	u32 cpsr();
	void cpsr(u32 value);
    
    cMemory memory;
	
    bool nFlag, zFlag, cFlag, vFlag; 
	bool qFlag, iFlag, fFlag, tFlag;
	byte modeBits;		//Only 5 bits used
    u32 Registers[16];
    u32 FIQRegisters[7];
    
    u32 cyclesCount;

};

#endif	/* CCPU_H */

