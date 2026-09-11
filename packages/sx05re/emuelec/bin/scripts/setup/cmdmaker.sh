#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile

CMD_MAKER_SCRIPT="/usr/bin/scripts/setup/CMD_MAKER.py"

function cmdmaker_confirm() {
    text_viewer -y -w -t "C M D M A K E R" -f 24 -m "Welcome to the .cmd Maker.\n\nThis script will guide you through creating .cmd files for MAME ROMs.\n\n\nIf you want to use your own system-list, put your listmedia.txt into the /storage/roms folder and it will be selectable.\n\n\nController Navigation:\n\n- D-Pad: Navigate menus with up and down, use left and right button for page down and page up\n\n- A/Start: Confirm selection\n- B: Go back\n- Select: Exit program\n\nContinue?"

    if [[ $? == 21 ]]; then
        if cmdmaker_start; then
            text_viewer -w -t "CMD MAKER" -f 24 -m "\nIf you have successfully created your .cmd-files, they are now ready to use.\n\nCheck your ROM directories for the generated files.\n\nIn case you have chosen to also update your gamelist.xml, refresh the gamelists via the menu or restart Emulationstation.\n\nIMPORTANT:\n\nMake sure that the file extension .cmd is available in the extension tag inside es_systems.cfg for the system you have created the cmd files for, otherwise the newly generated .cmd files will not show up on the game list."
        else
            text_viewer -e -w -t "CMD MAKER FAILED!" -f 24 -m "Failed to complete CMD Maker setup!\n\nCheck /tmp/cmdmaker.log for details."
        fi
    fi
}

function cmdmaker_start() {
    ee_console enable

    killall -STOP emulationstation 2>/dev/null || true

    /usr/bin/python3 -u "$CMD_MAKER_SCRIPT" 2>&1 | tee /tmp/cmdmaker.log
    result=${PIPESTATUS[0]}

    killall -CONT emulationstation 2>/dev/null || true
    ee_console disable

    [[ $result == 0 ]]
}

cmdmaker_confirm