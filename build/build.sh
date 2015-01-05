#!/bin/bash

#
# Build Mega Drive
#
../bin/osx/vasmm68k_mot -Fbin -o out/untitled_megadrive.bin megadrive.asm -m68000

#
# Build Amiga
#
../bin/osx/vasmm68k_mot -Fbin -o out/untitled.adf amiga.asm -m68000 -I"/Users/magnusrunesson/Projects/Amiga/NDK_3.9/Include/include_i"
../bin/osx/makeimage out/untitled.adf
