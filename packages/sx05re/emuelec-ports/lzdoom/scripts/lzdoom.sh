#!/usr/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

RUN_DIR="/storage/roms/ports/doom"
CONFIG_DIR="/emuelec/configs/lzdoom"
HOMECONFIG="/storage/.config/lzdoom"

if [ /usr/config/emuelec/configs/lzdoom/lzdoom.pk3 -nt ${CONFIG_DIR}/lzdoom.pk3 ]; then
    cp /usr/config/emuelec/configs/lzdoom/*.pk3 ${CONFIG_DIR}
fi

if [ ! -L "${HOMECONFIG}" ]; then
[[ -d "${HOMECONFIG}" ]] && rm -rf "${HOMECONFIG}"
ln -sf "${CONFIG_DIR}" "${HOMECONFIG}"
fi

params=" -savedir ${CONFIG_DIR}"

# EXT can be wad, WAD, iwad, IWAD, pwad, PWAD or doom
EXT=${1#*.}

# If its not a simple wad (extension .choco) read the file and parse the data
if [ "${EXT}" == "doom" ]; then
    while IFS== read -r key value; do
        if [ "${key}" == "SUBDIR" ]; then
            RUN_DIR="/storage/roms/ports/doom/${value}"
        fi

        if [ "${key}" == "PARAMS" ]; then
            params+=" ${value}"
        fi
    done < <(<"${1}" tr -d '\r'; echo;)
else
    params+=" -iwad ${1}"
fi

cd "${RUN_DIR}"
# Do not overwrite log messages already written by emuelecRunEmu.sh
/usr/bin/lzdoom ${params} >>/emuelec/logs/emuelec.log 2>&1
