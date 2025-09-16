#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# This variable has to match the version on package.mk
VERSION="1.4"

ASSETS="https://github.com/supertuxkart/stk-assets-mobile/releases/download/${VERSION}/stk-assets.zip"
DATA="https://github.com/supertuxkart/stk-code/archive/refs/tags/${VERSION}.zip"
DATAFOLDER="/storage/roms/ports/supertuxkart"

mkdir -p "${DATAFOLDER}"
cd "${DATAFOLDER}"

if [ ! -e "${DATAFOLDER}/data/stk_config.xml" ]; then
    text_viewer -y -w -f 24 -t "Data does not exists!" -m "It seems this is the first time you are launching Super Tux Kart or the data folder does not exists\n\nData is about 250 MB total, and you need to be connected to the internet\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
            unzip "${VERSION}.zip" > /dev/tty0
            rm -rf "${DATAFOLDER}/data"
            mv "stk-code-${VERSION}/data" "${DATAFOLDER}" > /dev/tty0
            rm -rf "stk-code-${VERSION}"
            wget "${ASSETS}" -q --show-progress > /dev/tty0 2>&1
            unzip "stk-assets.zip" -d data > /dev/tty0
            rm "stk-assets.zip"
            rm "${VERSION}.zip"
            ee_console disable
            mkdir -p /storage/.config/supertuxkart/config-0.10
            [[ ! -f "${DATAFOLDER}/data/supertuxkart.git" ]] && touch "${DATAFOLDER}/data/supertuxkart.git"
            
cat > /storage/.config/supertuxkart/config-0.10/players.xml << EOF
<?xml version="1.0"?>
<players version="1" >
    <current player="EmuELEC"/>
    <player name="EmuELEC" guest="false" use-frequency="0"
            icon-filename="1.png"
            unique-id="1" saved-session="false"
            saved-user="0" saved-token=""
            last-online-name="" last-was-online="false"
            remember-password="false"
            default-kart-color="0">
    </player>
</players>            
EOF
            SUPERTUXKART_DATADIR="${DATAFOLDER}" supertuxkart
        else
            exit 0
        fi
else
    SUPERTUXKART_DATADIR="${DATAFOLDER}" supertuxkart
fi

