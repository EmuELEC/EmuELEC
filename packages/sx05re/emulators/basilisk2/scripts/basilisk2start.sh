#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile

ROM="$1"
ROMNAME="${ROM##*/}"
ROMBASE="${ROMNAME%.*}"

CONF_DIR="/storage/.config/emuelec/configs/basilisk2"
PREFS="${CONF_DIR}/basilisk2.prefs"

# Create prefs from default on first start
mkdir -p "$CONF_DIR"
[ -f "$PREFS" ] || cp /usr/config/emuelec/configs/basilisk2/basilisk2.prefs "$PREFS"

# Kill old instances
killall -9 gptokeyb 2>/dev/null

# Check for game-specific gptk config
GPTK_GAME="${CONF_DIR}/gptk/${ROMBASE}.gptk"
GPTK_DEFAULT="/usr/config/emuelec/configs/basilisk2/gptk/basilisk2.gptk"

if [ -f "$GPTK_GAME" ]; then
    GPTK_CONFIG="$GPTK_GAME"
else
    GPTK_CONFIG="$GPTK_DEFAULT"
fi

# Pause EmulationStation
kill -SIGSTOP $(pgrep emulationstation) 2>/dev/null

# Start gptokeyb
gptokeyb 1 BasiliskII -c "$GPTK_CONFIG" &

sleep 1

# Launch Basilisk II
/usr/bin/BasiliskII --config "$PREFS" --disk "$ROM"

# Resume EmulationStation
kill -SIGCONT $(pgrep emulationstation) 2>/dev/null

# Cleanup
killall -9 gptokeyb 2>/dev/null
