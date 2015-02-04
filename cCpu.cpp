/* 
* File:   cCpu.cpp
* Author: dospro
* 
* Created on 31 de enero de 2015, 09:29 PM
*/

#include "cCpu.h"

cCpu::cCpu()
{
}

cCpu::cCpu(const cCpu& orig)
{
}

cCpu::~cCpu()
{
}

bool cCpu::initCpu()
{
	cpuMode = ARM_MODE;
	return true;
}

void cCpu::executeOpcode()
{
	word opcode;
	byte offset, source, dest;

	if (cpuMode == ARM_MODE) {
	}
	else if (cpuMode == THUMB_MODE) 
	{
		opcode = memory.readWord(Registers[15]);
		Registers[15]+=2;	//16 bits increment

		if (opcode & 0xE000 == 0) {
			switch ((opcode & 0x1800) >> 11) {
			case 0:
				offset = (opcode >> 6) & 0x1F;
				source = (opcode >> 3) & 0x7;
				dest = opcode & 3;
				Registers[dest] = Registers[source] << offset;
				zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 0x1F) == 1);
				cyclesCount += 1;
				break;
			case 1:
				break;
			case 2:
				break;
			case 3:
				break;
			}
		}
	}
}
