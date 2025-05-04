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

# we make sure the platform is all lowercase
PLATFORM=${PLATFORM,,}
PLAYER="ffplay"

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
# Choose random mp4 file
get_random_video() {
    local dir="$1"
    shopt -s nullglob
    local files=("${dir}"/*.mp4)
    if [[ ${#files[@]} -gt 0 ]]; then
        echo "${files[RANDOM % ${#files[@]}]}"
    else
        echo ""
    fi
}

if [ "${ACTION_TYPE}" == "intro" ]; then
    SPLASH=${DEFAULTSPLASH}
    if [[ "${MODE}" == *"x"* ]]; then
        SPLASH="/storage/.config/splash/splash-std.png"
    fi

elif [ "${ACTION_TYPE}" == "exit" ]; then
    EXITVIDEO="/storage/roms/splash/exitvideo.mp4"
    EXITSPLASH="/storage/roms/splash/exitsplash.png"
    CUSTOM_EXIT_VIDEO=$(get_ee_setting "ee_customexitsplashvideo")
    CUSTOM_EXIT_VIDEO_ENABLED=$(get_ee_setting "ee_customexitsplashvideo.enabled")
    CUSTOM_EXIT_IMAGE=$(get_ee_setting "ee_customexitsplashimage")
    CUSTOM_EXIT_IMAGE_ENABLED=$(get_ee_setting "ee_customexitsplashimage.enabled")

    if [[ "${CUSTOM_EXIT_VIDEO_ENABLED}" == "1" ]] && [[ -f "${CUSTOM_EXIT_VIDEO}" ]]; then
        SPLASH="${CUSTOM_EXIT_VIDEO}"
        VIDEO=1
    elif [[ "${CUSTOM_EXIT_IMAGE_ENABLED}" == "1" ]] && [[ -f "${CUSTOM_EXIT_IMAGE}" ]]; then
        SPLASH="${CUSTOM_EXIT_IMAGE}"
        VIDEO=0
    elif [[ $(get_ee_setting "ee_exitvideo.enabled") == "1" ]] && [[ -f "${EXITVIDEO}" ]]; then
        SPLASH="${EXITVIDEO}"
        VIDEO=1
    elif [[ $(get_ee_setting "ee_exitsplashimage.enabled") == "1" ]] && [[ -f "${EXITSPLASH}" ]]; then
        SPLASH="${EXITSPLASH}"
        VIDEO=0
    else
        SPLASH=${DEFAULTSPLASH}
        if [[ "${MODE}" == *"x"* ]]; then
            SPLASH="/storage/.config/splash/splash-std.png"
        fi
        VIDEO=0
    fi

elif [ "${ACTION_TYPE}" == "blank" ]; then
    SPLASH=${BLANKSPLASH}

elif [ "${ACTION_TYPE}" == "gameloading" ]; then
    # Default fallback for game loading splash image
    GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
    if [[ "${MODE}" == *"x"* ]]; then
        GAMELOADINGSPLASH="/storage/.config/splash/loading-game-std.png"
    fi

    # Custom splashscreen settings check
    CUSTOM_GAME_VIDEO=$(get_ee_setting "ee_customsplashvideo")
    CUSTOM_GAME_VIDEO_ENABLED=$(get_ee_setting "ee_customsplashvideo.enabled")
    CUSTOM_GAME_IMAGE=$(get_ee_setting "ee_customsplashimage")
    CUSTOM_GAME_IMAGE_ENABLED=$(get_ee_setting "ee_customsplashimage.enabled")

    # Check if custom video or image is enabled and exists
    if [[ "${CUSTOM_GAME_VIDEO_ENABLED}" == "1" ]] && [[ -f "${CUSTOM_GAME_VIDEO}" ]]; then
        SPLASH="${CUSTOM_GAME_VIDEO}"
        VIDEO=1
    elif [[ "${CUSTOM_GAME_IMAGE_ENABLED}" == "1" ]] && [[ -f "${CUSTOM_GAME_IMAGE}" ]]; then
        SPLASH="${CUSTOM_GAME_IMAGE}"
        VIDEO=0
    else
        # ROM-based splashscreen check
        ROMNAME=$(basename "${3%.*}")
        SPLMAP="/emuelec/configs/bezels/arcademap.cfg"
        SPLNAME=$(sed -n "/`echo ""${PLATFORM}"_"${ROMNAME}" = "`/p" "${SPLMAP}")
        REALSPL="${SPLNAME#*\"}"
        REALSPL="${REALSPL%\"*}"

        # Search for ROM-specific splashscreens (image and video)
        [ ! -z "${ROMNAME}" ] && SPLASH1=$(find ${SPLASHDIR}/${PLATFORM} -iname "${ROMNAME}*.png" -maxdepth 1 | sort -V | head -n 1)
        [ ! -z "${ROMNAME}" ] && SPLASHVID1=$(find ${SPLASHDIR}/${PLATFORM} -iname "${ROMNAME}*.mp4" -maxdepth 1 | sort -V | head -n 1)
        [ ! -z "${REALSPL}" ] && SPLASH2=$(find ${SPLASHDIR}/${PLATFORM} -iname "${REALSPL}*.png" -maxdepth 1 | sort -V | head -n 1)
        [ ! -z "${REALSPL}" ] && SPLASHVID2=$(find ${SPLASHDIR}/${PLATFORM} -iname "${REALSPL}*.mp4" -maxdepth 1 | sort -V | head -n 1)

        # Default platform-wide splashscreens (image and video)
        SPLASH3="${SPLASHDIR}/${PLATFORM}/launching.png"
        SPLASHVID3="${SPLASHDIR}/${PLATFORM}/launching.mp4"
        SPLASH4="${SPLASHDIR}/${PLATFORM}.png"
        SPLASHVID4="${SPLASHDIR}/${PLATFORM}.mp4"
        SPLASH5="${SPLASHDIR}/launching.png"
        SPLASHVID5="${SPLASHDIR}/launching.mp4"

        # Check for available splashscreens (video or image)
        if [ -f "${SPLASHVID1}" ]; then
            SPLASH="${SPLASHVID1}"
            VIDEO=1
        elif [ -f "${SPLASH1}" ]; then
            SPLASH="${SPLASH1}"
            VIDEO=0
        elif [ -f "${SPLASHVID2}" ]; then
            SPLASH="${SPLASHVID2}"
            VIDEO=1
        elif [ -f "${SPLASH2}" ]; then
            SPLASH="${SPLASH2}"
            VIDEO=0
        elif [ -f "${SPLASHVID3}" ]; then
            SPLASH="${SPLASHVID3}"
            VIDEO=1
        elif [ -f "${SPLASH3}" ]; then
            SPLASH="${SPLASH3}"
            VIDEO=0
        elif [ -f "${SPLASHVID4}" ]; then
            SPLASH="${SPLASHVID4}"
            VIDEO=1
        elif [ -f "${SPLASH4}" ]; then
            SPLASH="${SPLASH4}"
            VIDEO=0
        elif [ -f "${SPLASHVID5}" ]; then
            SPLASH="${SPLASHVID5}"
            VIDEO=1
        elif [ -f "${SPLASH5}" ]; then
            SPLASH="${SPLASH5}"
            VIDEO=0
        else
            # Fallback to configurable splash options
            GAMELOADINGVIDEO="/storage/roms/splash/${PLATFORM}/launching.mp4"
            GLOBALGAMELOADINGVIDEO="/storage/roms/splash/launching.mp4"
            GLOBALGAMELOADINGIMAGE="/storage/roms/splash/launching.png"
            RANDOMSYSTEMVIDEO=$(get_random_video "/storage/roms/splash/${PLATFORM}")
            RANDOMVIDEOFILE=$(get_random_video "/storage/roms/splash/video")

            # System loading video fallback
            if [[ $(get_ee_setting "ee_systemloadingvideo.enabled") == "1" ]] && [[ -f "${GAMELOADINGVIDEO}" ]]; then
                SPLASH="${GAMELOADINGVIDEO}"
                VIDEO=1
            elif [[ $(get_ee_setting "ee_randomsystemvideo.enabled") == "1" ]] && [[ -n "${RANDOMSYSTEMVIDEO}" ]]; then
                SPLASH="${RANDOMSYSTEMVIDEO}"
                VIDEO=1
            elif [[ $(get_ee_setting "ee_randomloadingvideo.enabled") == "1" ]] && [[ -n "${RANDOMVIDEOFILE}" ]]; then
                SPLASH="${RANDOMVIDEOFILE}"
                VIDEO=1
            elif [[ $(get_ee_setting "ee_standardloadingvideo.enabled") == "1" ]] && [[ -f "${GLOBALGAMELOADINGVIDEO}" ]]; then
                SPLASH="${GLOBALGAMELOADINGVIDEO}"
                VIDEO=1
            elif [[ $(get_ee_setting "ee_randomimage.enabled") == "1" ]]; then
                SPLASH=$(get_random_splash "${RANDOMSPLASHDIR}")
                VIDEO=0
            elif [[ $(get_ee_setting "ee_randomsystemimage.enabled") == "1" ]]; then
                SPLASH=$(get_random_splash "${PLATFORMSPLASHDIR}")
                VIDEO=0
            elif [[ $(get_ee_setting "ee_systemsplashimage.enabled") == "1" ]]; then
                SPLASH="${PLATFORMSPLASHDIR}/launching.png"
                VIDEO=0
            elif [[ $(get_ee_setting "ee_standardloadingimage.enabled") == "1" ]] && [[ -f "${GLOBALGAMELOADINGIMAGE}" ]]; then
                SPLASH="${GLOBALGAMELOADINGIMAGE}"
                VIDEO=0
            elif [[ -f "${GLOBALGAMELOADINGVIDEO}" ]]; then
                SPLASH="${GLOBALGAMELOADINGVIDEO}"
                VIDEO=1
            else
                SPLASH="$GAMELOADINGSPLASH"
                VIDEO=0
            fi
        fi
    fi
fi




# Odroid Go Advance still does not support splash screens
SS_DEVICE=0
if [[ "${EE_DEVICE}" == "OdroidGoAdvance" ]] || [[ "${EE_DEVICE}" == "GameForce" ]]; then
  SS_DEVICE=1
  clear > /dev/console
  echo "Loading ..." > /dev/console
  PLAYER="mpv"
fi

declare -a RES=( ${MODE} )
SIZE=" -x ${RES[0]} -y ${RES[1]}"

# Fix: Set VIDEO only if not already set (especially for gameloading)
if [[ "${ACTION_TYPE}" == "intro" ]]; then
    VIDEO=$(get_ee_setting ee_bootvideo.enabled)
elif [[ -z "$VIDEO" ]]; then
    VIDEO=0
fi


if [[ ${VIDEO} != "1" ]] && [[ -f "/storage/.config/emuelec/configs/novideo" ]]; then
    if [ "${SS_DEVICE}" == 1 ]; then
        ${PLAYER} "${SPLASH}" > /dev/null 2>&1
    else
        ${PLAYER} -fs -autoexit ${SIZE} "${SPLASH}" > /dev/null 2>&1
    fi
else
# Show intro video
    if [[ "${ACTION_TYPE}" == "intro" ]]; then
        RND=$(get_ee_setting "ee_randombootvideo.enabled" == "1")
        if [ "${RND}" == 1 ]; then
            SPLASH=$(ls ${RANDOMVIDEO}/*.mp4 | sort -R | tail -1)
            [[ -z "${SPLASH}" ]] && SPLASH="${VIDEOSPLASH}"
        else
            SPLASH="${VIDEOSPLASH}"
        fi
    fi

    set_audio alsa
	#[ -e /storage/.config/asound.conf ] && mv /storage/.config/asound.conf /storage/.config/asound.confs
    if [ ${SS_DEVICE} -eq 1 ]; then
        ${PLAYER} "${SPLASH}" > /dev/null 2>&1
    else
        ${PLAYER} -fs -autoexit ${SIZE} "${SPLASH}" > /dev/null 2>&1
    fi


    if [[ "${ACTION_TYPE}" == "intro" ]]; then
        touch "/storage/.config/emuelec/configs/novideo"
	#[ -e /storage/.config/asound.confs ] && mv /storage/.config/asound.confs /storage/.config/asound.conf
    fi
fi

fi

# Wait for the time specified in ee_splash_delay setting in emuelec.conf
SPLASHTIME=$(get_ee_setting ee_splash.delay)
[ ! -z "${SPLASHTIME}" ] && sleep ${SPLASHTIME}