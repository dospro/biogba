/* 
 * File:   cMemory.cpp
 * Author: dospro
 * 
 * Created on 17 de enero de 2015, 09:08 PM
 */

#include "cMemory.h"
#include <iostream>
#include <fstream>

cMemory::cMemory() {
	RomMemory = NULL;
}

cMemory::~cMemory() {
    if (RomMemory != NULL) {
        delete RomMemory;
        RomMemory = NULL;
    }
}

bool cMemory::loadRom(char* fileName) {

	std::ifstream file;
	file.open(fileName);

	if(file.bad())
	{
		std::cout << "ERROR: Couldn't load" << fileName << '\n';
		return false;
	}

    //Let's get the ROM real size.
	file.seekg(0,std::ios::end);
	header.romSize = file.tellg();

    //Now let's get the important data from the header.
	file.seekg(0xA0);
	file.read(header.title, 12);
	file.seekg(0);

    //Finally, let's load the ROM in memory.
    RomMemory = new byte[header.romSize];
    if (!RomMemory) {
        std::cout << "ERROR: Can't get enough memory for the ROM\n";
		file.close();
        return false;
    }
	file.read((char *)RomMemory, header.romSize);
	file.close();

    //Let's prepare the memory map.
    BIOSMemory = new byte[0x4000];
    EWorkRam = new byte[0x40000];
    IWorkRam = new byte[0x8000];

	std::cout << "Rom " << header.title << "has size " <<  (header.romSize / 1024) / 1024 << "MB\n";
    return true;
}

byte cMemory::readByte(u32 address) {
    if (address < 0x4000) {
        return BIOSMemory[address];
    } else if (address >= 0x2000000 && address < 0x2040000) {
        return EWorkRam[address - 0x2000000];
    } else if (address >= 0x3000000 && address < 0x3004000) {
        return IWorkRam[address - 0x3000000];
    } else if (address >= 0x8000000 && address < 0x1000000) {
        return RomMemory[address - 0x8000000];
    } else {
        std::cout << "Read to " << address << "not implemented\n";
        return 0xFF;
    }
}

word cMemory::readWord(u32 address) 
{
    return (readByte(address) | (readByte(address + 1) << 8));
}

u32 cMemory::readDword(u32 address)
{
	return (readByte(address) |
			(readByte(address + 1) << 8) |
			(readByte(address + 2) << 16) |
			(readByte(address + 3) << 32));
}

void cMemory::writeByte(u32 address, byte data) {
	if(address >= 0x2000000 && address < 0x2040000)
	{
		EWorkRam[address - 0x2000000] = data;
	}
	else if (address >= 0x3000000 && address < 0x3004000) 
	{
        IWorkRam[address - 0x3000000] = data;
    }
	else
	{
		std::cout << "Not implemented\n";
	}
}

void cMemory::writeWord(u32 address, word data)
{
	writeByte(address, data&0xFF);
	writeByte(address+1, data>>8);
}

void cMemory::writeDword(u32 address, u32 data)
{
	writeByte(address, data&0xFF);
	writeByte(address+1, (data>>8)&0xFF);
	writeByte(address+2, (data>>16)&0xFF);
	writeByte(address+1, (data>>24)&0xFF);
}
