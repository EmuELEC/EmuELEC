#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)

# 08/01/23 - Joshua L - Modified get GUID thanks to shantigilbert.
# 16/10/25 - Joshua L - Modified uses sdljoytest.

# Source predefined functions and variables
. /etc/profile

GCDB="${SDL_GAMECONTROLLERCONFIG_FILE}"

EMULATOR="${1}"

mkdir -p "/tmp/jc"

GAMEPAD_INFO_ALL="/tmp/jc/gamepad_info.txt"

jc_get_config() {
  local GP_FILE="/tmp/jc/js${1}"
  cat ${GAMEPAD_INFO_ALL} | grep -E -A5 "^Gamepad js${1}$" > ${GP_FILE}
  [[ -z ${GP_FILE} ]] && echo ' ' && return

  mapfile -t GAMEPAD_INFO < "${GP_FILE}"

  local JOY_UDEV_NAME="$( echo "${GAMEPAD_INFO[1]}" | cut -c18- )"
  local JOY_SDL_NAME="$( echo "${GAMEPAD_INFO[2]}" | cut -c18- )"
  local DEVICE_GUID="$( echo "${GAMEPAD_INFO[3]}" | cut -c18- )"
  local JOYMAPPING="$( echo "${GAMEPAD_INFO[4]}" | cut -c18- )"
  local INSTANCE_ID="$( echo "${GAMEPAD_INFO[5]}" | cut -c18- )"

  echo $(( $1 + 1 )) js${1} ${DEVICE_GUID} \"${JOY_UDEV_NAME}\" \"${JOYMAPPING}\" \"${JOY_SDL_NAME}\"
}

jc_get_players() {
  gamepad_info -more > ${GAMEPAD_INFO_ALL}

  for jci in {0..3}; do
    CFG=$( jc_get_config "${jci}" )
    CFG_CLEAN=${CFG}
    [[ -z "${CFG}" ]] && CFG_CLEAN=$(( $jci + 1 ))
    echo ${CFG}
    eval clean_pad ${CFG_CLEAN}
    [[ ! -z "${CFG}" ]] && eval set_pad ${CFG}
  done
}
