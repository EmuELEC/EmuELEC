#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
# Script for setting up cheevos on duckstation emuelec. it extracts the data from emuelec.conf and it constructs the entries in settings.ini if [Cheevos] or Enabled = True or Enable = False are not presented

. /etc/profile

FLYCAST_CFG="/storage/.config/flycast/emu.cfg"

# Extract username and password from emuelec.conf
username=$(get_ee_setting "global.retroachievements.username")
password=$(get_ee_setting "global.retroachievements.password")
token=$(grep "cheevos_token" /storage/.config/retroarch/retroarch.cfg | cut -d'"' -f2)

# Test the token if empty exit 1.
if [ -z "${token}" ]; then
    echo "Token is empty you must log in retroachievement first in retroarch achievements"
    exit 1
fi

# Variables for checking if [Cheevos] or enabled true or false are present.
zcheevos=$(grep -Fx "[achievements]" ${FLYCAST_CFG})

if [ -z "${zcheevos}" ]; then
    # Añadir la sección [achievements] con los valores
    sed -i "\$a [achievements]\nEnabled = yes\nUserName = ${username}\nToken = ${token}" ${FLYCAST_CFG}
else
    # Verificar y actualizar UserName y Token si es necesario
    if ! grep -q "^UserName = " ${FLYCAST_CFG}; then
        sed -i "/^\[achievements\]/a UserName = ${username}" ${FLYCAST_CFG}
    else
        sed -i "/^\[achievements\]/,/^\[/{s/^UserName = .*/UserName = ${username}/;}" ${FLYCAST_CFG}
    fi

    if ! grep -q "^Token = " ${FLYCAST_CFG}; then
        sed -i "/^\[achievements\]/a Token = ${token}" ${FLYCAST_CFG}
    else
        sed -i "/^\[achievements\]/,/^\[/{s/^Token = .*/Token = ${token}/;}" ${FLYCAST_CFG}
    fi
fi