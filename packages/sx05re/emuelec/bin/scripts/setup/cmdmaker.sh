#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

# Source predefined functions and variables
. /etc/profile

CMD_MAKER_SCRIPT="/usr/bin/scripts/setup/CMD_MAKER.py"

function cmdmaker_confirm() {
    text_viewer -y -w -t "C M D  M A K E R" -f 24 -m "Welcome to the .cmd Maker.\n\nThis script will guide you through creating .cmd files for MAME ROMs.\n\nController Navigation:\n\n- D-Pad: Navigate menus\n- A/Start: Confirm selection\n- B: Go back\n- Select: Exit program\n\nContinue?"
    
    if [[ $? == 21 ]]; then
        if cmdmaker_start; then
            text_viewer -w -t "CMD MAKER" -f 24 -m "\nIf you have created your .cmd-files, they are now ready to use.\n\nCheck your ROM directories for the generated files.\n\nIn case you have chosen to also update your gamelist.xml, refresh the gamelists via the menu or restart Emulationstation.\n\nIMPORTANT:\n\nMake sure that the file extension .cmd is available in the extension tag inside es_systems.cfg for the system you have created the cmd files for, otherwise the newly generated .cmd files will not show up on the game list."
        else
            text_viewer -e -w -t "CMD MAKER FAILED!" -f 24 -m "Failed to complete CMD Maker setup!\n\nCheck /tmp/cmdmaker.log for details."
        fi
    fi
    
    ee_console disable
}

function cmdmaker_start() {
    ee_console enable

    # Prefer a real VT device for output
    TTY="/dev/tty1"
    [[ -w "$TTY" ]] || TTY="/dev/tty0"
    [[ -w "$TTY" ]] || TTY="/dev/console"

    # Redirect this script's stdio to the VT so output is always visible on-screen
    exec <"$TTY" >"$TTY" 2>&1

    # Unblank framebuffer (screensaver/DPMS can leave it black)
    for b in /sys/class/graphics/fb0/blank /sys/class/graphics/fb1/blank; do
        [[ -w "$b" ]] && echo 0 >"$b"
    done

    # Disable console blanking/powersave if setterm exists
    if command -v setterm >/dev/null 2>&1; then
        setterm -blank 0 -powerdown 0 -powersave off >"$TTY" 2>/dev/null || true
    fi

    clear

    echo "=========================================="
    echo "   E m u E L E C ' s  C M D  M A K E R    "
    echo "=========================================="
    echo ""
    echo "Starting CMD Maker..."
    echo "Follow the instructions that will appear below:"
    echo ""

    if [[ ! -f "$CMD_MAKER_SCRIPT" ]]; then
        echo "ERROR: CMD_MAKER.py not found at $CMD_MAKER_SCRIPT"
        echo ""
        ee_console disable
        return 1
    fi

    chmod +x "$CMD_MAKER_SCRIPT"
    echo ""
    echo "Starting interactive mode..."
    echo ""
    sleep 1

    rm -f /tmp/cmdmaker.ret >/dev/null 2>&1

    if command -v openvt >/dev/null 2>&1; then
        # Run inside a real VT; keeps output visible even after screensaver
        openvt -c 1 -s -f -- /bin/sh -c "/usr/bin/python3 -u '$CMD_MAKER_SCRIPT' 2>&1 | tee /tmp/cmdmaker.log; echo \$? >/tmp/cmdmaker.ret"
        setup_result=$(cat /tmp/cmdmaker.ret 2>/dev/null || echo 1)
    else
        /usr/bin/python3 -u "$CMD_MAKER_SCRIPT" 2>&1 | tee /tmp/cmdmaker.log
        setup_result=${PIPESTATUS[0]}
    fi

    echo ""

    if [[ $setup_result == 0 ]]; then
        echo "CMD Maker completed successfully"
        echo ""
        ee_console disable
        rm /tmp/display > /dev/null 2>&1
        return 0
    else
        echo "CMD Maker exited with code: $setup_result"
        echo ""
        ee_console disable
        rm /tmp/display > /dev/null 2>&1
        return 1
    fi
}


# Start CMD Maker
cmdmaker_confirm