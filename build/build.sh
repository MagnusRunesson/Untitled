#!/bin/bash

#
# Build Mega Drive
#
echo
echo
echo "=======> Building Mega Drive"
echo
echo
../bin/osx/vasmm68k_mot -Fbin -o out/untitled_megadrive.bin megadrive.asm -m68000

#
# Build Amiga
#
echo
echo
echo "=======> Building Amiga"
echo
echo
../bin/osx/vasmm68k_mot -Fbin -o out/untitled.adf amigaadf.asm -m68000 -I"/Users/magnusrunesson/Projects/Amiga/NDK_3.9/Include/include_i" -I"/Users/magnusrunesson/Projects/md/Untitled/src/amiga_lib"
../bin/osx/makeimage out/untitled.adf

echo
echo
