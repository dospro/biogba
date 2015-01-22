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
}

bool cMemory::loadRom(char* fileName)
{
    int size = 0;
    FILE *file_ptr;
    file_ptr = fopen(fileName, "rb");
    
    //Let's get the ROM real size.
    fseek(file_ptr, 0, SEEK_END);
    size = ftell(file_ptr);
    rewind(file_ptr);
    
    //Now let's get the important data from the header.
    fseek(file_ptr, 0xA0, SEEK_SET);
    fread(header.title, 1, 12, file_ptr);
    
    //Finally, let's load the ROM in memory.
    fclose(file_ptr);
    
    printf("Rom %s has size %d MB\n", header.title, (size/1024)/1024);
    return true;
}

