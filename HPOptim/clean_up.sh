# Author: Julien Hoachuck
# Copyright 2015, Julien Hoachuck, All rights reserved.
rm /data/db/spearmint.*
rm /data/db/mongod.lock
killall mongod
mongod --fork --logpath /home/toor/Desktop/log --dbpath /data/db