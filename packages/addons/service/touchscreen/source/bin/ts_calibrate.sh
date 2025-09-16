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

echo "touchscreen device: $TSLIB_TSDEVICE"

if [ "$1" = "service" ]; then
  # recalibrate from service if required
  SETTINGS_XML="$ADDON_HOME/settings.xml"
  if [ -f "$SETTINGS_XML" ]; then
    mkdir -p /var/config

    # check settings version
    XML_SETTINGS_VER="$(xmlstarlet sel -t -m settings -v @version $SETTINGS_XML)"
    if [ "$XML_SETTINGS_VER" = "2" ]; then
      xmlstarlet sel -t -m settings/setting -v @id -o "=\"" -v . -o "\"" -n "$SETTINGS_XML" > /var/config/ts_calibration_addon.conf
    else
      xmlstarlet sel -t -m settings -m setting -v @id -o "=\"" -v @value -o "\"" -n "$SETTINGS_XML" > /var/config/ts_calibration_addon.conf
    fi

    . /var/config/ts_calibration_addon.conf

    if [ "$TS_RECALIBRATE" = "true" ]; then
      sed -i 's|id="TS_RECALIBRATE"[ ]*value="true"|id="TS_RECALIBRATE" value="false"|g' "$SETTINGS_XML"
      touch $ADDON_HOME/recalibrate
    fi
  fi

  if [ -f $ADDON_HOME/recalibrate ]; then
    echo "recalibrating..."
    rm -f $ADDON_HOME/recalibrate
    ts_calibrate
  fi
else
  echo "Stopping Kodi and touchscreen daemon..."
  systemctl stop kodi
  systemctl stop ts_uinput_touch

  while pidof kodi.bin &>/dev/null; do
    sleep 0.5
  done

  killall ts_uinput_touch &>/dev/null

  ts_calibrate

  # restart both if argument was set
  if [ "$1" = "run" ]; then
    echo "Starting touchscreen daemon and Kodi..."
    systemctl start ts_uinput_touch
    systemctl start kodi
  fi
fi
