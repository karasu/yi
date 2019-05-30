#!/bin/sh

YI_HOME="/home/yi"
YI_PREFIX="/home/app"
UDHCPC_SCRIPT_DEST="/home/app/script/default.script"

ARCHIVE_FILE="${YI_HOME}/yi-hack-v4.7z"

DHCP_SCRIPT_DEST="/home/app/script/wifidhcp.sh"
UDHCP_SCRIPT="${YI_HOME}/script/default.script"
DHCP_SCRIPT="${YI_HOME}/script/wifidhcp.sh"

# Extract all 7z files from /home/app
files=`find $YI_PREFIX -maxdepth 1 -name "*.7z"`
if [ ${#files[@]} -gt 0 ]; then
	/home/base/tools/7za x "$YI_PREFIX/*.7z" -y -o$YI_PREFIX
	rm $YI_PREFIX/*.7z
fi

# Extract yi-hack-v4.7z
if [ -f $ARCHIVE_FILE ]; then
	/home/base/tools/7za x $ARCHIVE_FILE -y -o$DESTDIR
	rm $ARCHIVE_FILE
fi

if [ ! -f $YI_PREFIX/cloudAPI_real ]; then
	mv $YI_PREFIX/cloudAPI $YI_PREFIX/cloudAPI_real
	cp ${YI_HOME}/script/cloudAPI $YI_PREFIX/
        rm $UDHCPC_SCRIPT_DEST
        cp $UDHCP_SCRIPT $UDHCPC_SCRIPT_DEST
	if [ -f $DHCP_SCRIPT_DEST ]; then
		rm $DHCP_SCRIPT_DEST
		cp $DHCP_SCRIPT $DHCP_SCRIPT_DEST
	fi
fi

mkdir -p ${YI_HOME}/etc/crontabs
mkdir -p ${YI_HOME}/etc/dropbear

# Comment out all the cloud stuff from base/init.sh
sed -i '/^\.\/watch_process/s/^/#/' /home/app/init.sh
sed -i '/^\.\/oss/s/^/#/' /home/app/init.sh
sed -i '/^\.\/p2p_tnp/s/^/#/' /home/app/init.sh
sed -i '/^\.\/cloud/s/^/#/' /home/app/init.sh
sed -i '/^\.\/mp4record/s/^/#/' /home/app/init.sh

# Comment out the rtc command that sometimes hangs the camera in base/init.sh
# rtctime=$(/home/base/tools/rtctool -g time
# date -s $rtctime
sed -i '/^rtctime=\$(\/home\/base\/tools\/rtctool -g time)/s/^/#/' /home/base/init.sh
sed -i '/^date -s \$rtctime/s/^/#/' /home/base/init.sh
