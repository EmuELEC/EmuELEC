#!/usr/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

EE_DEVICE=$(cat /ee_arch)

ee_console enable

if [[ "${1}" == *"launch_terminal_(kb).sh"* ]]; then
        ee_console disable
    if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
        #kmscon
		kmscon --font-size 8 --login /usr/bin/login -- -p -f root 
    else
		tmpsh=/tmp/tmp.$$.sh
		echo "/usr/bin/login -p -f root" > ${tmpsh}
		chmod +x ${tmpsh}
		fbterm "${tmpsh}" -s 24 < /dev/tty1
		rm ${tmpsh}
    fi
elif [[ "${1}" == *"file_manager.sh"* ]]; then
        if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
            bash "${1}"
        else
            fbterm "${1}" -s 24 < /dev/tty1
        fi
else
		case ${1} in
		"mplayer_video")
            bash playvideo.sh "${2}" "${3}" < /dev/tty0
		;;
		*)
            bash "${1}" > /dev/tty0
        ;;
		esac
fi 

ee_console disable
