# Author: Julien Hoachuck
# Copyright 2015, Julien Hoachuck, All rights reserved.

luajit -b ../model.lua model.o
gcc -w -c -Wall -Wl,-E -fpic cluaf.c -lluajit -lluaT -lTH -lm -ldl -I/home/toor/torch/install/include -L/usr/lib/x86_64-linux-gnu/
gcc -shared cluaf.o model.o -L/home/toor/torch/install/lib -lluajit -lluaT -lTH -lm -ldl -Wl,-E -o libcluaf.so
