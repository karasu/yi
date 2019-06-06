#!/bin/bash

sudo ./cleanup.sh
echo "Press ENTER to continue..."
read

./compile.sh
echo "Press ENTER to continue..."
read

./install.sh
echo "Press ENTER to continue..."
read

./init_sysroot.sh yi_home
echo "Press ENTER to continue..."
read

./pack_fw.sh yi_home

if [ -d ../out ]; then
    cd ../out
fi


