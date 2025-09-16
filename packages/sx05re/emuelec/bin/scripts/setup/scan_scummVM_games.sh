#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

function restart_confirm() {
    text_viewer -y -w -t "ScummVM scan completed" -f 24 -m "ScummVM scan completed, any found games will appear next time you restart Emulationstation!\n\nDo you wish to restart now?"
	[[ $? == 21 ]] && systemctl restart emustation || exit 0; 
}

ee_console enable
bash /usr/bin/scummvm.start add
bash /usr/bin/scummvm.start create
ee_console disable
restart_confirm
