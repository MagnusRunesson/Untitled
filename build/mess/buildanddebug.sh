#!/bin/bash
cd ..
~/Downloads/vasm/vasmm68k_mot -Fbin -o megadrive.bin megadrive.asm -m68000

cd mess
~/Downloads/mess0155-32bit/mess genesis -cart ../megadrive.bin -window -waitvsync -nofilter -debug -skip_gameinfo
