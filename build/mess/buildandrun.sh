#!/bin/bash
cd ..
../bin/osx/vasmm68k_mot -Fbin -o megadrive.bin megadrive.asm -m68000

cd mess
~/Downloads/mess0155-32bit/mess genesis -cart ../megadrive.bin -window -waitvsync -nofilter -skip_gameinfo