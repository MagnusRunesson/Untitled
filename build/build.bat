@echo off

Echo.
Echo Amiga!
Echo.

..\bin\win32\vasmm68k_mot_win32 -Fbin -o out/amigaadf.adf amigaadf.asm -Dis_amiga -m68000 -L amigaadf_listfile.txt -I"..\..\..\NDK_3.9\Include\include_i" -I"..\src\platform\amiga\amiga_lib"
..\bin\win32\makeimage out/amigaadf.adf
..\bin\win32\buildcomment amigaadf_listfile.txt mess\comments\a500.cmt a500

Echo.
Echo Mega drive!
Echo.

..\bin\win32\vasmm68k_mot_win32 -Fbin -o out/untitled_megadrive.bin megadrive.asm -Dis_mega_drive -m68000 -L megadrive_listfile.txt 
..\bin\win32\buildcomment megadrive_listfile.txt mess\comments\genesis.cmt genesis

Echo.
Echo done..
Echo.