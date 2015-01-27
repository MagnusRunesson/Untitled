#!/bin/bash
./build.sh

cd mess
~/Downloads/mess0155-32bit/mess megadriv -cart ../out/untitled_megadrive.bin -window -waitvsync -nofilter -skip_gameinfo
