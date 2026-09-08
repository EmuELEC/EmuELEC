#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

. /etc/profile

DREAMM_COMMANDER_SCRIPT="/usr/bin/scripts/setup/DREAMM_INSTALL.py"

function dreammcommander_confirm() {
    text_viewer -y -w -t "D R E A M M   C O M M A N D E R" -f 24 -m "Welcome to DREAMM Commander.\n\nUse this tool to install LucasArts games into DREAMM from folders or disk images, to turn installed games into .dreamm entries so EmulationStation lists them, and to build .dreamm launcher files by hand for titles DREAMM does not recognise.\n\nController Navigation:\n\n- D-Pad: Navigate menus\n- A / Start: Confirm selection\n- B: Go back\n- Select: Exit program\n\nContinue?"
    if [[ $? == 21 ]]; then
        if dreammcommander_start; then
            text_viewer -w -t "DREAMM COMMANDER" -f 24 -m "\n\nLaunch DREAMM via EmulationStation."
        else
            text_viewer -e -w -t "DREAMM COMMANDER FAILED" -f 24 -m "There has been an error!\n\nCheck /emuelec/logs/dreamm-commander.log for details."
        fi
    fi
    ee_console disable
}

function dreammcommander_start() {
    ee_console enable

    local timeout=10
    while pgrep -x text_viewer > /dev/null 2>&1 && [[ $timeout -gt 0 ]]; do
        sleep 0.2
        timeout=$((timeout - 1))
    done

    killall -STOP emulationstation 2>/dev/null || true

    /usr/bin/python3 -u "$DREAMM_COMMANDER_SCRIPT" 2>&1 | tee /emuelec/logs/dreamm-commander.log
    setup_result=${PIPESTATUS[0]}

    killall -CONT emulationstation 2>/dev/null || true
    ee_console disable

    [[ $setup_result == 0 ]]
}

dreammcommander_confirm