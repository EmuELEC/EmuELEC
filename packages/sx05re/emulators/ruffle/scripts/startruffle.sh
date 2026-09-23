#!/bin/bash
# startruffle.sh <path/to/game.swf>
# Runs an SWF with native Ruffle (ruffle4consoles, SDL2 + GLES2).
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# MADE WITH THE HELP OF CLAUDE.AI

. /etc/profile

ROM="$1"
[ -f "$ROM" ] || exit 1

GPTKDIR="/storage/.config/emuelec/configs/ruffle/gptk"

# Ruffle expects its content next to the working directory as
# ./ruffle_data/movie.swf, so every launch gets its own session directory.
SESSION="/tmp/ruffle-session-$$"
rm -rf "$SESSION"
mkdir -p "$SESSION/ruffle_data/storage"
ln -sf "$ROM" "$SESSION/ruffle_data/movie.swf"

# EmuELEC's SDL2 only provides the mali and offscreen video backends, and mali
# has no hardware cursor - the preloaded shim draws one from the mouse events.
export SDL_VIDEODRIVER=mali
export SDL_AUDIODRIVER=alsa
export LD_PRELOAD="/usr/bin/ruffle_cursor.so"

# gptokeyb: a .gptk named like the SWF next to it wins over the default
kill -9 $(pidof gptokeyb) 2>/dev/null
GPTK="$GPTKDIR/flash.gptk"
[ -f "${ROM%.swf}.gptk" ] && GPTK="${ROM%.swf}.gptk"
gptokeyb 1 ruffle.aarch64 -c "$GPTK" -killsignal 15 &
sleep 0.5

cd "$SESSION" || exit 1
/usr/bin/ruffle.aarch64

# Cleanup
kill -9 $(pidof gptokeyb) 2>/dev/null
cd /
rm -rf "$SESSION"