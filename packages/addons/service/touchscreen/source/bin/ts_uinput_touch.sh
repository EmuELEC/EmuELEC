#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

. /etc/profile

oe_setup_addon service.touchscreen

if [ -d /usr/share/kodi/addons/service.touchscreen ]; then
  # addon included in image
  ADDON_DIR="/usr/share/kodi/addons/service.touchscreen"
fi

. $ADDON_DIR/bin/ts_env.sh

params=$*

if [ "$1" = "service" ]; then
  # skip service parameter and daemonize
  params="-d"
else
  # started from command line
  systemctl stop ts_uinput_touch >/dev/null 2>&1
  killall ts_uinput_touch >/dev/null 2>&1
fi

echo "    touchscreen device: '$TSLIB_TSDEVICE'"

if [ -n "$TSLIB_RES_X" -a -n "$TSLIB_RES_Y" ]; then
  echo "touchscreen resolution: '${TSLIB_RES_X}x${TSLIB_RES_Y}'"
  params="-x $TSLIB_RES_X -y $TSLIB_RES_Y $params"
fi

echo "params: .$params."
if [ ! -x $ADDON_HOME/ts_uinput_touch ]; then
  ts_uinput_touch $params
else
  echo "Using $ADDON_HOME/ts_uinput_touch"
  $ADDON_HOME/ts_uinput_touch $params
fi
