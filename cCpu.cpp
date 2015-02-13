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
	byte offset, source, dest, operand;

	if (tFlag) 
	{
		// Thumb mode
		opcode = memory.readWord(Registers[15]);
		Registers[15]+=2;	// 16 bits increment

		if (opcode & 0xE000 == 0) { //Form 1 and 2
			switch ((opcode & 0x1800) >> 11) {
			case 0:
				offset = (opcode >> 6) & 0x1F;
				source = (opcode >> 3) & 0x7;
				dest = opcode & 3;
				Registers[dest] = Registers[source] << offset;
				zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                cFlag = (); 
                                vFlag = false;
				cyclesCount += 1;
				break;
			case 1:
                                offset = (opcode >> 6) & 0x1F;
                                source = (opcode >> 3) & 0x7;
				dest = opcode & 3;
                                Registers[dest] = Registers[sourse] >> offset;
                                zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                cFlag = (); 
                                vFlag = false;
				cyclesCount += 1;
				break;
			case 2:
                                offset = (opcode >> 6) & 0x1F;
                                source = (opcode >> 3) & 0x7;
                                dest = opcode & 3;
                                Registers[dest] = Registers[sourse] >> offset;
                                zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                cFlag = (); 
                                vFlag = false;
				cyclesCount += 1;
				break;
			case 3:
                                switch ((opcode & 0x600) >> 9){
                                    case 0:
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] + Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                        cFlag = (((Registers[operand] >> 0x80000000) & (Registers[source] >> 0x80000000)) == 1); //Check this
                                        vFlag = ((Registers[source] + Registers[operand]) == 0xFFFF);
                                        cyclesCount += 1;
                                        break;
                                    case 1:
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] - Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                        cFlag = (((Registers[operand] >> 0x80000000) & (Registers[source] >> 0x80000000)) == 1);
                                        vFlag = ((Registers[dest] = Registers[source] - Registers[operand]) == 0xFFFF);
                                        cyclesCount += 1;
                                        break;
                                    case 2: 
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] + operand;
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                        cFlag = (((Registers[dest] >> 0x80000000) & (Registers[source] >> 0x80000000)) == 0);
                                        vFlag = ();
                                        cyclesCount += 1;
                                        break;
                                    case 3:
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] - operand;
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                        cFlag = (((Registers[dest] >> 0x80000000) & (Registers[source] >> 0x80000000)) == 0);
                                        vFlag = ();
                                        cyclesCount += 1;
                                        break;
                                }
				break;
			}
		}
                if else (opcode & 0x2000 == 1){  //Form 3
                    switch ((opcode & 0x1800) >> 11){
                        case 0:
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            Registers[dest] = operand;
                            zFlag = (Registers[dest] == 0);
                            nFlag = ((Registers[dest] >> 0x80000000) == 1);
                            cyclesCount += 1;
                            break;
                        case 1:
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            zFlag = (( Registers[dest] - operand) == 0);
                            nFlag = (((( Registers[dest] - operand) >> 30) & 0x80000000) == 1);
                            cFlag = (((( Registers[dest] - operand) >> 30) & 0x80000000) == 1); // Check this
                            vFlag = ((( Registers[dest] - operand) & 0xFFFF) == 1);
                            cyclesCount += 1;
                            break;
                        case 2:
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            Registers[dest] += operand;
                            zFlag = (Registers[dest] == 0);
                            nFlag = ((Registers[dest] >> 0x80000000) == 1);
                            cFlag = ();
                            vFlag = ();
                            cyclesCount += 1;
                            break;
                        case 3:
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            Registers[dest] -= operand;
                            zFlag = (Registers[dest] == 0);
                            nFlag = ((Registers[dest] >> 0x80000000) == 1);
                            cFlag = ();
                            vFlag = ();
                            cyclesCount += 1;
                            break;
                    }
                }
                if else (opcode & 0x4000 == 1){
                    switch ((opcode & 0x3C00) >> 9){
                        case 0: //Form 4
                             switch ((opcode & 0x3C0) >> 5){
                                 case 0: //AND Rd,Rs
                                     sourse = (opcode & 0x38) >> 2;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[sourse] & Registers[dest];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                     cFlag = ();
                                     vFlag = ();
                                     break;
                                 case 1: //EOX Rd,Rs
                                     sourse = (opcode & 0x38) >> 2;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[sourse] ^ Registers[dest];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                     cFlag = ();
                                     vFlag = ();
                                     break;
                                 case 2: //LSL Rd,Rs
                                     sourse = (opcode & 0x38) >> 2;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] << (Registers[sourse] & 0xFF);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                     cFlag = ();
                                     vFlag = false;
                                     break;
                                 case 3: //LSR Rd,Rs
                                     sourse = (opcode & 0x38) >> 2;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] >> (Registers[sourse] & 0xFF);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                     cFlag = ();
                                     vFlag = false;
                                     break;
                                 case 4: //ASR Rd,Rs
                                     sourse = (opcode & 0x38) >> 2;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] >> (Registers[sourse] & 0xFF); //Check this
                                     zFlag = false;
                                     nFlag = false;
                                     cFlag = ();
                                     vFlag = false;
                                     break;
                                 case 5: //ADC Rd,Rs  Check how add carry bit 
                                     sourse = (opcode & 0x38) >> 2;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] + Registers[sourse];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 0x80000000) == 1);
                                     cFlag = ();
                                     vFlag = ();
                                     break;
                                 case 6:
                                     break;
                                 case 7:
                                     break;
                                 case 8:
                                     break;
                                 case 9:
                                     break;
                                 case 0xA:
                                     break;
                                 case 0xB:
                                     break;
                                 case 0xC:
                                     break;
                                 case 0xD:
                                     break;
                                 case 0xE:
                                     break;
                                 case 0xF:
                                     break;
                             }
                            break;
                        case 1: //Form 5
                            
                            break;
                    }
                    
                }
	}
	else
	{
		// ARM Mode
	}
}
