#!/bin/bash
#
#  This file is part of yi-hack-v4 (https://github.com/TheCrypt0/yi-hack-v4).
#  Copyright (c) 2019 densanki.
#  Copyright (c) 2019 Davide Maggioni.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, version 3.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#

get_script_dir()
{
    echo "$(cd `dirname $0` && pwd)"
}

source "$(get_script_dir)/common.sh"

require_root

echo ""
echo "------------------------------------------------------------------------"
echo " YI-HACK-V4 - CLEANUP"
echo "------------------------------------------------------------------------"
echo ""

BASE_DIR=$(get_script_dir)/../
BASE_DIR=$(normalize_path $BASE_DIR)

SYSROOT_DIR=${BASE_DIR}sysroot
STATIC_DIR=${BASE_DIR}static
BUILD_DIR=${BASE_DIR}build
OUT_DIR=${BASE_DIR}out

echo -n "Cleaning sysroot..."
rm -rf ${SYSROOT_DIR}/yi_*
echo "done!"

echo -n "Cleaning out dir..."
rm -rf ${OUT_DIR}/yi_*
echo "done!"

SRC_DIR=$(get_script_dir)/../src
for SUB_DIR in ${SRC_DIR}/* ; do
    if [ -d ${SUB_DIR}/_install ]; then # Will not run if no directories are available
        echo -n "Cleaning $(basename ${SUB_DIR})..."
        rm -rf ${SUB_DIR}/_install
        echo "done!"
    fi
done
echo ""
echo "Finished!"
echo ""
