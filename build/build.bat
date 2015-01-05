@echo off

..\bin\win32\vasmm68k_mot_win32 -Fbin -o out/untitled.adf amiga.asm -m68000 -I"F:/Amiga/Harddrives/Hdf My Amiga 1200/NewCode/NDK_3.9/Include/include_i"
..\bin\win32\makeimage out/untitled.adf

..\bin\win32\vasmm68k_mot_win32 -Fbin -o out/untitled_megadrive.bin megadrive.asm -m68000
