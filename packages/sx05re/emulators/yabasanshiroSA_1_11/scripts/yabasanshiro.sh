#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

mkdir -p "/storage/roms/saturn/yabasanshiro/"
mkdir -p "/storage/roms/bios/yabasanshiro/"

ROMNAME=$(basename "${1}")
BIOS=""

# Gamepad Autoconfiguration
GAMEPAD=$(sdljoytest -skip_loop | grep "0 name" | sed "s|Joystick 0 name ||")
GAMEPADCONFIG=$(xmlstarlet sel -t -c "//inputList/inputConfig[@deviceName=${GAMEPAD}]" -n /storage/.emulationstation/es_input.cfg)

if [ ! -z "${GAMEPADCONFIG}" ]; then
    echo -e "<?xml version=\"1.0\"?>\n<inputList>" > "/storage/roms/saturn/yabasanshiro/input.cfg"
    echo "${GAMEPADCONFIG}" >> "/storage/roms/saturn/yabasanshiro/input.cfg"
    echo "</inputList>" >> "/storage/roms/saturn/yabasanshiro/input.cfg"
fi

# if the auto config was not succesful copy the default just in case.
if [ ! -e "/storage/roms/saturn/yabasanshiro/input.cfg" ]; then
    cp -rf "/emuelec/configs/yabasanshiro/input.cfg" "/storage/roms/saturn/yabasanshiro/input.cfg"
fi

HLEBIOS=$(get_ee_setting hlebios saturn "${ROMNAME}")

if [ "${HLEBIOS}" != 1 ]; then 
    if [ -e "/storage/roms/bios/saturn_bios.bin" ]; then
        BIOS="-b /storage/roms/bios/saturn_bios.bin"
    else
        text_viewer -w -t "Notice! Yabasanshiro BIOS Missing!" -f 24 -m "/storage/roms/bios/saturn_bios.bin was not found!\n\nYabasanshiro will continue to load with HLE BIOS\n\nTo avoid this message please copy saturn_bios.bin with checksum af5828fdff51384f99b3c4926be27762 to /storage/roms/bios/\n\nOr select \"USE HLE BIOS\" on the emulator options"
        BIOS=""
    fi
fi

# It should be disabled by default unless the user enables it.
AUTOGP=$(get_ee_setting yabasanshiro_auto_gamepad)
if [[ "${AUTOGP}" == "1" ]]; then
  cp -f /storage/.emulationstation/es_input.cfg /storage/roms/saturn/yabasanshiro/input.cfg
  set_yabasanshiro_joy.sh
fi

# We use { } to avoid SIGUSR signal showing text and messing up with the error handling
{ yabasanshiro -r 2 -i "${1}" ${BIOS}; } > /emuelec/logs/emuelec.log 2>&1
