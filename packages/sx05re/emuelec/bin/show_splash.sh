#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)
# 2025-present Mod by DiegroSan

# 12/07/2019 use mpv for all splash 
# 19/01/2020 use ffplay for all splash 
# 06/02/2020 move splash to roms folder and add global splash support

. /etc/profile

ACTION_TYPE="${1}"
PLATFORM="${2}"
>/emuelec/logs/logx.txt
echo ${PLATFORM} >> /emuelec/logs/logx.txt

GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
BLANKSPLASH="/storage/.config/splash/blank.png"
DEFAULTSPLASH="/storage/.config/splash/splash-1080.png"
VIDEOSPLASH="/usr/config/splash/emuelec_intro_1080p.mp4"
RANDOMVIDEO="/storage/roms/splash/introvideos"
DURATION="5"

if [ -f "/storage/roms/splash/intro.mp4" ]; then
    VIDEOSPLASH="/storage/roms/splash/intro.mp4"
fi

if [ -f "/storage/.config/splash/loading-game.mp4" ]; then
    GAMELOADINGSPLASH="/storage/.config/splash/loading-game.mp4"
fi

# Convert the platform name to lowercase
PLATFORM=${PLATFORM,,}
PLAYER="ffplay"
echo ${PLATFORM} >> /emuelec/logs/logx.txt

case ${PLATFORM} in
 "arcade"|"fba"|"fbn"|"neogeo"|"mame"|cps*)
   PLATFORM="arcade"
  ;;
 "retropie"|"setup")
   # fbterm does not like the splash screen 
   exit 0
  ;;
esac

MODE=`get_resolution`

SPLASHDIR="/storage/roms/splash"
  
if [ "${ACTION_TYPE}" == "intro" ] || [ "${ACTION_TYPE}" == "exit" ]; then
    SPLASH=${DEFAULTSPLASH}
    if [[ "${MODE}" == *"x"* ]]; then
        SPLASH="/storage/.config/splash/splash-std.png"
    fi

    # Extended section for exit action: integrate additional settings from emuelec.conf
    if [ "${ACTION_TYPE}" == "exit" ]; then
        CUSTOM_EXIT_VIDEO_ENABLED=$(get_ee_setting ee_customexitsplashvideo.enabled)
        CUSTOM_EXIT_VIDEO=$(get_ee_setting ee_customexitsplashvideo)
        CUSTOM_EXIT_IMAGE_ENABLED=$(get_ee_setting ee_customexitsplashimage.enabled)
        CUSTOM_EXIT_IMAGE=$(get_ee_setting ee_customexitsplashimage)
        EXIT_VIDEO_ENABLED=$(get_ee_setting ee_exitvideo.enabled)
        EXIT_IMAGE_ENABLED=$(get_ee_setting ee_exitsplashimage.enabled)
        
        if [ "${CUSTOM_EXIT_VIDEO_ENABLED}" == "1" ] && [ -n "${CUSTOM_EXIT_VIDEO}" ] && [ -f "${CUSTOM_EXIT_VIDEO}" ]; then
            SPLASH="${CUSTOM_EXIT_VIDEO}"
        elif [ "${CUSTOM_EXIT_IMAGE_ENABLED}" == "1" ] && [ -n "${CUSTOM_EXIT_IMAGE}" ] && [ -f "${CUSTOM_EXIT_IMAGE}" ]; then
            SPLASH="${CUSTOM_EXIT_IMAGE}"
        elif [ "${EXIT_VIDEO_ENABLED}" == "1" ] && [ -f "/storage/roms/splash/exitvideo.mp4" ]; then
            SPLASH="/storage/roms/splash/exitvideo.mp4"
        elif [ "${EXIT_IMAGE_ENABLED}" == "1" ] && [ -f "/storage/roms/splash/exitsplash.png" ]; then
            SPLASH="/storage/roms/splash/exitsplash.png"
        fi
    fi

elif [ "${ACTION_TYPE}" == "blank" ]; then
    SPLASH=${BLANKSPLASH}
