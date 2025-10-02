#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)
# 2025-present Mod by DiegroSan
# 2025-present Mod by WorstcaseSecenario (https://github.com/worstcase-scenario)
# 2025-present Mod by Langerz82 (https://github.com/Langerz82)

# 12/07/2019 use mpv for all splash 
# 19/01/2020 use ffplay for all splash 
# 06/02/2020 move splash to roms folder and add global splash support
# 22/09/2025 various updates.

. /etc/profile

ACTION_TYPE="${1}"
PLATFORM="${2}"

GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
BLANKSPLASH="/storage/.config/splash/blank.png"
DEFAULTSPLASH="/storage/.config/splash/splash-1080.png"
VIDEOSPLASH="/usr/config/splash/emuelec_intro_1080p.mp4"
RANDOMVIDEO="/storage/roms/splash/introvideos"

[ -f "/storage/roms/splash/intro.mp4" ] && VIDEOSPLASH="/storage/roms/splash/intro.mp4"

PLATFORM=${PLATFORM,,}
PLAYER_VID="ffplay"
PLAYER_IMG="mpv"

have_mpv=0

case ${PLATFORM} in
  arcade|fba|fbn|neogeo|mame|cps*) PLATFORM="arcade" ;;
  retropie|setup) exit 0 ;;
esac

MODE="$(get_resolution)"
SPLASHDIR="/storage/roms/splash"

if [ "${ACTION_TYPE}" = "intro" ] || [ "${ACTION_TYPE}" = "exit" ]; then
  SPLASH="${DEFAULTSPLASH}"
  [[ "${MODE}" == *"x"* ]] && SPLASH="/storage/.config/splash/splash-std.png"

  if [ "${ACTION_TYPE}" = "exit" ]; then
		EE_SPLASH_EXIT="$(get_ee_setting ee_splashexit)"
		[[ -z "${EE_SPLASH_EXIT}" ]] && EE_SPLASH_EXIT=2

		CUSTOM_EXIT_IMAGE="$(get_ee_setting ee_customexitsplashimage)"		
    CUSTOM_EXIT_VIDEO="$(get_ee_setting ee_customexitsplashvideo)"

		if [ "${EE_SPLASH_EXIT}" = "0" ] && [ -n "${CUSTOM_EXIT_IMAGE}" ] && [ -f "${CUSTOM_EXIT_IMAGE}" ]; then
			SPLASH="${CUSTOM_EXIT_IMAGE}"
    elif [ "${EE_SPLASH_EXIT}" = "1" ] && [ -n "${CUSTOM_EXIT_VIDEO}" ] && [ -f "${CUSTOM_EXIT_VIDEO}" ]; then
      SPLASH="${CUSTOM_EXIT_VIDEO}"
		elif [ "${EE_SPLASH_EXIT}" = "2" ] && [ -f "/storage/roms/splash/exitsplash.png" ]; then
      SPLASH="/storage/roms/splash/exitsplash.png"
    elif [ "${EE_SPLASH_EXIT}" = "3" ] && [ -f "/storage/roms/splash/exitvideo.mp4" ]; then
      SPLASH="/storage/roms/splash/exitvideo.mp4"
    fi
  fi

elif [ "${ACTION_TYPE}" = "blank" ]; then
  SPLASH="${BLANKSPLASH}"

elif [ "${ACTION_TYPE}" = "gameloading" ]; then
  [[ "${MODE}" == *"x"* ]] && GAMELOADINGSPLASH="/storage/.config/splash/loading-game-std.png"

	EE_SPLASH_LOADING="$(get_ee_setting ee_splashloading)"
	[[ -z "${EE_SPLASH_LOADING}" ]] && EE_SPLASH_LOADING=6
	
	CUSTOM_SPLASH_IMAGE="$(get_ee_setting ee_customsplashimage)"
	CUSTOM_SPLASH_VIDEO="$(get_ee_setting ee_customsplashvideo)"

  if [ "${EE_SPLASH_LOADING}" = "0" ] && [ -n "${CUSTOM_SPLASH_IMAGE}" ] && [ -f "${CUSTOM_SPLASH_IMAGE}" ]; then
    SPLASH="${CUSTOM_SPLASH_IMAGE}"
  elif [ "${EE_SPLASH_LOADING}" = "1" ] && [ -n "${CUSTOM_SPLASH_VIDEO}" ] && [ -f "${CUSTOM_SPLASH_VIDEO}" ]; then
    SPLASH="${CUSTOM_SPLASH_VIDEO}"
  elif [ "${EE_SPLASH_LOADING}" = "2" ] && [ -f "/storage/roms/splash/launching.mp4" ]; then
    SPLASH="/storage/roms/splash/launching.mp4"
	elif [ "${EE_SPLASH_LOADING}" = "3" ] && [ -f "${SPLASHDIR}/${PLATFORM}/launching.mp4" ]; then
    SPLASH="${SPLASHDIR}/${PLATFORM}/launching.mp4"
  elif [ "${EE_SPLASH_LOADING}" = "4" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ]; then
    SPLASH="$(ls ${SPLASHDIR}/${PLATFORM}/*.mp4 2>/dev/null | sort -R | head -n 1)"
  elif [ "${EE_SPLASH_LOADING}" = "5" ]; then
    SPLASH="$(ls /storage/roms/splash/video/*.mp4 2>/dev/null | sort -R | head -n 1)"
	elif [ "${EE_SPLASH_LOADING}" = "6" ] && [ -f "/storage/roms/splash/launching.png" ]; then
    SPLASH="/storage/roms/splash/launching.png"
	elif [ "${EE_SPLASH_LOADING}" = "7" ] && [ -f "${SPLASHDIR}/${PLATFORM}/launching.png" ]; then
    SPLASH="${SPLASHDIR}/${PLATFORM}/launching.png"
	elif [ "${EE_SPLASH_LOADING}" = "8" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ]; then
    SPLASH="$(ls ${SPLASHDIR}/${PLATFORM}/*.{png,jpg,jpeg} 2>/dev/null | sort -R | head -n 1)"
	elif [ "${EE_SPLASH_LOADING}" = "9" ]; then
    SPLASH="$(ls /storage/roms/splash/random/*.{png,jpg,jpeg} 2>/dev/null | sort -R | head -n 1)"
  fi
  [ -z "${SPLASH}" ] && SPLASH="${GAMELOADINGSPLASH}"
