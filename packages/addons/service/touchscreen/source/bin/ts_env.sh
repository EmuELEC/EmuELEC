#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

. /etc/profile

oe_setup_addon service.touchscreen

if [ -d /usr/share/kodi/addons/service.touchscreen ]; then
  # addon included in image
  ADDON_DIR=/usr/share/kodi/addons/service.touchscreen
fi

if [ ! -f $ADDON_HOME/ts.conf-generic ]; then
  cp $ADDON_DIR/config/* $ADDON_HOME
fi

if [ -f $ADDON_HOME/ts_env.sh ]; then
  # use user supplied script
  if [ ! -x $ADDON_HOME/ts_env.sh ]; then
    chmod +x $ADDON_HOME/ts_env.sh
  fi
  
  dos2unix $ADDON_HOME/ts_env.sh
  dos2unix $ADDON_HOME/ts.conf

  . $ADDON_HOME/ts_env.sh
else
  # automatic start only on Udoo dual/quad for ldb screen
  LDB=""
  if grep -iq ":dev=ldb" /proc/cmdline; then
    LDB="yes"
    # maybe 7" LVDS display
    modprobe st1232 >/dev/null 2>&1
  fi

  if [ -n "$LDB" ]; then
    # find event# with command
    #  ls -l /dev/input/by-id
    # or using evtest program

    # st1232 module is always loaded so check for 3M first
    TS_DEVICE_1="3M 3M USB Touchscreen - EX II"
    TS_DEVICE_2="st1232-touchscreen"
    TS_DEVICE_CONF_1="ts.conf-udoo_15_6"
    TS_DEVICE_CONF_2="ts.conf-udoo_7"
    TS_DEVICE_CONF_GENERIC="ts.conf-generic"

    #TS_DEVICE="$TS_DEVICE_1" # use specified one, should exist ts.conf for it
    TS_DEVICE=""  # find one automatically
    #echo "device: $TS_DEVICE"

    TS_DEVICE_CONF=""
    if [ -n "$TS_DEVICE" ]; then
      TSLIB_TSDEVICE=$(echo 999 | evtest 2>&1 >/dev/null | awk -F':' -v TS_DEVICE="$TS_DEVICE" '$0 ~ TS_DEVICE {print $1}')
      TS_DEVICE_CONF="$TS_DEVICE_CONF_GENERIC"
    else
      TSLIB_TSDEVICE=$(echo 999 | evtest 2>&1 >/dev/null | awk -F':' -v TS_DEVICE="$TS_DEVICE_1" '$0 ~ TS_DEVICE {print $1}')
      if [ -n "$TSLIB_TSDEVICE" ]; then
        TS_DEVICE_CONF="$TS_DEVICE_CONF_1"
        rmmod st1232 >/dev/null 2>&1    # it's not
      else
        TSLIB_TSDEVICE=$(echo 999 | evtest 2>&1 >/dev/null | awk -F':' -v TS_DEVICE="$TS_DEVICE_2" '$0 ~ TS_DEVICE {print $1}')
        if [ -n "$TSLIB_TSDEVICE" ]; then
          TS_DEVICE_CONF="$TS_DEVICE_CONF_2"
        fi
      fi
    fi

    if [ ! -f $ADDON_HOME/ts.conf -a -n "$TS_DEVICE_CONF" ]; then
      cp "$ADDON_HOME/$TS_DEVICE_CONF" $ADDON_HOME/ts.conf
    fi

    export TSLIB_TSDEVICE="$TSLIB_TSDEVICE"
    export TSLIB_PLUGINDIR=$ADDON_DIR/lib
    export TSLIB_CONSOLEDEVICE=none
    export TSLIB_FBDEVICE=/dev/fb0
    export TSLIB_CALIBFILE=$ADDON_HOME/pointercal
    export TSLIB_CONFFILE=$ADDON_HOME/ts.conf

    #export TSLIB_RES_X=800
    #export TSLIB_RES_Y=480
  fi
fi
