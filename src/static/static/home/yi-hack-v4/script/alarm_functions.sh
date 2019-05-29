#!/bin/sh
# Copyright 2018 Frank van der Stad
# GPL
CONF_FILE="/yi-hack-v4/etc/system.conf"

if [ -d "/usr/yi-hack-v4" ]; then
  YI_HACK_V4_PREFIX="/usr"
elif [ -d "/home/yi-hack-v4" ]; then
  YI_HACK_V4_PREFIX="/home"
fi

get_config() {
  key=$1
  grep $1 $YI_HACK_V4_PREFIX$CONF_FILE | cut -d "=" -f2
}

curl() {
  LD_LIBRARY_PATH=/tmp/sd /tmp/sd/curl -k -q $@
}

photo() {
  message=$(urlencode $2)
  cp $1 /tmp/sd/record/last.jpg
  if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
    curl -F photo="@$1" "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto?chat_id=${TELEGRAM_CHAT_ID}&caption=$message&disable_notification=${TELEGRAM_SILENT}"
  fi
}

video() {
  message=$(urlencode $2)
  cp $1 /tmp/sd/record/last.mp4
  if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
    curl -F video="@$1" "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendVideo?chat_id=${TELEGRAM_CHAT_ID}&caption=$message&disable_notification=${TELEGRAM_SILENT}"
  fi
}

urlencode() {
  url=$(echo "$*" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
  echo $url
}
