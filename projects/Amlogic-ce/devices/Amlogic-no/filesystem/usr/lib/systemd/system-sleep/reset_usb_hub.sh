#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

case "$1" in
  pre)
    # <do something on suspend>
    ;;
  post)
    # <do something on resume>
    DT_ID=$(dtname)
    case $DT_ID in
      *odroid_n2plus*)
        wol="$(cat /flash/config.ini | awk -F "=" '/^wol=/{gsub(/"|\047/,"",$2); print $2}')"
        if [ "$wol" == "1" ]; then
          echo "reset" > /sys/devices/platform/gpio-reset/reset-usb_hub/control
        fi
        ;;
    esac
    ;;
esac
