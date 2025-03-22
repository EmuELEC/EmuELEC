#!/usr/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

RUN_DIR="/storage/roms/ports/doom"
CONFIG_DIR="/emuelec/configs/chocolate-doom"
LOCALCONFIG="/storage/.local/share/chocolate-doom"

params=" --savedir ${CONFIG_DIR}"

if [ ! -L "${LOCALCONFIG}" ]; then 
[[ -d "${LOCALCONFIG}" ]] && rm -rf "${LOCALCONFIG}"
ln -sf "${CONFIG_DIR}" "${LOCALCONFIG}"
fi

GUID=$(echo "${2}" | grep -Ewo '[[:xdigit:]]{32}' | head -n1)
# echo "Will use controller with ${GUID}"
# Try to set up gamepad
sed -i "s|joystick_guid.*|joystick_guid                 \"${GUID}\"|" "${CONFIG_DIR}/chocolate-doom.cfg"

# EXT can be wad, WAD, iwad, IWAD, pwad, PWAD or choco
FILE=$(basename -- "${1}")
EXT=${1#*.}

# If its not a simple wad (extension .doom) read the file and parse the data
if [ ${EXT} == "doom" ]; then
    while IFS== read -r key value; do
	if [ "${key}" == "GAMETYPE" ]; then
	    case ${value} in
		"doom"|"DOOM")
		    PROGRAM="chocolate-doom"
		;;
		"heretic"|"HERETIC")
		    PROGRAM="chocolate-heretic"
		;;
		"hexen"|"HEXEN")
		    PROGRAM="chocolate-hexen"
		;;
		"strife"|"STRIFE")
		    PROGRAM="chocolate-strife"
		;;
		*)
		    PROGRAM="chocolate-doom"
		;;
	    esac
	fi

        if [ "${key}" == "SUBDIR" ]; then
	    RUN_DIR="/storage/roms/ports/doom/${value}"
        fi

        if [ "${key}" == "PARAMS" ]; then
            params+=" ${value}"
        fi
    done < <(<"${1}" tr -d '\r'; echo;)
else
    PROGRAM="chocolate-doom"
    params+=" -iwad ${1}"
fi

cd "${RUN_DIR}"
# Do not overwrite log messages already written by emuelecRunEmu.sh
/usr/bin/${PROGRAM} ${params} >>/emuelec/logs/emuelec.log 2>&1

