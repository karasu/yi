#!/bin/sh
# Copyright 2018 Vladimir Dronnikov & Frank van der Stad
# GPL

if [ -d "/usr/yi-hack-v4" ]; then
	YI_HACK_V3_PREFIX="/usr"
elif [ -d "/home/yi-hack-v4" ]; then
	YI_HACK_V3_PREFIX="/home"
fi

source $YI_HACK_V3_PREFIX/yi-hack-v4/script/alarm_functions.sh

CAMERA_NAME=$(more $YI_HACK_V3_PREFIX/yi-hack-v4/etc/hostname)

# This part is copyright 2018 Vladimir Dronnikov
# GPL
ALARM=0
while true; do
  test -r /tmp/sd/record/tmp.mp4.tmp && REC=1 || REC=0
  if [ "$REC" != "$ALARM" ]; then
    ALARM="$REC"
    [ "n$ALARM" == "n0" ] && rm /tmp/temp.jpg /tmp/temp.mp4
  fi
  [ -r /tmp/motion.jpg -a ! -r /tmp/temp.jpg ] && cp /tmp/motion.jpg /tmp/temp.jpg && echo JPG ready && photo /tmp/temp.jpg "Photo from $CAMERA_NAME"
  [ -r /tmp/motion.mp4 -a ! -r /tmp/temp.mp4 ] && cp /tmp/motion.mp4 /tmp/temp.mp4 && echo MP4 ready && video /tmp/temp.mp4 "Video from $CAMERA_NAME"
  sleep 2s
done
