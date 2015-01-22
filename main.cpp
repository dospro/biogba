/* 
 * File:   main.cpp
 * Author: dospro
 *
 * Created on 17 de enero de 2015, 08:38 PM
 */

#include <stdio.h>
#include "cMemory.h"
/*
 * 
 */
int main(int argc, char** argv) {
    
    cMemory mem;
   
    printf("BioGBA v1.0\n");
    if(argc < 2)
    {
        printf("Specify a GBA Rom\n");
        return 0;
    }
    mem.loadRom(argv[1]);
    return 0;
}

