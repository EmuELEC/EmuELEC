#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

DUKEDIR="/storage/.config/eduke32"
DUKECFG="${DUKEDIR}/eduke32.cfg"

mkdir -p "${DUKEDIR}"
if [ ! -f "${DUKECFG}" ]; then
# We only do these changes if the cfg file does not already exists, if it exists we asume the user has created it outside this script
# Only for handheld devices, SBCs already handle this gratefully
               
    if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
        touch "${DUKECFG}"
    
        case "$(oga_ver)" in
            "OGA" | "OGABE")
                echo "ScreenDisplay = 0" > "${DUKECFG}"
                echo "ScreenHeight = 320" >> "${DUKECFG}"
                echo "ScreenMode = 0" >> "${DUKECFG}"
                echo "ScreenWidth = 480" >> "${DUKECFG}"
                echo "MaxRefreshFreq = 0" >> "${DUKECFG}"
            ;;
            "GF")
                echo "ScreenDisplay = 0" > "${DUKECFG}"
                echo "ScreenHeight = 480" >> "${DUKECFG}"
                echo "ScreenMode = 0" >> "${DUKECFG}"
                echo "ScreenWidth = 640" >> "${DUKECFG}"
                echo "MaxRefreshFreq = 0" >> "${DUKECFG}"
            ;;
            "OGS")
                echo "ScreenDisplay = 0" > "${DUKECFG}"
                echo "ScreenHeight = 480" >> "${DUKECFG}"
                echo "ScreenMode = 0" >> "${DUKECFG}"
                echo "ScreenWidth = 854" >> "${DUKECFG}"
                echo "MaxRefreshFreq = 0" >> "${DUKECFG}"
            ;;
        esac
    fi
fi

if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
    # Eduke does not run if there is less that x ammount of memory so we need to enable swap on devices with 1GB of RAM
    SWAP_FILE="/storage/.config/swap.conf"
    if [ ! -f "${SWAP_FILE}" ]; then
        cp /etc/swap.conf "${SWAP_FILE}"
    fi

    # We could potentially use /tmp/swap as the swap file by changing this: SWAPFILE="${HOME}/.cache/swapfile" in "${SWAP_FILE}" but not sure of the consequences
    # It needs at LEAST 300mb of swap, pretty greedy
    sed -i 's/SWAPFILESIZE=.*/SWAPFILESIZE="300"/' "${SWAP_FILE}"
    sed -i 's/SWAP_ENABLED=.*/SWAP_ENABLED="yes"/' "${SWAP_FILE}"
    /usr/lib/coreelec/mount-swap create
    /usr/lib/coreelec/mount-swap mount
fi 

cd /storage/roms/ports/eduke
eduke32 -j /storage/roms/ports/eduke > /emuelec/logs/emuelec.log 2>&1

if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || [ "${EE_DEVICE}" == "GameForce" ]; then
    /usr/lib/coreelec/mount-swap unmount
    rm -rf ${HOME}/.cache/swapfile
    sed -i 's/SWAP_ENABLED=.*/SWAP_ENABLED="no"/' "${SWAP_FILE}"
fi
