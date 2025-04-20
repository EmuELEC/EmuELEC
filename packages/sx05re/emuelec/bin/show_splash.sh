#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)

# 12/07/2019 use mpv for all splash 
# 19/01/2020 use ffplay for all splash 
# 06/02/2020 move splash to roms folder and add global splash support

. /etc/profile

ACTION_TYPE="${1}"
PLATFORM="${2}"

SPLASHDIR="/storage/roms/splash"
RANDOMSPLASHDIR="${SPLASHDIR}/random"
PLATFORMSPLASHDIR="${SPLASHDIR}/${PLATFORM}"
DEFAULTSPLASH="/storage/.config/splash/splash-1080.png"
BLANKSPLASH="/storage/.config/splash/blank.png"
VIDEOSPLASH="/usr/config/splash/emuelec_intro_1080p.mp4"
RANDOMVIDEO="/storage/roms/splash/introvideos"
DURATION="5"

if [ -f "/storage/roms/splash/intro.mp4" ]; then
    VIDEOSPLASH="/storage/roms/splash/intro.mp4"
fi

PLATFORM=${PLATFORM,,}
PLAYER="ffplay"

MODE=`get_resolution`

# Choose random PNG image
get_random_splash() {
    local dir="$1"
    shopt -s nullglob
    local files=("${dir}"/*.png)
    if [[ ${#files[@]} -gt 0 ]]; then
        echo "${files[RANDOM % ${#files[@]}]}"
    else
        echo ""
    fi
}

if [ "${ACTION_TYPE}" == "intro" ] || [ "${ACTION_TYPE}" == "exit" ]; then
    SPLASH=${DEFAULTSPLASH}
    if [[ "${MODE}" == *"x"* ]]; then
        SPLASH="/storage/.config/splash/splash-std.png"
    fi
elif [ "${ACTION_TYPE}" == "blank" ]; then
    SPLASH=${BLANKSPLASH}
elif [ "${ACTION_TYPE}" == "gameloading" ]; then
    GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
    
    if [[ $(get_ee_setting "ee_randomimage.enabled") == "1" ]]; then
        SPLASH=$(get_random_splash "${RANDOMSPLASHDIR}")
    elif [[ $(get_ee_setting "ee_randomsystemimage.enabled") == "1" ]]; then
        SPLASH=$(get_random_splash "${PLATFORMSPLASHDIR}")
    elif [[ $(get_ee_setting "ee_systemsplashimage.enabled") == "1" ]]; then
        SPLASH="${PLATFORMSPLASHDIR}/launching.png"
    fi
    
    if [[ -z "$SPLASH" ]]; then
        SPLASH="$GAMELOADINGSPLASH"
    fi
fi

SS_DEVICE=0
if [[ "${EE_DEVICE}" == "OdroidGoAdvance" ]] || [[ "${EE_DEVICE}" == "GameForce" ]]; then
  SS_DEVICE=1
  clear > /dev/console
  echo "Loading ..." > /dev/console
  PLAYER="mpv"
fi

declare -a RES=( ${MODE} )
SIZE=" -x ${RES[0]} -y ${RES[1]}"

[[ "${ACTION_TYPE}" != "intro" ]] && VIDEO=0 || VIDEO=$(get_ee_setting ee_bootvideo.enabled)

if [[ -f "/storage/.config/emuelec/configs/novideo" ]] && [[ ${VIDEO} != "1" ]]; then
    if [ "${SS_DEVICE}" == 1 ]; then
        ${PLAYER} "${SPLASH}" > /dev/null 2>&1
    else
        ${PLAYER} -fs -autoexit ${SIZE} "${SPLASH}" > /dev/null 2>&1
    fi
else
    RND=$(get_ee_setting "ee_randombootvideo.enabled" == "1")
    if [ "${RND}" == 1 ]; then
        SPLASH=$(ls ${RANDOMVIDEO}/*.mp4 |sort -R |tail -1)
        [[ -z "${SPLASH}" ]] && SPLASH="${VIDEOSPLASH}"
    else
        SPLASH="${VIDEOSPLASH}"
    fi
    set_audio alsa
    if [ ${SS_DEVICE} -eq 1 ]; then
        ${PLAYER} "${SPLASH}" > /dev/null 2>&1
    else
        ${PLAYER} -fs -autoexit ${SIZE} "${SPLASH}" > /dev/null 2>&1
    fi
    touch "/storage/.config/emuelec/configs/novideo"
fi

SPLASHTIME=$(get_ee_setting ee_splash.delay)
[ ! -z "${SPLASHTIME}" ] && sleep ${SPLASHTIME}
