#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

DATAFILE="C-Dogs.SDL-1.5.0-Linux.tar.gz"
DATA="https://github.com/cxong/cdogs-sdl/releases/download/1.5.0/${DATAFILE}"
CONFIGFOLDER="/storage/roms/ports/cdogs-sdl"
PORTNAME="Cdogs-sdl"
FLAGS=""

mkdir -p "${CONFIGFOLDER}"
cd "${CONFIGFOLDER}"

if [ ! -e "${CONFIGFOLDER}/data/ammo.json" ]; then
    text_viewer -y -w -f 24 -t "Data does not exists!" -m "It seems this is the first time you are launching ${PORTNAME} or the data folder does not exists\n\nData is about 35 MB total, and you need to be connected to the internet\n\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            clear > /dev/tty0
            cat /etc/motd > /dev/tty0
            echo "Downloading ${PORTNAME} data, please wait..." > /dev/tty0
            wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
            echo "Installing ${PORTNAME} data, please wait..." > /dev/tty0
            tar -xvf "${DATAFILE}" -C "${CONFIGFOLDER}" > /dev/tty0
            mv C-Dogs.SDL-1.5.0-Linux/* "${CONFIGFOLDER}"
            rm -rf C-Dogs.SDL-1.5.0-Linux bin share > /dev/tty0 2>&1
            rm "${DATAFILE}" > /dev/tty0 2>&1
            echo "Starting ${PORTNAME} for the first time, please wait..." > /dev/tty0
            ee_console disable
            cd "${CONFIGFOLDER}"
            cdogs-sdl ${FLAGS} > /emuelec/logs/emuelec.log 2>&1
        else
            exit 0
        fi
else
    cdogs-sdl ${FLAGS} > /emuelec/logs/emuelec.log 2>&1
fi

killall gptokeyb &
