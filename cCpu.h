/* 
 * File:   cCpu.h
 * Author: dospro
 *
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
    
    cMemory memory;
    int cpuMode;    //ARM or Thumb mode
    
    bool zFlag, nFlag, cFlag;
    u32 Registers[16];
    u32 FIQRegisters[8];
    
    u32 cyclesCount;

};

#endif	/* CCPU_H */

