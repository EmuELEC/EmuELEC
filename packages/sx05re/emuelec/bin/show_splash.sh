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

GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
BLANKSPLASH="/storage/.config/splash/blank.png"
DEFAULTSPLASH="/storage/.config/splash/splash-1080.png"
VIDEOSPLASH="/usr/config/splash/emuelec_intro_1080p.mp4"
RANDOMVIDEO="/storage/roms/splash/introvideos"

[ -f "/storage/roms/splash/intro.mp4" ] && VIDEOSPLASH="/storage/roms/splash/intro.mp4"

PLATFORM=${PLATFORM,,}
PLAYER_VID="ffplay"
PLAYER_IMG="mpv"

have_mpv=0; command -v mpv >/dev/null 2>&1 && have_mpv=1

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
    CUSTOM_EXIT_VIDEO_ENABLED="$(get_ee_setting ee_customexitsplashvideo.enabled)"
    CUSTOM_EXIT_VIDEO="$(get_ee_setting ee_customexitsplashvideo)"
    CUSTOM_EXIT_IMAGE_ENABLED="$(get_ee_setting ee_customexitsplashimage.enabled)"
    CUSTOM_EXIT_IMAGE="$(get_ee_setting ee_customexitsplashimage)"
    EXIT_VIDEO_ENABLED="$(get_ee_setting ee_exitvideo.enabled)"
    EXIT_IMAGE_ENABLED="$(get_ee_setting ee_exitsplashimage.enabled)"

    if [ "${CUSTOM_EXIT_VIDEO_ENABLED}" = "1" ] && [ -n "${CUSTOM_EXIT_VIDEO}" ] && [ -f "${CUSTOM_EXIT_VIDEO}" ]; then
      SPLASH="${CUSTOM_EXIT_VIDEO}"
    elif [ "${CUSTOM_EXIT_IMAGE_ENABLED}" = "1" ] && [ -n "${CUSTOM_EXIT_IMAGE}" ] && [ -f "${CUSTOM_EXIT_IMAGE}" ]; then
      SPLASH="${CUSTOM_EXIT_IMAGE}"
    elif [ "${EXIT_VIDEO_ENABLED}" = "1" ] && [ -f "/storage/roms/splash/exitvideo.mp4" ]; then
      SPLASH="/storage/roms/splash/exitvideo.mp4"
    elif [ "${EXIT_IMAGE_ENABLED}" = "1" ] && [ -f "/storage/roms/splash/exitsplash.png" ]; then
      SPLASH="/storage/roms/splash/exitsplash.png"
    fi
  fi

elif [ "${ACTION_TYPE}" = "blank" ]; then
  SPLASH="${BLANKSPLASH}"

