#!/bin/bash
#
#  This file is part of yi-hack-v4 (https://github.com/TheCrypt0/yi-hack-v4).
#  Copyright (c) 2018-2019 Davide Maggioni.
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

create_tmp_dir()
{
    local TMP_DIR=$(mktemp -d)

    if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
        echo "ERROR: Could not create temp dir \"$TMP_DIR\". Exiting."
        exit 1
    fi

    echo $TMP_DIR
}

compress_file()
{
    local DIR=$1
    local FILENAME=$2
    local FILE=$DIR/$FILENAME
#    if [ -f "$MYFILE" ]; then
        echo -n "    Compressing $FILE..."
        sudo 7za a -bd -sdel -y -mx9 "$FILE.7z" "$FILE" > /dev/null
        #sudo rm -f "$FILE"
        echo "done!"
#    fi
}

pack_image()
{
    local TYPE=$1
    local CAMERA_ID=$2
    local DIR=$3
    local OUT=$4

    echo ">>> Packing ${TYPE}_${CAMERA_ID}"

    echo -n "    Creating jffs2 filesystem in $DIR/${TYPE}_${CAMERA_ID}.jffs2... "
    sudo mkfs.jffs2 -l -e 64 -r $DIR/$TYPE -o $DIR/${TYPE}_${CAMERA_ID}.jffs2 || exit 1
    echo "done!"

    echo -n "    Adding U-Boot header... "
    sudo mkimage -A arm -T filesystem -C none -n 0001-hi3518-$TYPE -d $DIR/${TYPE}_${CAMERA_ID}.jffs2 $OUT/${TYPE}_${CAMERA_ID} > /dev/null || exit 1
    echo "done!"
}

###############################################################################

source "$(get_script_dir)/common.sh"

#require_root


