#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

. /etc/profile

BT_COMMANDER_SCRIPT="/usr/bin/scripts/setup/BT_COMMANDER.py"
RESTART_MARKER="/tmp/bt-commander.restart-es"

function wait_for_text_viewer() {
    local timeout=10
    while pgrep -x text_viewer > /dev/null 2>&1 && [[ $timeout -gt 0 ]]; do
        sleep 0.2
        timeout=$((timeout - 1))
    done
}

function btcommander_confirm() {
    text_viewer -y -w -t "B T   C O M M A N D E R" -f 24 -m "Welcome to BT Commander.\n\nUse this tool to scan for Bluetooth audio devices, to pair and connect them with A2DP audio routing, to reconnect the device you used last, and to remove a pairing again.\n\nController Navigation:\n\n- D-Pad: Navigate menus\n- A / Start: Confirm selection\n- B: Go back\n- Select: Exit program\n\nContinue?"
    if [[ $? == 21 ]]; then
        if btcommander_start; then
            # Nothing to show when EmulationStation is about to restart: a
            # dialog drawn over the starting frontend stays on screen.
            if [[ ! -f "$RESTART_MARKER" ]]; then
                text_viewer -w -t "BT COMMANDER" -f 24 -m "\n\nBluetooth setup finished."
            fi
        else
            text_viewer -e -w -t "BT COMMANDER FAILED" -f 24 -m "There has been an error!\n\nCheck /emuelec/logs/bt-commander.log for details."
        fi
    fi
    ee_console disable

    # Last action of all: the tool leaves this marker when it changed the
    # system audio routing, and EmulationStation has to restart to pick up
    # the new SDL audio driver.
    if [[ -f "$RESTART_MARKER" ]]; then
        rm -f "$RESTART_MARKER"
        wait_for_text_viewer
        systemctl restart emustation
    fi
}

function btcommander_start() {
    ee_console enable

    # fbcon blanks the console after 600 seconds by default, which takes the
    # framebuffer with it while the tool is still running. Turn the timeout off.
    echo -e '\033[9;0]' > /dev/tty0

    wait_for_text_viewer

    killall -STOP emulationstation 2>/dev/null || true

    /usr/bin/python3 -u "$BT_COMMANDER_SCRIPT" 2>&1 | tee /emuelec/logs/bt-commander.log
    setup_result=${PIPESTATUS[0]}

    killall -CONT emulationstation 2>/dev/null || true
    ee_console disable

    [[ $setup_result == 0 ]]
}

btcommander_confirm