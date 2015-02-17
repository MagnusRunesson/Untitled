#!/bin/bash

#
# Build Mega Drive
#
echo
echo
echo
echo "=======> Building Mega Drive"
echo
../bin/osx/vasmm68k_mot -Fbin -o out/untitled_megadrive.bin megadrive.asm -Dis_mega_drive -m68000 -L megadrive_listfile.txt
../bin/osx/buildcomments megadrive_listfile.txt mess/comments/megadriv.cmt

#
# Build Amiga
#
echo
echo
echo
echo "=======> Building Amiga"
echo
../bin/osx/vasmm68k_mot -Fbin -o out/untitled.adf amigaadf.asm -Dis_amiga -m68000 -I"/Users/magnusrunesson/Projects/Amiga/NDK_3.9/Include/include_i" -I"/Users/magnusrunesson/Projects/md/Untitled/src/platform/amiga/amiga_lib"
../bin/osx/makeimage out/untitled.adf

echo
echo
