#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Harakiri (https://github.com/worstcase-scenario)
#
# dreammstart.sh - DREAMM launcher for EmuELEC
#
. /etc/profile

# Software mouse pointer: EmuELEC's SDL2 only ships the "mali" and "offscreen"
# video drivers, neither of which implements a hardware cursor.
export LD_PRELOAD="/usr/lib/dreamm_cursor.so"
export DREAMM_CURSOR_SCALE="${DREAMM_CURSOR_SCALE:-3}"
export DREAMM_CURSOR_TOGGLE="${DREAMM_CURSOR_TOGGLE:-66}"   # F9
export DREAMM_MENU_KEY="${DREAMM_MENU_KEY:-67}"             # F10 -> F12

export LIBGL_NOTEST=1
export SDL_VIDEODRIVER=mali

# DREAMM ROM directory
USERPATH="/storage/roms/dreamm"
LOGFILE="/emuelec/logs/dreamm.log"

dir="${1%/}"
ROMNAME="${dir##*/}"
ROMBASE="${ROMNAME%.*}"

mkdir -p "$(dirname "$LOGFILE")" "$USERPATH"

killall -9 gptokeyb 2>/dev/null

GPTK_GAME="/storage/.config/emuelec/configs/gptokeyb/dreamm/${ROMBASE}.gptk"
GPTK_DEFAULT="/emuelec/configs/gptokeyb/dreamm.gptk"

if [ -f "$GPTK_GAME" ]; then
    GPTK_CONFIG="$GPTK_GAME"
else
    GPTK_CONFIG="$GPTK_DEFAULT"
fi

# Per-game overrides: DREAMM_CURSOR=0 for titles drawing their own pointer,
# DREAMM_GPTOKEYB=0 for joystick games so DREAMM can grab the pad itself
if [ -d "$dir" ] && [ -f "${dir}/dreamm.conf" ]; then
    . "${dir}/dreamm.conf"
fi

if [ -z "$dir" ]; then
    MODE=""
elif [ ! -e "$dir" ]; then
    echo "ERROR: path not found: $dir" | tee -a "$LOGFILE"
    exit 1
elif [ -d "$dir" ]; then
    MODE="-run"
else
    MODE="-launch"
fi

if [ "${DREAMM_GPTOKEYB:-1}" = "1" ]; then
    gptokeyb 1 dreamm -c "$GPTK_CONFIG" &
    sleep 1
fi

{
    echo "=== $(date) ==="
    echo "MODE: ${MODE:-frontend}"
    echo "GAME: ${dir:-none}"
    echo "GPTK: ${GPTK_CONFIG}"

    if [ -n "$MODE" ]; then

        echo "COMMAND: dreamm -sdl -fullscreen $MODE \"$dir\""

        dreamm \
            -sdl \
            -fullscreen \
            "$MODE" \
            "$dir"

        DREAMM_EXIT=$?
        echo "DREAMM EXIT CODE: $DREAMM_EXIT"

    else

        echo "COMMAND: dreamm -sdl -fullscreen"

        dreamm \
            -sdl \
            -fullscreen

        DREAMM_EXIT=$?
        echo "DREAMM EXIT CODE: $DREAMM_EXIT"

    fi
} >> "$LOGFILE" 2>&1

killall -9 gptokeyb 2>/dev/null

exit "${DREAMM_EXIT:-0}"
