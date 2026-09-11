#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile

ROM="$1"
ROMNAME="${ROM##*/}"; ROMBASE="${ROMNAME%.*}"

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
GPTK_LD="${GPTK_DIR}/openmsx-ld.gptk"
[ ! -f "${GPTK_LD}" ] && mkdir -p "${GPTK_DIR}" && \
  cp /usr/config/emuelec/configs/openmsx/gptk/openmsx-ld.gptk "${GPTK_LD}"
[ -f "${GPTK_DIR}/${ROMBASE}.gptk" ] && GPTK_CONFIG="${GPTK_DIR}/${ROMBASE}.gptk" || GPTK_CONFIG="${GPTK_LD}"
gptokeyb 1 openmsx-ld -c "${GPTK_CONFIG}" &

# ----------------------------
# FIX: LOADSCREEN / OVERLAY
# ----------------------------
pkill -9 ffplay 2>/dev/null
pkill -9 mpv 2>/dev/null

killall -STOP emulationstation 2>/dev/null
killall -STOP es 2>/dev/null

fbfix $(emuelec-utils getmainfb) 2>/dev/null
echo 0 > /sys/class/graphics/fb0/blank 2>/dev/null

sync
sleep 0.3
# ----------------------------


# Settings
[ ! -f "${OPENMSX_HOME}/share/settings.xml" ] && \
    INIT_CMD="set fullscreen on" || \
    INIT_CMD="set fullscreen on"

/usr/bin/openmsx-ld \
  -command "${INIT_CMD}" \
  -machine Pioneer_PX-7 \
  -laserdisc "${ROM}"

killall -9 gptokeyb 2>/dev/null
killall -CONT emulationstation 2>/dev/null
fbfix $(emuelec-utils getmainfb) 2>/dev/null