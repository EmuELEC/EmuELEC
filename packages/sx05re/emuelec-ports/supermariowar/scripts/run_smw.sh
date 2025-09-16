#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Modified 2024-present DiegroSan (github)

# Source predefined functions and variables
. /etc/profile

DATA="https://github.com/mmatyas/supermariowar-data/archive/da13a367e5a41c59d59f8c0a7fb8248a2f72750c.zip"
DATAFILE=$(basename "$DATA")
DATANAME=$(basename "$DATA" .zip)
DATAFOLDER="/storage/roms/ports/smw/data"
CONFIGFOLDER="/emuelec/configs/smw"

mkdir -p "${DATAFOLDER}"
mkdir -p "${CONFIGFOLDER}"
cd "${DATAFOLDER}"

gptokeyb &
if [ ! -f "${CONFIGFOLDER}/nofakekeyb" ]; then 
    touch "${CONFIGFOLDER}/nofakekeyb"
fi

if [ ! -e "${DATAFOLDER}/worlds/Big JM_Mixed River.txt" ]; then
    text_viewer -y -w -f 24 -t "Data does not exists!" -m "It seems this is the first time you are launching Super Mario War or the data folder does not exists\n\nData is about 30 MB total, and you need to be connected to the internet\n\nKeep in mind the first time you run the game a fake keyboard is set, you need to set up your controller/gamepad and restart the game.\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
            unzip "${DATAFILE}" > /dev/tty0
            mv "${DATAFOLDER}/supermariowar-data-${DATANAME}"/* "${DATAFOLDER}/" > /dev/tty0
            rm -rf "${DATAFOLDER}/supermariowar-data-${DATANAME}" > /dev/tty0 2>&1
            rm "${DATAFOLDER}/${DATAFILE}" > /dev/tty0 2>&1
            rm "imgui.ini" > /dev/tty0 2>&1
            ee_console disable
            cd "${DATAFOLDER}/.."
            smw --datadir "${DATAFOLDER}" > /emuelec/logs/emuelec.log 2>&1
        else
            exit 0
        fi
else
    smw --datadir "${DATAFOLDER}" > /emuelec/logs/emuelec.log 2>&1
fi

killall gptokeyb &
