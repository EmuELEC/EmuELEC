#! /bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Hector Calvarro (https://github.com/kelvfimer)
#Script for setting up cheevos on duckstation emuelec. it extracts the data from emuelec.conf and it constructs the entries in seetings.ini if [Cheevos] or Enabled = True or Enable = False are not presented

# Source predefined functions and variables
. /etc/profile

PPSSPP_ACHIEVEMENTS="/storage/.config/ppsspp/PSP/SYSTEM/ppsspp_retroachievements.dat"
PPSSPP_INI="/storage/.config/ppsspp/PSP/SYSTEM/ppsspp.ini"

#Extract username and password from emuelec.conf
username=$(get_ee_setting "global.retroachievements.username")
password=$(get_ee_setting "global.retroachievements.password")
token=$(grep "cheevos_token" /storage/.config/retroarch/retroarch.cfg | cut -d'"' -f2)

#Test the token if empty exit 1.
if [ -z "${token}" ]
then
      echo "Token is empty you must log in retroachievement first in retroarch achievements"
      exit 1
fi
echo "${token}" > ${PPSSPP_ACHIEVEMENTS}

#Variables for checking if [Cheevos] or enabled true or false are presente.
zcheevos=$(grep -Fx "[Achievements]" ${PPSSPP_INI})
datets=$(date +%s%N | cut -b1-13)

if ([ -z "${zcheevos}" ])
then
    echo -e "[Achievements]\nAchievementsEnable = True\nAchievementsUserName = ${username}\n" >> ${PPSSPP_INI}
else
    # Verificar y actualizar AchievementsUserName si es necesario
    if ! grep -q "^AchievementsUserName = " ${PPSSPP_INI}; then
        sed -i "/^\[Achievements\]/a AchievementsUserName = ${username}" ${PPSSPP_INI}
    else
        sed -i "/^\[Achievements\]/,/^\[/{s/^AchievementsUserName = .*/AchievementsUserName = ${username}/;}" ${PPSSPP_INI}
    fi
fi