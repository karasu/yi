#!/bin/bash

sudo ./cleanup
echo "Press any key to continue..."
./compile.sh
echo "Press any key to continue..."
read
./init_sysroot.sh yi_home
echo "Press any key to continue..."
read
./pack_fw.sh yi_home

if [ -d ../out ]; then
    cd ../out
fi


