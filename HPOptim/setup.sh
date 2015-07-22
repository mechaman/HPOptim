# Author: Julien Hoachuck
# Copyright 2015, Julien Hoachuck, All rights reserved.

temp=$(echo $PATH | grep -o ":/[a-zA-Z0-9_/]*/torch/install/bin:")
TorchPath=$(echo $temp | grep -o "/.*/torch")

luajit -b ../model.lua model.o
gcc -w -c -Wall -Wl,-E -fpic cluaf.c -lluajit -lluaT -lTH -lm -ldl -I$TorchPath/install/include -L/usr/lib/x86_64-linux-gnu/
gcc -shared cluaf.o model.o -L$TorchPath/install/lib -lluajit -lluaT -lTH -lm -ldl -Wl,-E -o libcluaf.so
