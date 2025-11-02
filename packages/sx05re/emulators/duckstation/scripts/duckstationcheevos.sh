#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
#Script for setting up cheevos on duckstation emuelec. it extracts the data from emuelec.conf and it constructs the entries in seetings.ini if [Cheevos] or Enabled = True or Enable = False are not presented

. /etc/profile

#Extract username and password from emuelec.conf
username=$(get_ee_setting "global.retroachievements.username")
password=$(get_ee_setting "global.retroachievements.password")
token=$(grep "cheevos_token" /storage/.config/retroarch/retroarch.cfg | cut -d'"' -f2)

DUCK_INI="/storage/.config/emuelec/configs/duckstation/settings.ini"

#Variables for checking if [Cheevos] or enabled true or false are presente.
zcheevos=$(grep -Fx "[Cheevos]" ${DUCK_INI})
datets=$(date +%s%N | cut -b1-13)

# Test the token if empty exit 1. // I don't think we should exit, it should continue but not enable cheevos
if [[ -z "${token}" || "${token}" == *'"Success":false'* ]]
then
      token=""
      zcheevos=""
fi

if ([ -z "${zcheevos}" ])
then
    # Add the [Cheevos] section and the corresponding lines if it does not exist
    sed -i "$ a [Cheevos]\nEnabled = true\nUsername = ${username}\nToken = ${token}\nLoginTimestamp = ${datets}" ${DUCK_INI}
else
    # Replace existing values if the [Cheevos] section is already present, without modifying Enabled
    if ! grep -q "^Username = " ${DUCK_INI}; then
        sed -i "/^\[Cheevos\]/a Username = ${username}" ${DUCK_INI}
    else
        sed -i "/^\[Cheevos\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" ${DUCK_INI}
    fi

    if ! grep -q "^Token = " ${DUCK_INI}; then
        sed -i "/^\[Cheevos\]/a Token = ${token}" ${DUCK_INI}
    else
        sed -i "/^\[Cheevos\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${DUCK_INI}
    fi

    sed -i "/^\[Cheevos\]/,/^\[/{s/^LoginTimestamp = .*/LoginTimestamp = ${datets}/;}" ${DUCK_INI}
fi
