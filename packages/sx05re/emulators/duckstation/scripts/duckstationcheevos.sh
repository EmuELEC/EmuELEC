#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
#Script for setting up cheevos on duckstation emuelec. it extracts the data from emuelec.conf and it constructs the entries in seetings.ini if [Cheevos] or Enabled = True or Enable = False are not presented

. /etc/profile

# Extract username, password, and token
username=$(get_ee_setting "global.retroachievements.username")
password=$(get_ee_setting "global.retroachievements.password")
token=$(grep "cheevos_token" /storage/.config/retroarch/retroarch.cfg | cut -d'"' -f2)

# Path to DuckStation settings.ini
DUCK_INI="/storage/.config/emuelec/configs/duckstation/settings.ini"

# Get current date in milliseconds for LoginTimestamp
datets=$(date +%s%N | cut -b1-13)

# Check if the [Cheevos] section exists in the settings file
zcheevos=$(grep -Fx "[Cheevos]" ${DUCK_INI})

# If the token is empty or invalid, do not proceed with enabling Cheevos
if [[ -z "${token}" || "${token}" == *'"Success":false'* ]]; then
    token=""
    zcheevos=""  # Remove the Cheevos section if token is invalid
fi

# Check if the [Cheevos] section is present, and add it if not
if [[ -z "${zcheevos}" ]]; then
    # Add [Cheevos] section if not present
    {
        echo -e "[Cheevos]"
        echo "Enabled = true"
        echo "Username = ${username}"
        echo "Token = ${token}"
        echo "LoginTimestamp = ${datets}"
    } >> "${DUCK_INI}"
else
    # If [Cheevos] section is present, update specific fields as needed

    # Update the Username field
    if grep -q "^Username = " "${DUCK_INI}"; then
        sed -i "/^\[Cheevos\]/,/^\[/{s/^Username = .*/Username = ${username}/;}" "${DUCK_INI}"
    else
        sed -i "/^\[Cheevos\]/a Username = ${username}" "${DUCK_INI}"
    fi

    # Update the Token field
    if grep -q "^Token = " "${DUCK_INI}"; then
        sed -i "/^\[Cheevos\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" "${DUCK_INI}"
    else
        sed -i "/^\[Cheevos\]/a Token = ${token}" "${DUCK_INI}"
    fi

    # Update the LoginTimestamp field
    sed -i "/^\[Cheevos\]/,/^\[/{s/^LoginTimestamp = .*/LoginTimestamp = ${datets}/;}" "${DUCK_INI}"
fi
