#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

# Configure Mupen64Plus players based on GameControllerDB
CONFIG_DIR="/storage/.config/emuelec/configs/mupen64plussa"
CONFIG="${CONFIG_DIR}/mupen64plus.cfg"
CONFIG_TMP="/tmp/jc/mupen64.tmp"

source joy_common.sh "mupen64plus"

BTN_H0=$(get_ee_setting mupen_btn_h0)
[[ -z "${BTN_H0}" ]] && BTN_H0=0


declare -A GC_MUPEN64_VALUES=(
  [h0.1]="hat(${BTN_H0} Up)"
  [h0.4]="hat(${BTN_H0} Down)"
  [h0.8]="hat(${BTN_H0} Left)"
  [h0.2]="hat(${BTN_H0} Right)"
  [b0]="button(0)"
  [b1]="button(1)"
  [b2]="button(2)"
  [b3]="button(3)"
  [b4]="button(4)"
  [b5]="button(5)"
  [b6]="button(6)"
  [b7]="button(7)"
  [b8]="button(8)"
  [b9]="button(9)"
  [b10]="button(10)"
  [b11]="button(11)"
  [b12]="button(12)"
  [b13]="button(13)"
  [b14]="button(14)"
  [b15]="button(15)"
)

declare -A GC_MUPEN64_BUTTONS=(
  [dpleft]="DPad L"
  [dpright]="DPad R"
  [dpup]="DPad U"
  [dpdown]="DPad D"
  [a]="B Button"
  [b]="A Button"
#  [x]="None"
#  [y]="None"
#  [lefttrigger]="Z Trig"
  [righttrigger]="Z Trig"
  [start]="Start"
  [leftshoulder]="L Trig"
  [rightshoulder]="R Trig"
  [leftx]="X Axis"
  [lefty]="Y Axis"
  [rightx,0]="C Button L"
  [rightx,1]="C Button R"
  [righty,0]="C Button U"
  [righty,1]="C Button D"
)

#BTN_SWAP_XY=$(get_ee_setting mupen64_joy_swap_xy)
#if [[ "${BTN_SWAP_XY}" == "1" ]]; then
#  GC_MUPEN64_BUTTONS[x]="None"
#  GC_MUPEN64_BUTTONS[y]="None"
#fi

BTN_SWAP_AB=$(get_ee_setting mupen64_joy_swap_ab)
if [[ "${BTN_SWAP_AB}" == "1" ]]; then
  GC_MUPEN64_BUTTONS[a]="A Button"
  GC_MUPEN64_BUTTONS[b]="B Button"
fi

declare -A GC_MUPEN64_STICKS=(
  ["leftx"]="axis(%d-,%d+)"
  ["lefty"]="axis(%d-,%d+)"
  ["rightx,0"]="axis(%d-)"
  ["rightx,1"]="axis(%d+)"
  ["righty,0"]="axis(%d-)"
  ["righty,1"]="axis(%d+)"
)

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {  
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
  local START_DELETING=0
  local GC_REGEX="\[Input-SDL-Control${1}\]"
  local LN=1
  [[ ! -f "${CONFIG}" ]] && return
  while read -r line; do
    if [[ "${line}" =~ \[.+\] ]]; then
      START_DELETING=0
    fi
    local header=$(echo "${line}" | grep -E "${GC_REGEX}" )
    if [[ ! -z "${header}" ]]; then
      START_DELETING=1
    fi    
    if [[ "${START_DELETING}" == "1" ]]; then
      [[ "${line}" =~ ^AnalogPeak(.*)+$ ]] && echo "${line}" >> ${CONFIG_TMP}
      [[ "${line}" =~ ^AnalogDeadZone(.*)+$ ]] && echo "${line}" >> ${CONFIG_TMP}
      sed -i "${LN} d" "${CONFIG}"
    else
      LN=$(( ${LN} + 1 ))  
    fi
  done < ${CONFIG}
}

# Sets pad depending on parameters.
# ${1} = Player Number
# ${2} = js[0-7]
# ${3} = Device GUID
# ${4} = Device Name

set_pad() {
  local JSI=${2}
  local DEVICE_GUID=${3}
  local JOY_NAME="${4}"

  echo "DEVICE_GUID=${DEVICE_GUID}"

  local GC_CONFIG=$(cat "${GCDB}" | grep "${DEVICE_GUID}" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_MUPEN64_BUTTONS[${BUTTON_INDEX}]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_MUPEN64_VALUES[${TVAL}]}"

      # Create Axis Maps
      case ${BUTTON_INDEX} in
        leftx|lefty)
          local AXIS_VAL=$( printf "${GC_MUPEN64_STICKS[${BUTTON_INDEX}]}" ${BUTTON_VAL} ${BUTTON_VAL} )
          echo "${GC_INDEX} = ${AXIS_VAL}" >> ${CONFIG_TMP}
          continue
          ;;
        rightx|righty)
          GC_INDEX="${GC_MUPEN64_BUTTONS[${BUTTON_INDEX},0]}"
          VAL=$( printf "${GC_MUPEN64_STICKS[${BUTTON_INDEX},0]}" ${BUTTON_VAL} )
          echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}

          GC_INDEX="${GC_MUPEN64_BUTTONS[${BUTTON_INDEX},1]}"
          VAL=$( printf "${GC_MUPEN64_STICKS[${BUTTON_INDEX},1]}" ${BUTTON_VAL} )
          echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}
          continue
          ;;
      esac

      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
          [[ ! -z "${VAL}" ]] && echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}
        fi
        if [[ "${BTN_TYPE}" == "a" ]]; then
          VAL=$( printf "axis(%d+)" ${BUTTON_VAL} )
          echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}
        fi
      fi

  done

  printf "\n\n[Input-SDL-Control${1}]\n" >> ${CONFIG}
  echo "version = 2.000000" >> ${CONFIG}
  echo "mode = 0" >> ${CONFIG}
  local index=$(( ${1} - 1 ))
  echo "device = ${JSI:2:1}" >> ${CONFIG}
  echo "name = \"${JOY_NAME}\"" >> ${CONFIG}
  echo "plugged = True" >> ${CONFIG}
  echo "plugin = 2" >> ${CONFIG}
  echo "mouse = False" >> ${CONFIG}
  echo "Mempak switch = \"\"" >> ${CONFIG}
  echo "Rumblepak switch = \"\"" >> ${CONFIG}

  local RES=$(cat ${CONFIG_TMP} | grep -E "^AnalogPeak *= *(.*)$")
  [[ -z "${RES}" ]] && echo "AnalogPeak = \"32768,32768\"" >> ${CONFIG_TMP}
  RES=$(cat ${CONFIG_TMP} | grep -E "^AnalogDeadzone *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "AnalogDeadzone = \"4096,4096\""  >> ${CONFIG_TMP}

  cat "${CONFIG_TMP}" | sort >> ${CONFIG}
  rm "${CONFIG_TMP}"
}

jc_get_players
