/* 
* File:   cCpu.cpp
* Author: dospro
*         Jonatan Mendez Lopez
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
	return true;
}

u32 cCpu::cpsr()
{
	u32 data = 0;
	data = data | (modeBits & 0x1F);	//First the 5 bits of Mode Bits.
	data = data | (tFlag << 5);
	data = data | (fFlag << 6);
	data = data | (iFlag << 7);
	data = data | (qFlag << 27);
	data = data | (vFlag << 28);
	data = data | (cFlag << 29);
	data = data | (zFlag << 30);
	data = data | (nFlag << 31);
	return data;
}

void cCpu::cpsr(u32 value)
{
	modeBits = value & 0x1F;
	tFlag = (value >> 5) & 1;
	fFlag = (value >> 6) & 1;
	iFlag = (value >> 7) & 1;
	qFlag = (value >> 27) & 1;
	vFlag = (value >> 28) & 1;
	cFlag = (value >> 29) & 1;
	zFlag = (value >> 30) & 1;
	nFlag = (value >> 31) & 1;
}


void cCpu::executeOpcode()
{
	word opcode;
	byte offset, source, dest,operand;

	if (tFlag) 
	{
		// Thumb mode
		opcode = memory.readWord(Registers[15]);
		Registers[15]+=2;	// 16 bits increment

		if (opcode & 0xE000 == 0) { //Form 1/2
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
                                offset = (opcode >> 6) & 0x1F;
                                source = (opcode >> 3) & 0x7;
				dest = opcode & 3;
                                Registers[dest] = Registers[sourse] >> offset;
                                zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 0x1F) == 1);
				cyclesCount += 1;
				break;
			case 2:
                                
				break;
			case 3:
                                switch ((opcode & 0x600) >> 9){
                                    case 0:
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] + Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x1F) == 1);
                                        cFlag = (((Registers[operand] >> 0x8000) & (Registers[source] >> 0x8000)) == 1); //Verificar bandera e implementar VFlag
                                        break;
                                    case 1:
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] - Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x1F) == 1);
                                        cFlag = (((Registers[operand] >> 0x8000) & (Registers[source] >> 0x8000)) == 1);
                                        break;
                                    case 2: //Verificar si nn es una direcion o un dato como tal
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] - Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x1F) == 1);
                                        cFlag = (((Registers[operand] >> 0x8000) & (Registers[source] >> 0x8000)) == 1);
                                        break;
                                    case 3:
                                        break;
                                }
				break;
			}
		}
                if else (opcode & 0x2000 == 1){  //Form 3
                    switch ((opcode & 0x1800) >> 11){
                        case 0:
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
	else
	{
		// ARM Mode
	}
}
