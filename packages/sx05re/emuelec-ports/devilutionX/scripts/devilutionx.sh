#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

DIABLOPATH="/storage/.local/share/diasurgical/devilution"
DIABLOROMPATH="/storage/roms/ports/diablo"

EELANG=$(echo ${LANG} | cut -d= -f2 | cut -d_ -f1)

if [ "${EELANG}" == "en" ]; then
    LANG=""
fi

mkdir -p ${DIABLOPATH}

if [ -e ${DIABLOPATH}/diablo.ini ]; then
    sed -i "s|Code=.*|Code=${EELANG}|g" ${DIABLOPATH}/diablo.ini
fi

if [ -e ${DIABLOROMPATH}/diabdat.mpq ]; then
    if [ ! -L ${DIABLOPATH}/diabdat.mpq ]; then
        ln -sf ${DIABLOROMPATH}/diabdat.mpq ${DIABLOPATH}/diabdat.mpq
    fi
else
    exit 21
fi

if [ "${1}" == "hellfire" ]; then
    for hell in diabdat hellfire hfmonk hfmusic hfvoice; do
        if [ -e ${DIABLOROMPATH}/${hell}.mpq ]; then
            if [ ! -L ${DIABLOPATH}/${hell}.mpq ]; then
                ln -sf ${DIABLOROMPATH}/${hell}.mpq ${DIABLOPATH}/${hell}.mpq
            fi
        else
            exit 21
        fi
    done
else
PARAMS=" --diablo"
fi 

devilutionx --verbose ${PARAMS}
