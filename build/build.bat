@echo off

..\bin\win32\vasmm68k_mot_win32 -Fbin -o out/untitled.adf amigaadf.asm -m68000 -I"F:/Amiga/Harddrives/Hdf My Amiga 1200/NewCode/NDK_3.9/Include/include_i" -I"F:\Amiga\Harddrives\Hdf My Amiga 1200\NewCode\Source\Untitled\src\amiga_lib"
..\bin\win32\makeimage out/untitled.adf

..\bin\win32\vasmm68k_mot_win32 -Fbin -o out/untitled_megadrive.bin megadrive.asm -m68000
