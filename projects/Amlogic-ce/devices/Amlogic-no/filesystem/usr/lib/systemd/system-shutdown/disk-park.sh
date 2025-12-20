#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

function disk_park() {
  [ -z "$PARK_WAIT" ] && PARK_WAIT="10"
  echo "disk-park: suspend disks: $PARK_HDD, park time: ${PARK_WAIT}s" >/dev/kmsg

  wait=0
  for dev in /sys/block/sd* ; do
    [ ! -e $dev ] && continue
    DEV="${dev##*/}"
    [ "$(udevadm info --query=all --name=$DEV | awk -F "=" '/ID_MODEL=/{print index($2, "SSD")}')" != "0" ] && continue
    [ -n "$(hdparm -C /dev/$DEV | grep 'standby')" ] && continue
    echo "disk-park: suspend disk /dev/$DEV" >/dev/kmsg
    hdparm -y /dev/$DEV >/dev/null && wait=$PARK_WAIT
  done

  if [ "$wait" = "0" ]; then
    echo "disk-park: no disk got sent to suspend" >/dev/kmsg
  else
    sleep $wait
  fi
}

[ -e /run/disk-park.dat ] && . /run/disk-park.dat || exit 0
[ -z "$PARK_HDD" ] && exit 0

case "$1" in
  reboot|post)
    # do not park disks when rebooting or on suspend resume
    ;;
  *)
    disk_park
    ;;
esac
