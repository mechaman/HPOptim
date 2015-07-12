# Author: Julien Hoachuck
# Copyright 2015, Julien Hoachuck, All rights reserved.
#!/bin/bash
file1="0"
file2="0"

find /data/db/ -maxdepth 1 -type f -name "spearmint.*" 2>/dev/null | grep -q . && file1=1
if [ $file1 -eq 1 ]; then
	rm /data/db/spearmint.*
	echo "Removed spearmint.*"
fi

find /data/db/ -maxdepth 1 -type f -name "mongod.lock" 2>/dev/null | grep -q . && file2=1
if [ $file2 -eq 1 ]; then
	rm /data/db/mongod.lock
	echo "Removed mongod.lock"
fi

killall mongod

