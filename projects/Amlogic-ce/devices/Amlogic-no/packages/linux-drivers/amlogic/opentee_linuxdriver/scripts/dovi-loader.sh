#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

# get coreelec release information
source /etc/os-release

message() {
  >&2 echo "${@}"
}

# Return 1 if given kernel version is lower than current dovi.ko module version
check_dovi_version() {
    version_higher=$(modinfo $1 | awk '/vermagic:/ {split($2, ver, "-"); print ver[1]}' | awk -F '.' \
      -v ker_ver=$2 -v maj_ver=$3 -v min_ver=$4 '{
        if ($1 > ker_ver) { print "Y"; }
        else if ($1 < ker_ver) { print "N"; }
        else {
          if ($2 > maj_ver) { print "Y"; }
          else if ($2 < maj_ver) { print "N"; }
          else {
            if ($3 >= min_ver) { print "Y"; }
            else { print "N"; }
          }
        }
      }')

    if [ "$version_higher" = "Y" ]; then
      return 0
    else
      return 1
    fi
}

insmod_dovi() {
  [ ! -f ${DOVI_KO_ANDROID} ] && return 1

  modinfo ${DOVI_KO_ANDROID}

  if check_dovi_version ${DOVI_KO_ANDROID} 5 15 137; then
    message "loading dovi module from android partition"
    insmod ${DOVI_KO_ANDROID}
  else
    cat > /tmp/dovi.message << 'EOF'
[TITLE]CoreELEC Dolby Vision Media Playback[/TITLE]
[B][COLOR red]Android Dolby Vision kernel module is not compatible[/COLOR][/B]
[COLOR red]No Dolby Vision media playback possible![/COLOR]

Please upgrade Android firmware of your device to minimum Linux kernel version '5.15.137'.
Dolby Vision media will be displayed in HDR instead Dolby Vision until the firmware fulfill the minimum requirements.
EOF
  fi

  return 0
}

load_dovi() {
  # local dovi.ko
  for DOVI_KO_STORAGE in /storage/.config/dovi.ko \
                         /flash/dovi.ko \
                         /storage/dovi.ko \
                         ; do
    if [ -f ${DOVI_KO_STORAGE} ]; then
      message "loading dovi module from ce partition"
      modinfo ${DOVI_KO_STORAGE}
      insmod ${DOVI_KO_STORAGE} && return
    fi
  done

  # Android 12
  if [ -b /dev/oem ]; then
    mountpoint -q /android/oem || mount -o ro /dev/oem /android/oem

    DOVI_KO_ANDROID="/android/oem/overlay/dovi.ko"
    insmod_dovi && return
  fi

  # Android 11
  # if mounted from tee-loader don't mount/unmount from dovi-loader
  if ! ls /dev/mapper/dynpart-* &>/dev/null && [ -b /dev/super ]; then
    dmsetup create --concise "$(parse-android-dynparts /dev/super)"
    systemctl set-environment dmsetup_remove=yes
  fi

  local active_slot=$(fw_printenv active_slot 2>/dev/null | awk -F '=' '/active_slot=/ {print $2}')

  if [ -b /dev/mapper/dynpart-system_a ]; then
    active_slot="_a"
  elif [ -b /dev/mapper/dynpart-system_b ]; then
    active_slot="_b"
  else
    active_slot=""
  fi

  if [ -b /dev/mapper/dynpart-odm${active_slot} ]; then
    mountpoint -q /android/odm || mount -o ro /dev/mapper/dynpart-odm${active_slot} /android/odm

    DOVI_KO_ANDROID="/android/odm/lib/modules/dovi.ko"
    insmod_dovi && return
  fi

  # older Android
  mountpoint -q /android/vendor || mount -o ro /dev/vendor /android/vendor

  for DOVI_KO_ANDROID in /android/vendor/lib/modules/dovi.ko \
                         /android/vendor/lib/modules/dovi_vs10.ko \
                         ; do
    insmod_dovi && return
  done

  cleanup_dovi
}

cleanup_dovi() {
  rmmod dovi 2>/dev/null
  mountpoint -q /android/odm && umount /android/odm
  mountpoint -q /android/oem && umount /android/oem
  mountpoint -q /android/vendor && umount /android/vendor
  # unmount only if mounted from this script
  [ "${dmsetup_remove}" = "yes" ] && \
    ls /dev/mapper/dynpart-* &>/dev/null && dmsetup remove /dev/mapper/dynpart-*
}

message "run dovi '${1}'"

case "${1}" in
  start)
    load_dovi
    ;;
  stop)
    cleanup
    ;;
esac

exit 0
