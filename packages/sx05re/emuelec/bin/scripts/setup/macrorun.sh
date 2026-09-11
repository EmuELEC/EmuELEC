#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI
. /etc/profile

SCRIPT="/usr/bin/scripts/setup/macrorun.py"
LOG="/emuelec/logs/macrorun.log"

ee_console enable

TTY="/dev/tty1"
[[ -w "$TTY" ]] || TTY="/dev/tty0"
[[ -w "$TTY" ]] || TTY="/dev/console"
exec <"$TTY" >"$TTY" 2>&1

for b in /sys/class/graphics/fb0/blank /sys/class/graphics/fb1/blank; do
    [[ -w "$b" ]] && echo 0 >"$b"
done
command -v setterm >/dev/null 2>&1 && setterm -blank 0 -powerdown 0 -powersave off >"$TTY" 2>/dev/null || true

clear

if [[ ! -f "$SCRIPT" ]]; then
    echo "ERROR: macrorun.py not found at $SCRIPT"
    ee_console disable
    exit 1
fi

mkdir -p "$(dirname "$LOG")"
/usr/bin/python3 -u "$SCRIPT" 2>&1 | tee "$LOG"
result=${PIPESTATUS[0]}

ee_console disable
rm -f /tmp/display 2>/dev/null

if [[ $result == 0 ]]; then
    text_viewer -w -t "MACRO ENABLER" -f 24 \
        -m "If you have activated macro mode, DO NOT press the press the trigger button while in EmulationStation, otherwise the setup screen will pop up.\n\nPress the hotkey button to exit that routine.\n\nTo DISABLE the macro, hold the macro button for 3-5 seconds."
else
    text_viewer -e -w -t "MACRO ENABLER" -f 24 \
        -m "Cancelled or error.\n\nSee: $LOG"
fi
