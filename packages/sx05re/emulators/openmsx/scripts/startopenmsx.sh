#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile

ROM="$1"
ROMNAME="${ROM##*/}"; ROMBASE="${ROMNAME%.*}"; ROMEXT="${ROMNAME##*.}"

export LD_LIBRARY_PATH="/usr/config/emuelec/configs/openmsx/libs:${LD_LIBRARY_PATH}"
export OPENMSX_HOME="/storage/.openMSX"
export LIBGL_VSYNC=0
export LIBGL_NOINTOVLHACK=1
export LIBGL_RECYCLE_EGL=0

# BIOS symlink
mkdir -p /storage/.openMSX/share
[ ! -e /storage/.openMSX/share/systemroms ] && \
  ln -sf /storage/roms/bios/msx /storage/.openMSX/share/systemroms

# gptk
GPTK_DIR="/storage/.config/emuelec/configs/openmsx/gptk"
GPTK_DEFAULT="${GPTK_DIR}/openmsx.gptk"
[ ! -f "${GPTK_DEFAULT}" ] && mkdir -p "${GPTK_DIR}" && \
  cp /usr/config/emuelec/configs/openmsx/gptk/openmsx.gptk "${GPTK_DEFAULT}"
[ -f "${GPTK_DIR}/${ROMBASE}.gptk" ] && GPTK_CONFIG="${GPTK_DIR}/${ROMBASE}.gptk" || GPTK_CONFIG="${GPTK_DEFAULT}"
gptokeyb 1 openmsx -c "${GPTK_CONFIG}" &

# Kill loading screen overlay, freeze ES
pkill -9 ffplay 2>/dev/null
pkill -9 mpv 2>/dev/null
killall -STOP emulationstation 2>/dev/null
killall -STOP es 2>/dev/null
fbfix $(emuelec-utils getmainfb) 2>/dev/null
echo 0 > /sys/class/graphics/fb0/blank 2>/dev/null
sync
sleep 0.3

# Machine selection
case "$ROM" in
  */msx1/*|*/MSX1/*)           MACHINE="msx1" ;;
  */msx2/*|*/MSX2/*)           MACHINE="msx2" ;;
  */msx2+/*|*/MSX2+/*)         MACHINE="msx2plus" ;;
  */msxturbor/*|*/MSXTURBOR/*) MACHINE="turbor" ;;
  *) MACHINE="" ;;
esac
MACHINE_ARG=""
[ -n "$MACHINE" ] && MACHINE_ARG="-machine ${MACHINE}"

# ZIP/M3U extraction
ROMFILE="${ROM}"
TMPDIR=$(mktemp -d /tmp/openmsx_XXXXXX)
if [ "${ROMEXT,,}" = "zip" ]; then
  unzip -o "${ROM}" -d "${TMPDIR}" > /dev/null 2>&1
  EXTRACTED=$(find "${TMPDIR}" -maxdepth 2 -type f | head -1)
  [ -n "${EXTRACTED}" ] && ROMFILE="${EXTRACTED}"
elif [ "${ROMEXT,,}" = "m3u" ]; then
  ROMDIR="$(dirname "${ROM}")"
  line=$(grep -m1 "." "${ROM}" | tr -d '\r')
  ENTRY="${line}"
  [ ! -f "${ENTRY}" ] && ENTRY="${ROMDIR}/${line}"
  # Extract ZIP entry if needed
  if [ "${ENTRY##*.}" = "zip" ] || [ "${ENTRY##*.}" = "ZIP" ]; then
    unzip -o "${ENTRY}" -d "${TMPDIR}" > /dev/null 2>&1
    EXTRACTED=$(find "${TMPDIR}" -maxdepth 2 -type f | head -1)
    [ -n "${EXTRACTED}" ] && ROMFILE="${EXTRACTED}"
  else
    ROMFILE="${ENTRY}"
  fi
fi
ROMEXT="${ROMFILE##*.}"

# Media type
case "${ROMEXT,,}" in
  dsk|dmk) MEDIA="-diska" ;;
  cas)     MEDIA="-cassettefile" ;;
  *)       MEDIA="-cart" ;;
esac

# Settings
[ ! -f "${OPENMSX_HOME}/share/settings.xml" ] && \
  INIT_CMD="set fullscreen on" || \
  INIT_CMD="set fullscreen on"

/usr/bin/openmsx \
  -command "${INIT_CMD}" \
  ${MACHINE_ARG} \
  ${MEDIA} \
  "${ROMFILE}"

killall -9 gptokeyb 2>/dev/null
killall -CONT emulationstation 2>/dev/null
killall -CONT es 2>/dev/null
fbfix $(emuelec-utils getmainfb) 2>/dev/null
rm -rf /tmp/openmsx_* 2>/dev/null
