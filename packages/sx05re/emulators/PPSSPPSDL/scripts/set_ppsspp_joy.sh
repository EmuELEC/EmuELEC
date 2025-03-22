#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.config/ppsspp/PSP/SYSTEM"
CONFIG=${CONFIG_DIR}/controls.ini
CONFIG2=${CONFIG_DIR}/controls.ini

CONFIG_TMP=/tmp/jc/ppsspp.tmp


source joy_common.sh "ppsspp"

declare -A GC_PPSSPP_VALUES=(
  [h0.1]="10-19" #Up
  [h0.4]="10-20" #Down
  [h0.8]="10-21" #Left
  [h0.2]="10-22" #Right
  [b0]="10-190"
  [b1]="10-189"
  [b2]="10-188"
  [b3]="10-191"
  [b4]="10-193"
  [b5]="10-192"
  [b6]="10,196"
  [b7]="10-197"
  [b8]="10,196" # back
  [b9]="10,197" # start
  [b10]="" # usually home.
  [b11]="10-106" #leftstick
  [b12]="10-107" #rightstick
  [b13]="10-19" # up
  [b14]="10-20" # down
  [b15]="10-21" # left
  [b16]="10-22" # right
  [a0-0]="10-4001"
  [a0-1]="10-4000"
  [a1-0]="10-4003"
  [a1-1]="10-4002"
  [a2]="10-4010" #lefttrigger
	[a3]="10-4011" #righttrigger
	[a4]="10-4010" #lefttrigger
  [a5]="10-4011" #righttrigger
)

declare -A KB_PPSSPP_VALUES=(
  [h0.1]="1-19" #Up
  [h0.4]="1-20" #Down
  [h0.8]="1-21" #Left
  [h0.2]="1-22" #Right

  [b0]="1-52"
  [b1]="1-54"
  [b2]="1-47"
  [b3]="1-29"
  [b4]="1-45"
  [b5]="1-51"
  [b6]="1-66"
  [b7]="1-62"

  [a0-0]="1-38"
  [a0-1]="1-40"
  [a1-0]="1-37"
  [a1-1]="1-39"
)

declare -A GC_PPSSPP_BUTTONS=(
  [dpleft]="Left"
  [dpright]="Right"
  [dpup]="Up"
  [dpdown]="Down"
  [x]="Square"
  [y]="Triangle"
  [a]="Cross"
  [b]="Circle"
  [back]="Select"
  [start]="Start"
  [leftshoulder]="L"
  [rightshoulder]="R"
  [leftx-0]="An.Left"
  [leftx-1]="An.Right"
  [lefty-0]="An.Up"
  [lefty-1]="An.Down"
)

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {
  [[ "${1}" != "1" ]] && return
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
  [[ ! -f "${CONFIG}" ]] && return
  while read -r line; do
    [[ "${line}" =~ "Analog limiter ="* ]] && echo "${line}" >> ${CONFIG_TMP}
    [[ "${line}" =~ "RapidFire ="* ]] && echo "${line}" >> ${CONFIG_TMP}
    [[ "${line}" =~ "Unthrottle ="* ]] && echo "${line}" >> ${CONFIG_TMP}
    [[ "${line}" =~ "SpeedToggle ="* ]] && echo "${line}" >> ${CONFIG_TMP}
    [[ "${line}" =~ "Pause ="* ]] && echo "${line}" >> ${CONFIG_TMP}
    [[ "${line}" =~ "Rewind ="* ]] && echo "${line}" >> ${CONFIG_TMP}
  done < ${CONFIG}
}

# Sets pad depending on parameters.
# ${1} = Player Number
# ${2} = js[0-7]
# ${3} = Device GUID
# ${4} = Device Name

set_pad() {
  [[ "${1}" != "1" ]] && return

  local DEVICE_GUID=${3}
  local JOY_NAME="${4}"

  echo "DEVICE_GUID=${DEVICE_GUID}"

  local GC_CONFIG=$(cat "${GCDB}" | grep "${DEVICE_GUID}" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  local L_VAL=
  local R_VAL=

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_PPSSPP_BUTTONS[${BUTTON_INDEX}]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_PPSSPP_VALUES[${TVAL}]}"
      local KBVAL="${KB_PPSSPP_VALUES[${TVAL}]}"

      local RECORD
      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
          if [[ ! -z "${VAL}" ]]; then 
            [[ ! -z "${KBVAL}" ]] && echo "${GC_INDEX} = ${KBVAL},${VAL}" >> ${CONFIG_TMP}
            [[ -z "${KBVAL}" ]] && echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}
          fi
        fi
      fi
      if [[ "${BTN_TYPE}" == "a" ]]; then
        echo "BINDEX=${BUTTON_INDEX}"
        [[ "${BUTTON_INDEX}" == "lefttrigger" ]] && L_VAL=${VAL} && echo "LVAL=${VAL}"
        [[ "${BUTTON_INDEX}" == "righttrigger" ]] && R_VAL=${VAL} && echo "RVAL=${VAL}"
      fi

      # Create Axis Maps
      case ${BUTTON_INDEX} in
        leftx|lefty)
          GC_INDEX="${GC_PPSSPP_BUTTONS[${BUTTON_INDEX}-0]}"
          VAL="${GC_PPSSPP_VALUES[${TVAL}-0]}"
          KBVAL="${KB_PPSSPP_VALUES[${TVAL}-0]}"
          echo "${GC_INDEX} = ${KBVAL},${VAL}" >> ${CONFIG_TMP}

          GC_INDEX="${GC_PPSSPP_BUTTONS[${BUTTON_INDEX}-1]}"
          VAL="${GC_PPSSPP_VALUES[${TVAL}-1]}"
          KBVAL="${KB_PPSSPP_VALUES[${TVAL}-1]}"
          echo "${GC_INDEX} = ${KBVAL},${VAL}" >> ${CONFIG_TMP}
          ;;
      esac
  done

  [[ ! -z "${L_VAL}" ]] && sed -i -r "s|L = (.*)|L = \1,${L_VAL}|g" "${CONFIG_TMP}"
  [[ ! -z "${R_VAL}" ]] && sed -i -r "s|R = (.*)|R = \1,${R_VAL}|g" "${CONFIG_TMP}"

  echo "[Control Mapping]" > ${CONFIG2}
  cat "${CONFIG_TMP}" | sort >> ${CONFIG2}
  rm "${CONFIG_TMP}"
}

jc_get_players
