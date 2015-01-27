/* 
 * File:   cMemory.cpp
 * Author: dospro
 * 
 * Created on 17 de enero de 2015, 09:08 PM
 */

#include "cMemory.h"
#include <stdio.h>


cMemory::cMemory() {
}


cMemory::~cMemory() {
	if(RomMemory != NULL)
	{
		delete RomMemory;
		RomMemory = NULL;
	}
}

bool cMemory::loadRom(char* fileName)
{
    FILE *file_ptr;
    file_ptr = fopen(fileName, "rb");
    
    //Let's get the ROM real size.
    fseek(file_ptr, 0, SEEK_END);
	header.romSize = ftell(file_ptr);
    
    //Now let's get the important data from the header.
    fseek(file_ptr, 0xA0, SEEK_SET);
    fread(header.title, 1, 12, file_ptr);
	rewind(file_ptr);
    
    //Finally, let's load the ROM in memory.
	RomMemory = new byte[header.romSize];
	if(!RomMemory)
	{
		printf("ERROR: Can't get enough memory for the ROM\n");
		fclose(file_ptr);
		return false;
	}
	fread(RomMemory, header.romSize, 1, file_ptr);
    fclose(file_ptr);

	//Let's prepare the memory map.
	BIOSMemory = new byte[0x4000];
	EWorkRam = new byte[0x40000];
	IWorkRam = new byte[0x8000];
    
	printf("Rom %s has size %d MB\n", header.title, (header.romSize/1024)/1024);
    return true;
}

byte cMemory::readByte(u32 address)
{
	if(address < 0x4000)
	{
		return BIOSMemory[address];
	}
	else if(address > 0x2000000 && address < 0x2040000)
	{
		return EWorkRam[address-0x2000000];
	}
	else if(address > 0x3000000 && address < 0x3004000)
	{
		return IWorkRam[address-0x3000000];
	}
	else if(address > 0x8000000 && address < 0x1000000)
	{
		return RomMemory[address-0x8000000];
	}
	else
	{
		printf("Read to %X not implemented\n");
		return 0xFF;
	}
}

word cMemory::readWord(u32 address)
{
	return (readByte(address) | (readByte(address+1) << 8));
}

void cMemory::writeByte(u32 address, byte data)
{

}
