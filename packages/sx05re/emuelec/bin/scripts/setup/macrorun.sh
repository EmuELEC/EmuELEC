#!/bin/bash
# Source predefined functions and variables
. /etc/profile

function macro_confirm() {
    text_viewer -y -w -t "ACTIVATE MACRO" -f 24 -m "This will activate the macro mode in the background.\n\nThe macro will be active while you continue using EmulationStation. \n\nContinue?"
    if [[ $? == 21 ]]; then
        if macro_start; then
            text_viewer -w -t "MACRO ACTIVATED!" -f 24 -m "Macro mode is now active in the background!\n\nATTENTION: DO NOT press the trigger button as long as you are in Emulationstation, otherwise the new controller-setup screen will pop up.\n\nIn this case, just press the hotkey button to exit the routine.\n\nTo DISABLE the macro, press the macro button for around 3-5 seconds."
        else
            text_viewer -e -w -t "MACRO ACTIVATION FAILED!" -f 24 -m "Failed to avtivate macro mode! Check /tmp/macrorun.log for details."
        fi
    fi
    ee_console disable
}

function macro_start() {
    ee_console enable
    
    echo "Starting macro run..."
    
    # Start Python script in background
    nohup /usr/bin/python3 /usr/bin/scripts/setup/macrorun.py > /tmp/macrorun.log 2>&1 &
    
    # Wait briefly and check
    sleep 2
    
    if pgrep -f "macrorun.py" > /dev/null; then
        echo "Macro script started successfully"
        ee_console disable
        rm /tmp/display > /dev/null 2>&1
        return 0
    else
        echo "Failed to start macro script"
        ee_console disable
        rm /tmp/display > /dev/null 2>&1
        return 1
    fi
}

macro_confirm
