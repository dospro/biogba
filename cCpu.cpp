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
	byte offset, source, dest, operand, h1, h2;

	if (tFlag) 
	{
		// Thumb mode
		opcode = memory.readWord(Registers[15]);
		Registers[15]+=2;	// 16 bits increment

		if (opcode & 0xE000 == 0) { //Form 1 and 2
			switch ((opcode & 0x1800) >> 11) {
			case 0: //LSL Rd,Rs,#
				offset = (opcode >> 6) & 0x1F;
				source = (opcode >> 3) & 0x7;
				dest = opcode & 3;
				Registers[dest] = Registers[source] << offset;
				zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 31) == 1);
                                cFlag = ((Registers[source] << offset) >> 32) != 0; 
                                vFlag = false;
				cyclesCount += 1;
				break;
			case 1: //LSR Rd,Rs,#
                                offset = (opcode >> 6) & 0x1F;
                                source = (opcode >> 3) & 0x7;
				dest = opcode & 3;
                                Registers[dest] = Registers[sourse] >> offset;
                                zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 31) == 1);
                                cFlag = (((Registers[source] >> offset) >> 32) != 0); 
                                vFlag = false;
				cyclesCount += 1;
				break;
			case 2: //ASR Rd,Rs,#
                                offset = (opcode >> 6) & 0x1F;
                                source = (opcode >> 3) & 0x7;
                                dest = opcode & 3;
                                Registers[dest] = Registers[sourse] >> offset;
                                zFlag = (Registers[dest] == 0);
				nFlag = ((Registers[dest] >> 31) == 1);
                                cFlag = (((Registers[source] >> offset) >> 32) != 0); 
                                vFlag = false;
				cyclesCount += 1;
				break;
			case 3: //Form 2
                                switch ((opcode & 0x600) >> 9){
                                    case 0: //ADD Rd,Rs,Rn
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] + Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 31) == 1);
                                        vFlag = (((Registers[operand] >> 31) & (Registers[source] >> 31)) == 1); //Check this
                                        cFlag = ((Registers[source] + Registers[operand]) >> 32) != 0;
                                        cyclesCount += 1;
                                        break;
                                    case 1: //SUB Rd,Rs,Rn
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] - Registers[operand];
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 31) == 1);
                                        vFlag = (((Registers[operand] >> 31) & (Registers[source] >> 31)) == 1);
                                        cFlag = ((Registers[source] - Registers[operand]) >> 32) != 0;
                                        cyclesCount += 1;
                                        break;
                                    case 2: //ADD Rd,Rs,# if #=0 MOV Rd,Rs
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] + operand;
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 31) == 1);
                                        vFlag = (((Registers[dest] >> 31) & (Registers[source] >> 31)) == 0);
                                        cFlag = ((Registers[source] + operand) >> 32) != 0;
                                        cyclesCount += 1;
                                        break;
                                    case 3: //SUB Rd,Rs,#
                                        operand = (opcode >> 6) & 0x7;
                                        source = (opcode >> 3) & 0x7;
                                        dest = opcode & 0x7;
                                        Registers[dest] = Registers[source] - operand;
                                        zFlag = (Registers[dest] == 0);
                                        nFlag = ((Registers[dest] >> 31) == 1);
                                        vFlag = (((Registers[dest] >> 31) & (Registers[source] >> 31)) == 0);
                                        cFlag = ((Registers[source] - operand) >> 32) != 0;
                                        cyclesCount += 1;
                                        break;
                                }
				break;
			}
		}
                if else (opcode & 0x2000 == 1){  //Form 3
                    switch ((opcode & 0x1800) >> 11){
                        case 0: //MOV Rd,#
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            Registers[dest] = operand;
                            zFlag = (Registers[dest] == 0);
                            nFlag = ((Registers[dest] >> 31) == 1);
                            vFlag = false;
                            cFlag = false;
                            cyclesCount += 1;
                            break;
                        case 1: //CMP Rd,#
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            zFlag = (( Registers[dest] - operand) == 0);
                            nFlag = (((( Registers[dest] - operand) >> 31) & 0x1) == 1);
                            vFlag = (((( Registers[dest] - operand) >> 31) & 0x1) == 1);
                            cFlag = ((( Registers[dest] - operand) >> 32) != 0);
                            cyclesCount += 1;
                            break;
                        case 2: //ADD Rd,#
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            Registers[dest] += operand;
                            zFlag = (Registers[dest] == 0);
                            nFlag = ((Registers[dest] >> 31) == 1);
                            cFlag = ((Registers[dest] + operand) >> 32) != 0;
                            vFlag = (((Registers[dest] + operand) >> 31 ) & 0x1) == 1;
                            cyclesCount += 1;
                            break;
                        case 3: //SUB Rd,#
                            dest = (opcode >> 8) & 0x7;
                            operand = opcode & 0xFF;
                            Registers[dest] -= operand;
                            zFlag = (Registers[dest] == 0);
                            nFlag = ((Registers[dest] >> 31) == 1);
                            cFlag = (((Registers[dest] - operand) >> 32) != 0);
                            vFlag = ((((Registers[dest] - operand) >> 31 ) & 0x1) == 1);
                            cyclesCount += 1;
                            break;
                    }
                }
                if else (opcode & 0x4000 == 1){
                    switch ((opcode & 0x3C00) >> 9){
                        case 0: //Form 4
                             switch ((opcode & 0x3C0) >> 5){
                                 case 0: //AND Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[sourse] & Registers[dest];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = false;
                                     vFlag = false;
                                     cyclesCount += 1;
                                     break;
                                 case 1: //EOX Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[sourse] ^ Registers[dest];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = false;
                                     vFlag = false;
                                     cyclesCount += 1;
                                     break;
                                 case 2: //LSL Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] << (Registers[sourse] & 0xFF);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = ((Registers[dest] << (Registers[sourse] & 0xFF)) >> 32) != 0;
                                     vFlag = false;
                                     break;
                                 case 3: //LSR Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] >> (Registers[sourse] & 0xFF);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = ((Registers[dest] >> (Registers[sourse] & 0xFF)) >> 32) != 0;
                                     vFlag = false;
                                     break;
                                 case 4: //ASR Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] >> (Registers[sourse] & 0xFF); //Check this
                                     zFlag = false;
                                     nFlag = false;
                                     cFlag = ((Registers[dest] >> (Registers[sourse] & 0xFF)) >> 32) != 0;
                                     vFlag = false;
                                     break;
                                 case 5: //ADC Rd,Rs  Check how add carry bit 
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] + Registers[sourse] + cFlag; //Check type
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = ((Registers[dest] + Registers[sourse] + cFlag) >> 32) != 0;
                                     vFlag = (((Registers[dest] + Registers[sourse] + cFlag) >> 31) ^ 0x1) == 1;
                                     cyclesCount += 1;
                                     break;
                                 case 6: //SBC Rd,Rs Check how sub carry bit
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] - Registers[sourse] - (cFLag ^ 0x1);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = ((Registers[dest] - Registers[sourse] - (cFLag ^ 0x1)) >> 32) != 0;
                                     vFlag = (((Registers[dest] - Registers[sourse] - (cFLag ^ 0x1)) >> 31) ^ 0x1) == 1;
                                     cyclesCount += 1;
                                     break;
                                 case 7: //ROR Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] << (Registers[sourse] & 0xFF); //Check this
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = ();
                                     vFlag = false;
                                     break;
                                 case 8: //TST Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     zFlag = ((Registers[dest] & Registers[sourse]) == 0);
                                     nFlag = (((Registers[dest] & Registers[sourse]) >> 31) == 1);
                                     cFlag = false;
                                     vFlag = false;
                                     cyclesCount += 1;
                                     break;
                                 case 9: //NEG Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = 0 - Registers[sourse];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = ((Registers[dest] >> 31) == 1);
                                     cFlag = ((0 - Registers[sourse]) >> 32) != 0;
                                     vFlag = (((0 - Registers[sourse]) >> 31) ^ 0x1) == 1;
                                     cyclesCount += 1;
                                     break;
                                 case 0xA: //CMP Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     zFlag = ((Registers[dest] - Registers[sourse]) == 0);
                                     nFlag = (((Registers[dest] - Registers[sourse]) >> 31) == 1);
                                     cFlag = (((Registers[dest] - Registers[sourse])) >> 32) != 0;
                                     vFlag = ((((Registers[dest] - Registers[sourse])) >> 31) & 0x1) == 1;
                                     cyclesCount += 1;
                                     break;
                                 case 0xB: //CMN Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     zFlag = ((Registers[dest] + Registers[sourse]) == 0);
                                     nFlag = (((Registers[dest] + Registers[sourse]) >> 31) == 1);
                                     cFlag = (((Registers[dest] + Registers[sourse])) >> 32) != 0;
                                     vFlag = ((((Registers[dest] + Registers[sourse])) >> 31) & 0x1) == 1;
                                     cyclesCount += 1;
                                     break;
                                 case 0xC: //ORR Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] | Registers[sourse];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = (((Registers[dest]) >> 31) == 1);
                                     cFlag = false;
                                     vFlag = false;
                                     cyclesCount += 1;
                                     break;
                                 case 0xD: //MUL Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] * Registers[sourse];
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = (((Registers[dest]) >> 31) == 1);
                                     cFlag = ((Registers[dest] * Registers[sourse]) >> 32) != 0;
                                     vFlag = false;
                                     break;
                                 case 0xE: //BIC Rd,Rs
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = Registers[dest] & !(Registers[sourse]);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = (((Registers[dest]) >> 31) == 1);
                                     cFlag = false;
                                     vFlag = false;
                                     cyclesCount += 1;
                                     break;
                                 case 0xF: //MVN Rd,RS
                                     sourse = (opcode & 0x38) >> 3;
                                     dest = (opcode &0x7);
                                     Registers[dest] = !(Registers[sourse]);
                                     zFlag = (Registers[dest] == 0);
                                     nFlag = (((Registers[dest]) >> 31) == 1);
                                     cFlag = false;
                                     vFlag = false;
                                     cyclesCount += 1;
                                     break;
                             }
                            break;
                        case 1: //Form 5
                            switch ((opcode & 0x300) >> 9){
                                case 0: //ADD Rd,Rs
                                    zFlag = false;
                                    nFlag = false;
                                    cFlag = false;
                                    vFlag = false;
                                    h1 = (opcode & 0x80) >> 7;
                                    h2 = (opcode & 0x40) >> 6;
                                    sourse = (opcode & 0x38) >> 3;
                                    dest = (opcode & 0x7); //How do the  case h1=h2=0 if undefined
                                    if ((h1 == 0) & (h2 == 1)){
                                        Registers[dest] += Registers[7 + sourse];
                                    }
                                    else if ((h1 == 1) & (h2 == 0)){
                                        Registers[7 + dest] += Registers[sourse];
                                    }
                                    else if ((h1 == 1) & (h2 == 1)){
                                        Registers[7 + dest] += Registers[ 7 + sourse];
                                    }
                                    break;
                                case 1:
                                    h1 = (opcode & 0x80) >> 7;
                                    h2 = (opcode & 0x40) >> 6;
                                    sourse = (opcode & 0x38) >> 3;
                                    dest = (opcode & 0x7); //How do the  case h1=h2=0 if undefined
                                    if ((h1 == 0) & (h2 == 1)){
                                        zFlag = ( (Registers[dest] - Registers[7 + sourse]) == 0);
                                        nFlag = (((Registers[dest] - Registers[7 + sourse]) & 0x80000000) >> 31) == 1;
                                        cFlag = (((Registers[dest] - Registers[7 + sourse]) >> 32) != 0);
                                        vFlag = ((((Registers[dest] & 0x80000000) >> 31) ^ ((Registers[7 + sourse] & 0x80000000) >> 31)) == 1);
                                    }
                                    else if ((h1 == 1) & (h2 == 0)){
                                        zFlag = ( (Registers[7 + dest] - Registers[sourse]) == 0);
                                        nFlag = (((Registers[7 + dest] - Registers[sourse]) & 0x80000000) >> 31) == 1;
                                        cFlag = (((Registers[7 + dest] - Registers[sourse]) >> 32) != 0);
                                        vFlag = ((((Registers[7 + dest] & 0x80000000) >> 31) ^ ((Registers[sourse] & 0x80000000) >> 31)) == 1);
                                        
                                    }
                                    else if ((h1 == 1) & (h2 == 1)){
                                        zFlag = ( (Registers[7 + dest] - Registers[7 + sourse]) == 0);
                                        nFlag = (((Registers[7 + dest] - Registers[7 + sourse]) & 0x80000000) >> 31) == 1;
                                        cFlag = (((Registers[7 + dest] - Registers[7 + sourse]) >> 32) != 0);
                                        vFlag = ((((Registers[7 + dest] & 0x80000000) >> 31) ^ ((Registers[7 + sourse] & 0x80000000) >> 31)) == 1);
                                        
                                    }
                                    break;
                                case 2:
                                    zFlag = false;
                                    nFlag = false;
                                    cFlag = false;
                                    vFlag = false;
                                    h1 = (opcode & 0x80) >> 7;
                                    h2 = (opcode & 0x40) >> 6;
                                    sourse = (opcode & 0x38) >> 3;
                                    dest = (opcode & 0x7); //How do the  case h1=h2=0 if undefined
                                    if ((h1 == 0) & (h2 == 1)){
                                        Registers[dest] = Registers[7 + sourse];
                                    }
                                    else if ((h1 == 1) & (h2 == 0)){
                                        Registers[7 + dest] = Registers[sourse];
                                    }
                                    else if ((h1 == 1) & (h2 == 1)){
                                        Registers[7 + dest] = Registers[ 7 + sourse];
                                    }
                                    break;
                                case 3:
                                    zFlag = false;
                                    nFlag = false;
                                    cFlag = false;
                                    vFlag = false;
                                    h1 = (opcode & 0x80) >> 7;
                                    h2 = (opcode & 0x40) >> 6;
                                    sourse = (opcode & 0x38) >> 3;
                                     //How do the  case h1=h2=0 if undefined
                                    if ((h1 == 0) & (h2 == 0)){
                                        Registers[15] = Registers[sourse];
                                        tFlag = ((Registers[sourse] & 0x1) == 1);
                                        
                                    }
                                    else if ((h1 == 0) & (h2 == 1)){
                                        if (sourse == 7){
                                            tFlag = ((Registers[15] & 0x1) == 1);
                                            if (tFlag){
                                                Registers[15] += 2; //When executting this in THUMB will result in unpredictable execution
                                            }
                                            else {
                                                 Registers[15] += 4;
                                            }
                                        }
                                        else {
                                            Registers[15] = Registers[7 + sourse];
                                            tFlag = ((Registers[sourse] & 0x1) == 1);
                                        }
                                    }
                                    
                                    break;
                            }
                            break;
                    }
                    
                }
	}
	else
	{
		// ARM Mode
	}
}
