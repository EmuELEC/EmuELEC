#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

# We cd into this directory before starting ecwolf
RUN_DIR="/emuelec/configs/ecwolf"
CONFIG_DIR="/emuelec/configs/ecwolf"
CONFIG_FILE="${CONFIG_DIR}/ecwolf.cfg"

params=" --config ${CONFIG_FILE} --savedir ${CONFIG_DIR}"

case $(oga_ver) in
    "OGS")
        params+=" --res 854 480 --fullscreen --aspect 16:9"
    ;;
    "OGA")
        params+=" --res 480 320 --fullscreen --aspect 3:2"
    ;;
    "GF")
        params+=" --res 640 480 --fullscreen --aspect 4:3"
    ;;
    *)
        params+=" --fullscreen --aspect 16:9"
    ;;
esac

# data can be SD2 SD3 SOD WL6 or N3D and it's passed as the ROM
DATA=${1#*.}

# If its a mod (extension .ecwolf) read the file and parse the data
if [ ${DATA} == "ecwolf" ]; then
    while IFS== read -r key value; do
        if [ "${key}" == "SUBDIR" ]; then
	    RUN_DIR="/storage/roms/ports/ecwolf/${value}"
	    # ecwolf does not work without ecwolf.pk3 in the current directory
	    # so we have to copy it there if it not already exists
	    if [ ! -f ${RUN_DIR}/ecwolf.pk3 ]; then
		cp ${CONFIG_DIR}/ecwolf.pk3 ${RUN_DIR}
	    fi
        fi

        if [ "${key}" == "PARAMS" ]; then
            params+=" ${value}"
        fi
    done < <(<"${1}" tr -d '\r'; echo;)
else
    params+=" --data ${DATA}"
fi

# There are mods which have the same files as the original games, so you have
# to put them in subdirectories. ecwolf on the other side has no command line
# parameter to switch to such a subdir, so you have to cd into that dir first.
cd "${RUN_DIR}"
# Do not overwrite log messages already written by emuelecRunEmu.sh
ecwolf ${params} >> /emuelec/logs/emuelec.log 2>&1