elif [ "${ACTION_TYPE}" == "gameloading" ]; then
    if [[ "${MODE}" == *"x"* ]]; then
        GAMELOADINGSPLASH="/storage/.config/splash/loading-game-std.png"

        if [ -f "/storage/.config/splash/loading-game-std.mp4" ]; then
            GAMELOADINGSPLASH="/storage/.config/splash/loading-game-std.mp4"
        fi

    fi

    # Extended gameloading settings from emuelec.conf:
    CUSTOM_SPLASH_IMAGE_ENABLED=$(get_ee_setting ee_customsplashimage.enabled)
    CUSTOM_SPLASH_IMAGE=$(get_ee_setting ee_customsplashimage)
    CUSTOM_SPLASH_VIDEO_ENABLED=$(get_ee_setting ee_customsplashvideo.enabled)
    CUSTOM_SPLASH_VIDEO=$(get_ee_setting ee_customsplashvideo)
    STANDARD_LOADING_VIDEO_ENABLED=$(get_ee_setting ee_standardloadingvideo.enabled)
    RANDOM_LOADING_VIDEO_ENABLED=$(get_ee_setting ee_randomloadingvideo.enabled)
    SYSTEM_LOADING_VIDEO_ENABLED=$(get_ee_setting ee_systemloadingvideo.enabled)
    RANDOM_SYSTEM_VIDEO_ENABLED=$(get_ee_setting ee_randomsystemvideo.enabled)
    RANDOM_IMAGE_ENABLED=$(get_ee_setting ee_randomimage.enabled)
    RANDOM_SYSTEM_IMAGE_ENABLED=$(get_ee_setting ee_randomsystemimage.enabled)
    SYSTEM_SPLASH_IMAGE_ENABLED=$(get_ee_setting ee_systemsplashimage.enabled)
    STANDARD_LOADING_IMAGE_ENABLED=$(get_ee_setting ee_standardloadingimage.enabled)

    if [ "${CUSTOM_SPLASH_IMAGE_ENABLED}" == "1" ] && [ -n "${CUSTOM_SPLASH_IMAGE}" ] && [ -f "${CUSTOM_SPLASH_IMAGE}" ]; then
        SPLASH="${CUSTOM_SPLASH_IMAGE}"
    elif [ "${CUSTOM_SPLASH_VIDEO_ENABLED}" == "1" ] && [ -n "${CUSTOM_SPLASH_VIDEO}" ] && [ -f "${CUSTOM_SPLASH_VIDEO}" ]; then
        SPLASH="${CUSTOM_SPLASH_VIDEO}"
    elif [ "${STANDARD_LOADING_VIDEO_ENABLED}" == "1" ] && [ -f "/storage/roms/splash/launching.mp4" ]; then
        SPLASH="/storage/roms/splash/launching.mp4"
    elif [ "${RANDOM_LOADING_VIDEO_ENABLED}" == "1" ]; then
        SPLASH=$(ls /storage/roms/splash/video/*.mp4 2>/dev/null | sort -R | head -n 1)
    elif [ "${SYSTEM_LOADING_VIDEO_ENABLED}" == "1" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ] && [ -f "${SPLASHDIR}/${PLATFORM}/launching.mp4" ]; then
        SPLASH="${SPLASHDIR}/${PLATFORM}/launching.mp4"
    elif [ "${RANDOM_SYSTEM_VIDEO_ENABLED}" == "1" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ]; then
        SPLASH=$(ls ${SPLASHDIR}/${PLATFORM}/*.mp4 2>/dev/null | sort -R | head -n 1)
    elif [ "${RANDOM_IMAGE_ENABLED}" == "1" ]; then
        SPLASH=$(ls /storage/roms/splash/random/*.{png,jpg,jpeg} 2>/dev/null | sort -R | head -n 1)
    elif [ "${RANDOM_SYSTEM_IMAGE_ENABLED}" == "1" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ]; then
        SPLASH=$(ls ${SPLASHDIR}/${PLATFORM}/*.{png,jpg,jpeg} 2>/dev/null | sort -R | head -n 1)
    elif [ "${SYSTEM_SPLASH_IMAGE_ENABLED}" == "1" ] && [ -f "${SPLASHDIR}/${PLATFORM}/launching.png" ]; then
        SPLASH="${SPLASHDIR}/${PLATFORM}/launching.png"
    elif [ "${STANDARD_LOADING_IMAGE_ENABLED}" == "1" ] && [ -f "/storage/roms/splash/launching.png" ]; then
        SPLASH="/storage/roms/splash/launching.png"
    fi

    # If no valid file was selected using custom settings, fallback to the default matching logic:
    if [ -z "${SPLASH}" ]; then
        ROMNAME=$(basename "${3%.*}")
        SPLMAP="/emuelec/configs/bezels/arcademap.cfg"
        SPLNAME=$(sed -n "/$(echo "${PLATFORM}_${ROMNAME} = ")/p" "${SPLMAP}")
        REALSPL="${SPLNAME#*\"}"
        REALSPL="${REALSPL%\"*}"
        [ ! -z "${ROMNAME}" ] && SPLASH1=$(find ${SPLASHDIR}/${PLATFORM} -iname "${ROMNAME}*.png" -maxdepth 1 | sort -V | head -n 1)
        [ ! -z "${ROMNAME}" ] && SPLASHVID1=$(find ${SPLASHDIR}/${PLATFORM} -iname "${ROMNAME}*.mp4" -maxdepth 1 | sort -V | head -n 1)
        [ ! -z "${REALSPL}" ] && SPLASH2=$(find ${SPLASHDIR}/${PLATFORM} -iname "${REALSPL}*.png" -maxdepth 1 | sort -V | head -n 1)
        [ ! -z "${REALSPL}" ] && SPLASHVID2=$(find ${SPLASHDIR}/${PLATFORM} -iname "${REALSPL}*.mp4" -maxdepth 1 | sort -V | head -n 1)

        SPLASH3="${SPLASHDIR}/${PLATFORM}/launching.png"
        SPLASHVID3="${SPLASHDIR}/${PLATFORM}/launching.mp4"

        SPLASH4="${SPLASHDIR}/${PLATFORM}.png"
        SPLASHVID4="${SPLASHDIR}/${PLATFORM}.mp4"

        SPLASH5="${SPLASHDIR}/launching.png"
        SPLASHVID5="${SPLASHDIR}/launching.mp4"
        
        if [ -f "${SPLASHVID1}" ]; then
            SPLASH="${SPLASHVID1}"
        elif [ -f "${SPLASH1}" ]; then
            SPLASH="${SPLASH1}"
        elif [ -f "${SPLASHVID2}" ]; then
            SPLASH="${SPLASHVID2}"
        elif [ -f "${SPLASH2}" ]; then
            SPLASH="${SPLASH2}"
        elif [ -f "${SPLASHVID3}" ]; then
            SPLASH="${SPLASHVID3}"
        elif [ -f "${SPLASH3}" ]; then
            SPLASH="${SPLASH3}"
        elif [ -f "${SPLASHVID4}" ]; then
            SPLASH="${SPLASHVID4}"
        elif [ -f "${SPLASH4}" ]; then
            SPLASH="${SPLASH4}"
        elif [ -f "${SPLASHVID5}" ]; then
            SPLASH="${SPLASHVID5}"
        elif [ -f "${SPLASH5}" ]; then
            SPLASH="${SPLASH5}"
        else
            SPLASH="${GAMELOADINGSPLASH}"
        fi
    fi
fi

# Odroid Go Advance and GameForce do not support splash screens yet
SS_DEVICE=0
if [[ "${EE_DEVICE}" == "OdroidGoAdvance" ]] || [[ "${EE_DEVICE}" == "GameForce" ]]; then
    SS_DEVICE=1
    clear > /dev/console
    echo "Loading ..." > /dev/console
    PLAYER="mpv"
fi

declare -a RES=( ${MODE} )
SIZE=" -x ${RES[0]} -y ${RES[1]}"
SCALE="${RES[0]}:${RES[1]}"
EXTENSION="${SPLASH##*.}"

[[ "${ACTION_TYPE}" != "intro" ]] && VIDEO=0 || VIDEO=$(get_ee_setting ee_bootvideo.enabled)

if [[ -f "/storage/.config/emuelec/configs/novideo" ]] && [[ ${VIDEO} != "1" ]]; then
    if [ "${ACTION_TYPE}" != "intro" ]; then
        if [ "${SS_DEVICE}" == 1 ]; then
            ${PLAYER} "${SPLASH}" > /dev/null 2>&1
        else
               if [[ "$EXTENSION" == "mp4" || "$EXTENSION" == "MP4" ]]; then
                    if [[ -f "tmp/Plibretro.p" ]]; then
                         ${PLAYER} -fs ${SIZE} -vf scale=${SCALE} "${SPLASH}" > /dev/null 2>&1
                     else
                         ${PLAYER} -fs -autoexit ${SIZE} -vf scale=${SCALE} "${SPLASH}" > /dev/null 2>&1
                    fi
                elif [ "${ACTION_TYPE}" == "exit" ]; then
                # Game over presentation, 3 seconds for images or video duration + 3 seconds.
                ${PLAYER} -fs ${SIZE} -vf scale=${SCALE}  "${SPLASH}" > /dev/null 2>&1 & sleep 3 && ACTION_TYPE="stopplayer"
                else
                   if [[ -f "tmp/Plibretro.p" ]]; then
                     ${PLAYER} -fs ${SIZE} -vf scale=${SCALE} "${SPLASH}" > /dev/null 2>&1
                   else
                     ${PLAYER} -fs ${SIZE} -vf scale=${SCALE} -autoexit "${SPLASH}" > /dev/null 2>&1 & sleep 3 
                   fi
                fi
            fi
        fi 
else
    # Display intro video
    RND=$(get_ee_setting "ee_randombootvideo.enabled" == "1")
    if [ "${RND}" ==  1 ]; then
        SPLASH=$(ls ${RANDOMVIDEO}/*.mp4 | sort -R | tail -1)
        [[ -z "${SPLASH}" ]] && SPLASH="${VIDEOSPLASH}"
    else
        SPLASH="${VIDEOSPLASH}"
    fi
    set_audio alsa
    # [ -e /storage/.config/asound.conf ] && mv /storage/.config/asound.conf /storage/.config/asound.confs
    if [ ${SS_DEVICE} -eq 1 ]; then
        ${PLAYER} "${SPLASH}" > /dev/null 2>&1
    else
        ${PLAYER} -fs -autoexit ${SIZE} -vf scale=${SCALE}  "${SPLASH}" > /dev/null 2>&1
    fi
    touch "/storage/.config/emuelec/configs/novideo"
    # [ -e /storage/.config/asound.confs ] && mv /storage/.config/asound.confs /storage/.config/asound.conf
fi

if [ "${ACTION_TYPE}" == "stopplayer" ] ; then
    killall "${PLAYER}"
    #blank_buffer
fi

# Wait for the duration specified by ee_splash.delay in emuelec.conf
SPLASHTIME=$(get_ee_setting ee_splash.delay)
[ ! -z "${SPLASHTIME}" ] && sleep ${SPLASHTIME}