fi

# OGA/GameForce -> mpv
SS_DEVICE=0
if [[ "${EE_DEVICE}" == "OdroidGoAdvance" ]] || [[ "${EE_DEVICE}" == "GameForce" ]]; then
  SS_DEVICE=1
  clear > /dev/console
  echo "Loading ..." > /dev/console
  PLAYER_VID="mpv"
  PLAYER_IMG="mpv"
  have_mpv=1
fi

declare -a RES=( ${MODE} )
SCALE="${RES[0]}:${RES[1]}"
FILTER_FILL="scale=${SCALE}:force_original_aspect_ratio=increase,crop=${RES[0]}:${RES[1]},setsar=1"
MPV_VF="${FILTER_FILL}"

[[ "${ACTION_TYPE}" != "intro" ]] && VIDEO=0 || VIDEO="$(get_ee_setting ee_bootvideo.enabled)"

is_video() { case "${1,,}" in *.mp4|*.mkv|*.webm|*.avi|*.mov|*.mpg|*.mpeg) return 0;; *) return 1;; esac; }
is_image() { case "${1,,}" in *.png|*.jpg|*.jpeg|*.bmp|*.gif) return 0;; *) return 1;; esac; }

if [[ -f "/storage/.config/emuelec/configs/novideo" ]] && [[ ${VIDEO} != "1" ]]; then
  if [ "${ACTION_TYPE}" != "intro" ]; then
    LOADING_DURATION="$(get_ee_setting ee_splash_loading_duration)"
    DURATION="${LOADING_DURATION}"

    if [ "${ACTION_TYPE}" = "exit" ]; then
			EXIT_DURATION="$(get_ee_setting ee_splash_exit_duration)"
			DURATION="${EXIT_DURATION}"
    fi

		if [ -z "${DURATION}" ] || [ ! -n ${DURATION} ]; then
			DURATION=2
		fi

    if is_image "${SPLASH}"; then
      if [ "${have_mpv}" -eq 1 ]; then
        ${PLAYER_IMG} --fullscreen --no-keepaspect --vf="${MPV_VF}" --image-display-duration=${DURATION} "${SPLASH}" >/dev/null 2>&1
      else
        ffplay -fs -loglevel error -nostats -vf "${FILTER_FILL}" -i "${SPLASH}" -t ${DURATION} >/dev/null 2>&1 & PID=$!
				sleep 1
				kill ${PID}
				sleep ${DURATION}
      fi
    elif is_video "${SPLASH}"; then
      if [ -n "${DURATION}" ] && [ "${DURATION}" -gt 0 ]; then
        if [ "${PLAYER_VID}" = "ffplay" ]; then
          ${PLAYER_VID} -fs -autoexit -loglevel error -nostats -vf "${FILTER_FILL}" -t ${DURATION} -i "${SPLASH}" >/dev/null 2>&1
        else
          ${PLAYER_VID} --fullscreen --no-keepaspect --vf="${MPV_VF}" --length=${DURATION} "${SPLASH}" -t 1 >/dev/null 2>&1
        fi
      else
        if [ "${PLAYER_VID}" = "ffplay" ]; then
          ${PLAYER_VID} -fs -autoexit -loglevel error -nostats -vf "${FILTER_FILL}" -i "${SPLASH}" >/dev/null 2>&1
        else
          ${PLAYER_VID} --fullscreen --no-keepaspect --vf="${MPV_VF}" "${SPLASH}" >/dev/null 2>&1
        fi
      fi
    fi
  fi
else
  RND="$(get_ee_setting ee_randombootvideo.enabled)"
  if [ "${RND}" = "1" ]; then
    SPLASH="$(ls ${RANDOMVIDEO}/*.mp4 2>/dev/null | sort -R | tail -1)"
    [[ -z "${SPLASH}" ]] && SPLASH="${VIDEOSPLASH}"
  else
    SPLASH="${VIDEOSPLASH}"
  fi

  set_audio alsa

  if [ ${SS_DEVICE} -eq 1 ]; then
    ${PLAYER_VID} --fullscreen --no-keepaspect --vf="${MPV_VF}" "${SPLASH}" >/dev/null 2>&1
  else
    ${PLAYER_VID} -fs -autoexit -vf "${FILTER_FILL}" -i "${SPLASH}" >/dev/null 2>&1
  fi

  touch "/storage/.config/emuelec/configs/novideo"
fi

SPLASHTIME="$(get_ee_setting ee_splash.delay)"
[ -n "${SPLASHTIME}" ] && sleep "${SPLASHTIME}"