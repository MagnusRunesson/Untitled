#!/bin/bash
./build.sh

cd mess
~/Downloads/mess0155-32bit/mess genesis -cart ../out/untitled_megadrive.bin -window -waitvsync -nofilter -skip_gameinfo
