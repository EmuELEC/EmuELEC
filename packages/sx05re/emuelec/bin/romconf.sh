#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Make sure ES is not running to prevent file corruption.
if pgrep -x "emulationstation" > /dev/null
  then
    echo "ERROR: This script should not be run if emulationstation is running"
    exit 1
fi
 
 state="${1}"
 romconf="/storage/roms/emuelec.conf"
 conf="/emuelec/configs/emuelec.conf"
 [[ -z "${state}" ]] && state=$(get_ee_setting ee_romconf_enable)


if [[ "${state}" != "1" ]]  ; then 
    if [[ -L "${conf}" ]]; then
        cp --remove-destination $(readlink ${conf}) ${conf}
    elif [[ -f "${romconf}" ]] && [[ ! -f "${conf}" ]]; then
        cp -rf "${romconf}" "${conf}"
    fi
    set_ee_setting ee_romconf_enable "0"
elif [[ "${state}" == "1" ]]; then
    if [[ ! -f "${romconf}" ]]; then
        cp -f "${conf}" "${conf}.bak"
        mv -- "${conf}" "${romconf}"
    else
        mv -- "${conf}" "${conf}.bak"
    fi
        ln -s -- "${romconf}" "${conf}"
        set_ee_setting ee_romconf_enable "1"
fi

exit 0
