#!/bin/bash
# Source predefined functions and variables
. /etc/profile

function macrosetup_confirm() {
    text_viewer -y -w -t "SETUP MACRO" -f 24 -m "This will start the macro setup configuration.\n\nThe setup will guide you through configuring your macro settings.\n\nContinue?"
    if [[ $? == 21 ]]; then
        if macrosetup_start; then
            text_viewer -w -t "MACRO SETUP COMPLETED!" -f 24 -m "Macro setup has been completed successfully!\n\nYour macro configuration has been saved and is ready to use.\n\nYou can now activate macros using the macro activation script."
        else
            text_viewer -e -w -t "MACRO SETUP FAILED!" -f 24 -m "Failed to complete macro setup! Check /tmp/macrosetup.log for details."
        fi
    fi
    ee_console disable
}

function macrosetup_start() {
    ee_console enable
    
    echo "Starting macro setup..."
    echo "Follow the instructions that will appear below:"
    echo ""
    
    # Run Python setup script with logging (but keep interactive output)
    /usr/bin/python3 -u /usr/bin/scripts/setup/macrosetup.py 2>&1 | tee /tmp/macrosetup.log
    setup_result=${PIPESTATUS[0]}
    
    echo ""
    
    # Check if setup completed successfully
    if [[ $setup_result == 0 ]]; then
        echo "Macro setup completed successfully"
        ee_console disable
        rm /tmp/display > /dev/null 2>&1
        return 0
    else
        echo "Failed to complete macro setup"
        ee_console disable
        rm /tmp/display > /dev/null 2>&1
        return 1
    fi
}

macrosetup_confirm