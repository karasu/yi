#!/bin/sh

YI_HOME="/home/yi"
CONF_FILE="${YI_HOME}/etc/system.conf"

get_config()
{
    key=$1
    grep -w $1 $CONF_FILE | cut -d "=" -f2
}

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:${YI_HOME}/lib:/tmp/sd/yi-hack-v4/lib
export PATH=$PATH:/home/base/tools:${YI_HOME}/bin:${YI_HOME}/sbin:/tmp/sd/yi-hack-v4/bin:/tmp/sd/yi-hack-v4/sbin

ulimit -s 1024
hostname -F /etc/hostname

if [[ $(get_config DISABLE_CLOUD) == "no" ]] ; then
(
    cd /home/app
    sleep 2
    ./mp4record &
    ./cloud &
    ./p2p_tnp &
    if [[ $(cat /home/app/.camver) != "yi_dome" ]] ; then
        ./oss &
    fi
    ./watch_process &
)
elif [[ $(get_config REC_WITHOUT_CLOUD) == "yes" ]] ; then
(
    cd /home/app
    sleep 2
    ./mp4record &
)
fi

if [[ $(get_config HTTPD) == "yes" ]] ; then
    httpd -p 80 -h ${YI_HOME}/www/
fi

if [[ $(get_config TELNETD) == "yes" ]] ; then
    telnetd
fi

if [[ $(get_config FTPD) == "yes" ]] ; then
    if [[ $(get_config BUSYBOX_FTPD) == "yes" ]] ; then
        tcpsvd -vE 0.0.0.0 21 ftpd -w &
    else
        pure-ftpd -B
    fi
fi

if [[ $(get_config SSHD) == "yes" ]] ; then
    dropbear -R
fi

if [[ $(get_config NTPD) == "yes" ]] ; then
    # Wait until all the other processes have been initialized
    sleep 5 && ntpd -p $(get_config NTP_SERVER) &
fi

if [[ $(get_config MQTT) == "yes" ]] ; then
    mqttv4 &
fi

if [[ $(get_config RTSP) == "yes" ]] ; then
    if [[ -f "${YI_HOME}/bin/viewd" && -f "${YI_HOME}/bin/rtspv4" ]] ; then
        viewd -D -S
        rtspv4 -D -S
    fi
fi

sleep 25 && camhash > /tmp/camhash &

# First run on startup, then every day via crond
${YI_HOME}/script/check_update.sh

crond -c ${YI_HOME}/etc/crontabs

if [ -f "/tmp/sd/yi-hack-v4/startup.sh" ]; then
    /tmp/sd/yi-hack-v4/startup.sh
elif [ -f "/home/hd1/yi-hack-v4/startup.sh" ]; then
    /home/hd1/yi-hack-v4/startup.sh
fi

# Adding some symlinks for the last picture/video
if [ ! -d "${YI_HOME}/www/img" ]; then
    mkdir -p ${YI_HOME}/www/img
fi

if [ ! -f "${YI_HOME}/www/img/last.jpg" ]; then
    ln -s /tmp/sd/record/last.jpg ${YI_HOME}/www/img/last.jpg
fi

if [ ! -f "${YI_HOME}/www/img/last.mp4" ]; then
    ln -s /tmp/sd/record/last.mp4 ${YI_HOME}/www/img/last.mp4
fi

# Check if we use the telegram alarm functionality
if [[ $(get_config ALARM) == "yes" ]] ; then
    if [ -f "${YI_HOME}/script/alarm.sh" ]; then
        sh ${YI_HOME}/script/alarm.sh &
    fi
else
    if [ -f "${YI_HOME}/script/last_motion.sh" ]; then
        sh ${YI_HOME}/script/last_motion.sh &
    fi
fi
