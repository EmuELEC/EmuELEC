#!/usr/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/EmuELEC)

. /etc/profile

RUN_DIR="/storage/roms/ports/doom"
CONFIG_DIR="/emuelec/configs/gzdoom"
HOMECONFIG="/storage/.config/gzdoom"

# Check for newer pk3 files
SHASUMSRC=$(sha256sum "/usr/config/emuelec/configs/gzdoom/gzdoom.pk3" | awk '{print $1}')
SHASUMDST=$(sha256sum "${CONFIG_DIR}/gzdoom.pk3" | awk '{print $1}')

if [ $SHASUMSRC != $SHASUMDST ]; then
  cp /usr/config/emuelec/configs/gzdoom/*.pk3 ${CONFIG_DIR}
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
/usr/bin/gzdoom ${params} >>/emuelec/logs/emuelec.log 2>&1