if [ $# -ne 1 ]; then
    echo "Usage: pack_sw.sh camera_name"
    echo ""
    exit 1
fi

CAMERA_NAME=$1

check_camera_name $CAMERA_NAME

CAMERA_ID=$(get_camera_id $CAMERA_NAME)

BASE_DIR=$(get_script_dir)/../
BASE_DIR=$(normalize_path $BASE_DIR)

YI_HOME="/home/yi"

SYSROOT_DIR=${BASE_DIR}sysroot/$CAMERA_NAME
STATIC_DIR=${BASE_DIR}static
BUILD_DIR=${BASE_DIR}build
OUT_DIR=${BASE_DIR}out/$CAMERA_NAME

echo ""
echo "------------------------------------------------------------------------"
echo " YI HACK v4 - FIRMWARE PACKER"
echo "------------------------------------------------------------------------"
printf " camera_name      : %s\n" $CAMERA_NAME
printf " camera_id        : %s\n" $CAMERA_ID
printf "                      \n"
printf " sysroot_dir      : %s\n" $SYSROOT_DIR
printf " static_dir       : %s\n" $STATIC_DIR
printf " build_dir        : %s\n" $BUILD_DIR
printf " out_dir          : %s\n" $OUT_DIR
echo "------------------------------------------------------------------------"
echo ""

printf "Starting...\n\n"

sleep 1

printf ">>> Checking if the required sysroot exists... "

# Check if the sysroot exist
if [[ ! -d "${SYSROOT_DIR}/home" || ! -d "${SYSROOT_DIR}/rootfs" ]]; then
    printf "\n\n"
    echo "ERROR: Cannot find the sysroot. Missing:"
    echo " > ${SYSROOT_DIR}/home"
    echo " > ${SYSROOT_DIR}/rootfs"
    echo ""
    echo "You should create the $CAMERA_NAME sysroot before trying to pack the firmware."
    exit 1
else
    printf "yeah!\n"
fi

echo -n ">>> Creating the out directory... "
mkdir -p ${OUT_DIR}
echo "${OUT_DIR} created!"

echo -n ">>> Creating the tmp directory... "
TMP_DIR=$(create_tmp_dir)
echo "${TMP_DIR} created!"

# Copy the sysroot to the tmp dir
echo ">>> Copying the sysroot contents to ${TMP_DIR}... "
echo "    Copying rootfs..."
rsync -a ${SYSROOT_DIR}/rootfs/* ${TMP_DIR}/rootfs || exit 1
echo "    Copying home..."
rsync -a ${SYSROOT_DIR}/home/* ${TMP_DIR}/home || exit 1
echo "    done!"

# We can safely replace chinese audio files with links to the us version
echo -n ">>> Removing unneeded audio files... "
AUDIO_EXTENSION="*.aac"
if [[ $CAMERA_NAME == "yi_home" ]] ; then
    # The yi_home camera uses *.g726 and *.726 audio files
    AUDIO_EXTENSION="*726"
fi

for AUDIO_FILE in ${TMP_DIR}/home/app/audio_file/us/${AUDIO_EXTENSION} ; do
    AUDIO_NAME=$(basename ${AUDIO_FILE})

    # Delete the original audio files
    rm -f $TMP_DIR/home/app/audio_file/jp/$AUDIO_NAME
    rm -f $TMP_DIR/home/app/audio_file/kr/$AUDIO_NAME
    rm -f $TMP_DIR/home/app/audio_file/simplecn/$AUDIO_NAME
    rm -f $TMP_DIR/home/app/audio_file/trditionalcn/$AUDIO_NAME

    # Create links to the us version
    ln -s ../us/$AUDIO_NAME $TMP_DIR/home/app/audio_file/jp/$AUDIO_NAME
    ln -s ../us/$AUDIO_NAME $TMP_DIR/home/app/audio_file/kr/$AUDIO_NAME
    ln -s ../us/$AUDIO_NAME $TMP_DIR/home/app/audio_file/simplecn/$AUDIO_NAME
    ln -s ../us/$AUDIO_NAME $TMP_DIR/home/app/audio_file/trditionalcn/$AUDIO_NAME
done
echo "done!"

## Copy build files to the tmp dir
echo -n ">>> Copying files from the build directory to ${TMP_DIR}... "
cp -R ${BUILD_DIR}/rootfs/* ${TMP_DIR}/rootfs || exit 1
cp -R ${BUILD_DIR}/home/* ${TMP_DIR}/home || exit 1
echo "done!"

TMP_YI_HOME=${TMP_DIR}${YI_HOME}

# Copy viewd to sd yi folder
if [ -f ${BASE_DIR}viewd ]; then
    echo -n ">>> Copying viewd to ${TMP_YI_HOME}/bin..."
    cp ${BASE_DIR}viewd ${TMP_YI_HOME}/bin
    echo "done!"
fi

if [ ! -f ${TMP_YI_HOME}/bin/vencrtsp_v2 ]; then
    echo -n ">>> vencrtsp_v2 compilation failed. Copying executable..."
    cp ${BASE_DIR}vencrtsp_v2 ${TMP_YI_HOME}/bin
    echo "done!"
fi

# Insert the version file
echo -n ">>> Copying VERSION file... "
cp $BASE_DIR/VERSION ${TMP_YI_HOME}/version
echo "done!"

# Insert the camera version file
echo -n ">>> Creating the .camver file... "
echo $CAMERA_NAME > ${TMP_DIR}/home/app/.camver
echo "done!"

# fix the files ownership
echo -n ">>> Fixing tmp files ownership... "
sudo chown -R root:root ${TMP_DIR}
echo "done!"

## Compress the yi app files
echo ">>> Compressing yi app files..."
compress_file ${TMP_DIR}/home/app cloudAPI
compress_file ${TMP_DIR}/home/app oss
compress_file ${TMP_DIR}/home/app p2p_tnp
compress_file ${TMP_DIR}/home/app rmm
echo "done!"

## Compress the /home/yi folder
#echo -n ">>> Compressing $YI_HOME... "
#sudo 7za a -bd -mx9 -y ${TMP_YI_HOME}/yi.7z ${TMP_YI_HOME}/* > /dev/null
#echo "done!"

#echo -n ">>> Removing duplicated compressed files from ${TMP_YI_HOME}..."
## Delete all the compressed files except system_init.sh and yi.7z
#sudo sh -c "find $TMP_YI_HOME/script -maxdepth 1 -not -name 'system_init.sh' -type f -exec rm -f {} +"
#sudo sh -c "find $TMP_YI_HOME/* -maxdepth 1 -type d -not -name 'script' -exec rm -rf {} +"
#sudo sh -c "find ${TMP_YI_HOME}/* -maxdepth 0 -type f -not -name 'yi.7z' | xargs rm -rf"
#echo "done!"

## fix the files ownership
#echo -n ">>> Fixing compressed files ownership... (again)"
#sudo chown -R root:root ${TMP_DIR}
#echo "done!"

# home
pack_image "home" $CAMERA_ID $TMP_DIR $OUT_DIR

# rootfs
pack_image "rootfs" $CAMERA_ID $TMP_DIR $OUT_DIR

# Cleanup
echo -n ">>> Cleaning up the tmp folder ($TMP_DIR)... "
sudo rm -rf $TMP_DIR
echo "done!"

echo -n ">>> Copying extra sd files to ${OUT_DIR} directory... "
mkdir -p ${OUT_DIR}
cp -R ${BUILD_DIR}/sd/* ${OUT_DIR}
echo "done!"

# Copy sdk libraries
if [ -d /opt/hisi-linux/x86-arm/arm-hisiv300-linux/arm-hisiv300-linux-uclibcgnueabi/lib ]; then
    echo -n ">>> Copying library files from sdk to ${OUT_DIR}/yi/lib..."
    cp -a /opt/hisi-linux/x86-arm/arm-hisiv300-linux/arm-hisiv300-linux-uclibcgnueabi/lib/*.so.* ${OUT_DIR}/yi/lib
    echo "done!"
fi

echo "------------------------------------------------------------------------"
echo " Finished!"
echo " Files saved in ${OUT_DIR}"
echo "------------------------------------------------------------------------"
