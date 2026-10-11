#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile

OPTS_MAKER_SCRIPT="/usr/bin/scripts/setup/OPTS_MAKER.py"

function optsmaker_confirm() {
    text_viewer -y -w -t "O P T S  M A K E R" -f 24 -m "Welcome to the .opts Maker for the Tsugaru FM Towns emulator.\n\nThis tool creates per-game .opts files. The first line of a .opts file is appended to the tsugaru command line by tsugarustart.sh - later options override the launcher defaults.\n\nAvailable settings per game:\n\n- Gameport 0/1 (pad, pad-as-mouse, host mouse, keyboard)\n- CD speed, mouse speed, RAM size, CPU fidelity\n- Free options for everything else (e.g. -APP presets)\n\nController Navigation:\n\n- D-Pad: Navigate menus, left/right cycles values\n- A/Start: Confirm selection\n- B: Go back\n- Select: Exit program\n\nContinue?"

    if [[ $? == 21 ]]; then
        if optsmaker_start; then
            text_viewer -w -t "OPTS MAKER" -f 24 -m "\nYour .opts files are saved next to the ROMs and take effect on the next game launch.\n\nExample result:\n-GAMEPORT1 ANA1MOUSE\n(left analog stick controls the Towns mouse)\n\nTo remove per-game options, open the game again and choose '.opts loeschen'."
        else
            text_viewer -e -w -t "OPTS MAKER FAILED!" -f 24 -m "Failed to complete OPTS Maker!\n\nCheck /tmp/optsmaker.log for details."
        fi
    fi
}

function optsmaker_start() {
    ee_console enable

    killall -STOP emulationstation 2>/dev/null || true

    /usr/bin/python3 -u "$OPTS_MAKER_SCRIPT" 2>&1 | tee /tmp/optsmaker.log
    result=${PIPESTATUS[0]}

    killall -CONT emulationstation 2>/dev/null || true
    ee_console disable

    [[ $result == 0 ]]
}

optsmaker_confirm