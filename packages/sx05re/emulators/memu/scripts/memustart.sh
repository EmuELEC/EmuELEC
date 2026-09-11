#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present worstcase_scenario (https://github.com/worstcase-scenario)
. /etc/profile

ROM="$1"
ROMNAME="${ROM##*/}"
ROMBASE="${ROMNAME%.*}"
EXT="${ROMNAME##*.}"
EXT="${EXT,,}"

CONFIGDIR="/storage/.config/emuelec/configs/memu"
SYSCONFIGDIR="/usr/config/emuelec/configs/memu"

mkdir -p "${CONFIGDIR}/gptk"
mkdir -p "${CONFIGDIR}/autotype"

[ ! -f "${CONFIGDIR}/gptk/memu.gptk" ] && \
    cp "${SYSCONFIGDIR}/gptk/memu.gptk" "${CONFIGDIR}/gptk/memu.gptk"

[ ! -f "${CONFIGDIR}/autotype/default.autotype" ] && \
    cp "${SYSCONFIGDIR}/autotype/default.autotype" \
       "${CONFIGDIR}/autotype/default.autotype"

killall -9 gptokeyb 2>/dev/null

GPTK_CONFIG="${CONFIGDIR}/gptk/memu.gptk"
[ -f "${CONFIGDIR}/gptk/${ROMBASE}.gptk" ] && \
    GPTK_CONFIG="${CONFIGDIR}/gptk/${ROMBASE}.gptk"

gptokeyb 1 memu -c "$GPTK_CONFIG" &
sleep 1

echo 1 > /sys/class/graphics/fb0/osd_clear 2>/dev/null
fbfix 0

cd "${CONFIGDIR}"

case "${EXT}" in
  com)
    MEMU_EXTRA="-cpm -iobyte 0x80"
    ;;
  mtx)
    # Game-specific autotype: /storage/.config/emuelec/configs/memu/autotype/<ROMBASE>.autotype
    # Default: /storage/.config/emuelec/configs/memu/autotype/default.autotype
    AUTOTYPE="${CONFIGDIR}/autotype/default.autotype"
    [ -f "${CONFIGDIR}/autotype/${ROMBASE}.autotype" ] && \
        AUTOTYPE="${CONFIGDIR}/autotype/${ROMBASE}.autotype"
    MEMU_EXTRA="-kbd-type-file ${AUTOTYPE}"
    ;;
  *)
    MEMU_EXTRA=""
    ;;
esac

/usr/bin/memu -vid-win -snd-portaudio ${MEMU_EXTRA} "${ROM}" </dev/tty1

killall -9 gptokeyb 2>/dev/null