elif [ "${ACTION_TYPE}" = "gameloading" ]; then
  [[ "${MODE}" == *"x"* ]] && GAMELOADINGSPLASH="/storage/.config/splash/loading-game-std.png"

  CUSTOM_SPLASH_IMAGE_ENABLED="$(get_ee_setting ee_customsplashimage.enabled)"
  CUSTOM_SPLASH_IMAGE="$(get_ee_setting ee_customsplashimage)"
  CUSTOM_SPLASH_VIDEO_ENABLED="$(get_ee_setting ee_customsplashvideo.enabled)"
  CUSTOM_SPLASH_VIDEO="$(get_ee_setting ee_customsplashvideo)"
  STANDARD_LOADING_VIDEO_ENABLED="$(get_ee_setting ee_standardloadingvideo.enabled)"
  RANDOM_LOADING_VIDEO_ENABLED="$(get_ee_setting ee_randomloadingvideo.enabled)"
  SYSTEM_LOADING_VIDEO_ENABLED="$(get_ee_setting ee_systemloadingvideo.enabled)"
  RANDOM_SYSTEM_VIDEO_ENABLED="$(get_ee_setting ee_randomsystemvideo.enabled)"
  RANDOM_IMAGE_ENABLED="$(get_ee_setting ee_randomimage.enabled)"
  RANDOM_SYSTEM_IMAGE_ENABLED="$(get_ee_setting ee_randomsystemimage.enabled)"
  SYSTEM_SPLASH_IMAGE_ENABLED="$(get_ee_setting ee_systemsplashimage.enabled)"
  STANDARD_LOADING_IMAGE_ENABLED="$(get_ee_setting ee_standardloadingimage.enabled)"

  if [ "${CUSTOM_SPLASH_IMAGE_ENABLED}" = "1" ] && [ -n "${CUSTOM_SPLASH_IMAGE}" ] && [ -f "${CUSTOM_SPLASH_IMAGE}" ]; then
    SPLASH="${CUSTOM_SPLASH_IMAGE}"
  elif [ "${CUSTOM_SPLASH_VIDEO_ENABLED}" = "1" ] && [ -n "${CUSTOM_SPLASH_VIDEO}" ] && [ -f "${CUSTOM_SPLASH_VIDEO}" ]; then
    SPLASH="${CUSTOM_SPLASH_VIDEO}"
  elif [ "${STANDARD_LOADING_VIDEO_ENABLED}" = "1" ] && [ -f "/storage/roms/splash/launching.mp4" ]; then
    SPLASH="/storage/roms/splash/launching.mp4"
  elif [ "${RANDOM_LOADING_VIDEO_ENABLED}" = "1" ]; then
    SPLASH="$(ls /storage/roms/splash/video/*.mp4 2>/dev/null | sort -R | head -n 1)"
  elif [ "${SYSTEM_LOADING_VIDEO_ENABLED}" = "1" ] && [ -f "${SPLASHDIR}/${PLATFORM}/launching.mp4" ]; then
    SPLASH="${SPLASHDIR}/${PLATFORM}/launching.mp4"
  elif [ "${RANDOM_SYSTEM_VIDEO_ENABLED}" = "1" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ]; then
    SPLASH="$(ls ${SPLASHDIR}/${PLATFORM}/*.mp4 2>/dev/null | sort -R | head -n 1)"
  elif [ "${RANDOM_IMAGE_ENABLED}" = "1" ]; then
    SPLASH="$(ls /storage/roms/splash/random/*.{png,jpg,jpeg} 2>/dev/null | sort -R | head -n 1)"
  elif [ "${RANDOM_SYSTEM_IMAGE_ENABLED}" = "1" ] && [ -d "${SPLASHDIR}/${PLATFORM}" ]; then
    SPLASH="$(ls ${SPLASHDIR}/${PLATFORM}/*.{png,jpg,jpeg} 2>/dev/null | sort -R | head -n 1)"
  elif [ "${SYSTEM_SPLASH_IMAGE_ENABLED}" = "1" ] && [ -f "${SPLASHDIR}/${PLATFORM}/launching.png" ]; then
    SPLASH="${SPLASHDIR}/${PLATFORM}/launching.png"
  elif [ "${STANDARD_LOADING_IMAGE_ENABLED}" = "1" ] && [ -f "/storage/roms/splash/launching.png" ]; then
    SPLASH="/storage/roms/splash/launching.png"
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
    BASE_VIDEO_DURATION="$(get_ee_setting ee_videoduration)"
    BASE_IMAGE_DURATION="$(get_ee_setting ee_imageduration)"
    EXIT_VIDEO_DURATION="$(get_ee_setting ee_exit_videoduration)"
    EXIT_IMAGE_DURATION="$(get_ee_setting ee_exit_imageduration)"

    VIDEO_DURATION="${BASE_VIDEO_DURATION}"
    IMAGE_DURATION="${BASE_IMAGE_DURATION}"
    if [ "${ACTION_TYPE}" = "exit" ]; then
      [ -n "${EXIT_VIDEO_DURATION}" ] && VIDEO_DURATION="${EXIT_VIDEO_DURATION}"
      [ -n "${EXIT_IMAGE_DURATION}" ] && IMAGE_DURATION="${EXIT_IMAGE_DURATION}"
    fi

    if is_image "${SPLASH}"; then
      DUR="${IMAGE_DURATION:-3}"
      if [ "${have_mpv}" -eq 1 ]; then
        ${PLAYER_IMG} --fullscreen --no-keepaspect --vf="${MPV_VF}" --image-display-duration=${DUR} "${SPLASH}" >/dev/null 2>&1
      else
        ffplay -fs -autoexit -loglevel error -nostats -vf "${FILTER_FILL}" -t ${DUR} -loop 1 -framerate 1 -i "${SPLASH}" >/dev/null 2>&1
      fi
    elif is_video "${SPLASH}"; then
      if [ -n "${VIDEO_DURATION}" ] && [ "${VIDEO_DURATION}" -gt 0 ]; then
        if [ "${PLAYER_VID}" = "ffplay" ]; then
          ${PLAYER_VID} -fs -autoexit -loglevel error -nostats -vf "${FILTER_FILL}" -t ${VIDEO_DURATION} -i "${SPLASH}" >/dev/null 2>&1
        else
          ${PLAYER_VID} --fullscreen --no-keepaspect --vf="${MPV_VF}" --length=${VIDEO_DURATION} "${SPLASH}" >/dev/null 2>&1
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
