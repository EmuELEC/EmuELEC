#!/bin/bash
. /etc/profile

macro_confirm() {
    text_viewer -y -w -t "ACTIVATE MACRO" -f 24 -m "This will activate the macro mode in the background.\n\nThe macro will be active while you continue using EmulationStation.\n\nContinue?"
    if [[ $? == 21 ]]; then
        if macro_start; then
			text_viewer -w -t "MACRO ACTIVATED!" -f 24 -m "Macro mode is now active in the background!\n\nATTENTION: DO NOT press the trigger button as long as you are in Emulationstation, otherwise the new controller-setup screen will pop up.\n\nIn this case, just press the hotkey button to exit the routine.\n\nTo DISABLE the macro again, press the macro button for around 3-5 seconds."
        else
            text_viewer -e -w -t "MACRO ACTIVATION FAILED!" -f 24 -m "Failed to activate macro mode! Check /tmp/macrorun.log for details."
        fi
    fi
    ee_console disable
}

macro_start() {
    ee_console enable
    echo "Starting macro run (foreground menu, then daemonize)..."
	
    /usr/bin/python3 -u /usr/bin/scripts/setup/macrorun.py
    rc=$?

   
    sleep 1
    if [[ -f /tmp/macrorun.pid ]] && ps -p "$(cat /tmp/macrorun.pid)" >/dev/null 2>&1; then
        echo "Macro daemon running with PID $(cat /tmp/macrorun.pid)"
        ee_console disable
        rm /tmp/display >/dev/null 2>&1
        return 0
    fi

  
    if pgrep -f "Virtual-Macro" >/dev/null 2>&1 || pgrep -f "/usr/bin/scripts/setup/macrorun.py" >/dev/null 2>&1; then
        ee_console disable
        rm /tmp/display >/dev/null 2>&1
        return 0
    fi

    echo "Macro daemon not detected (rc=${rc})"
    ee_console disable
    rm /tmp/display >/dev/null 2>&1
    return 1
}

macro_confirm
