#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

. /etc/profile

EKA_INSTALL_SCRIPT="/usr/bin/scripts/setup/EKA_INSTALL.py"

function ekainstall_confirm() {
    text_viewer -y -w -t "E K A 2 L 1   C O M M A N D E R" -f 24 -m "Welcome to the eka2l1 Commander.\n\nUse this tool to setup eka2l1, install firmware and .sis/.sisx apps, import pre-configured device folders, change the active device, create .uid launcher files for installed applications, and convert selected device folders and their contents to lowercase so EKA2L1 can access case-sensitive paths correctly.\n\nController Navigation:\n\n- D-Pad: Navigate menus\n- A / Start: Confirm selection\n- B: Go back\n- Select: Exit program\n\nContinue?"
    if [[ $? == 21 ]]; then
        if ekainstall_start; then
            text_viewer -w -t "EKA2L1 COMMANDER" -f 24 -m "\n\nLaunch eka2l1 via EmulationStation."
        else
            text_viewer -e -w -t "EKA2L1 COMMANDER FAILED" -f 24 -m "There has been an error!\n\nCheck /emuelec/logs/eka2l1-install.log for details."
        fi
    fi
    ee_console disable
}

function ekainstall_start() {
    ee_console enable

    local timeout=10
    while pgrep -x text_viewer > /dev/null 2>&1 && [[ $timeout -gt 0 ]]; do
        sleep 0.2
        timeout=$((timeout - 1))
    done

    killall -STOP emulationstation 2>/dev/null || true

    /usr/bin/python3 -u "$EKA_INSTALL_SCRIPT" 2>&1 | tee /emuelec/logs/eka2l1-install.log
    setup_result=${PIPESTATUS[0]}

    killall -CONT emulationstation 2>/dev/null || true
    ee_console disable

    [[ $setup_result == 0 ]]
}

ekainstall_confirm