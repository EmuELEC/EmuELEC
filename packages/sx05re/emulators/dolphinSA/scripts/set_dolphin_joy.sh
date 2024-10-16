#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.config/emuelec/configs/dolphin-emu"
CONFIG=${CONFIG_DIR}/GCPadNew.ini
MAIN_CONFIG=${CONFIG_DIR}/Dolphin.ini
CONFIG_TMP=/tmp/jc/GCPadNew.tmp


source joy_common.sh "dolphin"

BTN_H0=$(get_ee_setting dolphin_btn_h0)
[[ -z "${BTN_H0}" ]] && BTN_H0=6

H0_AXIS1=$(( BTN_H0+0 ))
H0_AXIS2=$(( BTN_H0+1 ))

declare -A GC_DOLPHIN_VALUES=(
[h0.1]="Axis ${H0_AXIS2}-"
[h0.4]="Axis ${H0_AXIS2}+"
[h0.8]="Axis ${H0_AXIS1}-"
[h0.2]="Axis ${H0_AXIS1}+"
[b0]="Button 0"
[b1]="Button 1"
[b2]="Button 2"
[b3]="Button 3"
[b4]="Button 4"
[b5]="Button 5"
[b6]="Button 6"
[b7]="Button 7"
[b8]="Button 8"
[b9]="Button 9"
[b10]="Button 10"
[b11]="Button 11"
[b12]="Button 12"
[b13]="Button 13"
[b14]="Button 14"
[b15]="Button 15"
[b16]="Button 16"

)

declare -A GC_DOLPHIN_BUTTONS=(
  [dpleft]="D-Pad/Left"
  [dpright]="D-Pad/Right"
  [dpup]="D-Pad/Up"
  [dpdown]="D-Pad/Down"
  [x]="Buttons/Y"
  [y]="Buttons/X"
  [a]="Buttons/B"
  [b]="Buttons/A"
  [lefttrigger]="Triggers/L"
  [righttrigger]="Triggers/R"
  [start]="Buttons/Start"
  [rightshoulder]="Buttons/Z"
)

BTN_SWAP_XY=$(get_ee_setting dolphin_joy_swap_xy)
if [[ "${BTN_SWAP_XY}" == "1" ]]; then
  GC_DOLPHIN_BUTTONS[x]="Buttons/X"
  GC_DOLPHIN_BUTTONS[y]="Buttons/Y"
fi
BTN_SWAP_AB=$(get_ee_setting dolphin_joy_swap_ab)
if [[ "${BTN_SWAP_AB}" == "1" ]]; then
  GC_DOLPHIN_BUTTONS[a]="Buttons/A"
  GC_DOLPHIN_BUTTONS[b]="Buttons/B"
fi

declare -A GC_DOLPHIN_STICKS=(
  ["leftx,0"]="Main Stick/Left"
  ["leftx,1"]="Main Stick/Right"
  ["lefty,0"]="Main Stick/Up"
  ["lefty,1"]="Main Stick/Down"
  ["rightx,0"]="C-Stick/Left"
  ["rightx,1"]="C-Stick/Right"
  ["righty,0"]="C-Stick/Up"
  ["righty,1"]="C-Stick/Down"
)

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
  local START_DELETING=0
  local GC_REGEX="\[GCPad${1}\]"
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
      [[ "${line}" =~ ^(.*)+Stick\/Modifier(.*)+$ ]] && echo "${line}" >> ${CONFIG_TMP}
      [[ "${line}" =~ ^(.*)+Stick\/Dead(.*)+$ ]] && echo "${line}" >> ${CONFIG_TMP}
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
  local DEVICE_GUID=${3}
  local JOY_NAME="${4}"

  echo "DEVICE_GUID=${DEVICE_GUID}"

  local GC_CONFIG=$(cat "${GCDB}" | grep "${DEVICE_GUID}" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  echo "[GCPad${1}]" >> ${CONFIG}
  declare -i JOY_INDEX=$(( ${1} - 1 ))
  echo "Device = evdev/${JOY_INDEX}/${JOY_NAME}" >> ${CONFIG}

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_DOLPHIN_BUTTONS[${BUTTON_INDEX}]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_DOLPHIN_VALUES[${TVAL}]}"

      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
          [[ ! -z "${VAL}" ]] && echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}
        fi
        if [[ "${BTN_TYPE}" == "a" ]]; then
          echo "${GC_INDEX} = Axis ${BUTTON_VAL}+" >> ${CONFIG_TMP}
        fi        
      fi

      # Create Axis Maps
      case ${BUTTON_INDEX} in
        lefttrigger|righttrigger)
          if [[ "${BTN_TYPE}" == "a" ]]; then
            VAL=${BUTTON_VAL}
            echo "${GC_INDEX} = Axis ${VAL}+" >> ${CONFIG_TMP}
          fi
          ;;
        leftx|lefty|rightx|righty)
          GC_INDEX="${GC_DOLPHIN_STICKS[${BUTTON_INDEX},0]}"
          echo "${GC_INDEX} = Axis ${BUTTON_VAL}-" >> ${CONFIG_TMP}
          GC_INDEX="${GC_DOLPHIN_STICKS[${BUTTON_INDEX},1]}"
          echo "${GC_INDEX} = Axis ${BUTTON_VAL}+" >> ${CONFIG_TMP}
          ;;
      esac
  done

  local JOYSTICK="Main Stick"
  local GC_RECORD
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^${JOYSTICK}/Modifier *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "${JOYSTICK}/Modifier = Shift_L" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^${JOYSTICK}/Modifier/Range *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "${JOYSTICK}/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^${JOYSTICK}/Dead Zone *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "${JOYSTICK}/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}

  JOYSTICK="C-Stick"
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^${JOYSTICK}/Modifier *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "${JOYSTICK}/Modifier = Control_L" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^${JOYSTICK}/Modifier/Range *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "${JOYSTICK}/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^${JOYSTICK}/Dead Zone *= *(.*)$")
  [[ -z "${GC_RECORD}" ]] && echo "${JOYSTICK}/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}

  cat "${CONFIG_TMP}" | sort >> ${CONFIG}
  rm "${CONFIG_TMP}"
}

init_config() {
  local SIDevices=$( cat "${MAIN_CONFIG}" | grep -E "^SIDevice[0-9] *= *[^6]$")
  [[ -z "${SIDevices}" ]] && return

  declare -i LN=$( cat "${MAIN_CONFIG}" | grep -n -E "SIDevice[0-9] *= *[0-9]" | cut -d: -f1 | head -1 )
  [[ "${LN}" == "0" ]] && LN=$( cat "${MAIN_CONFIG}" | grep -n "\[Core\]" | cut -d: -f1 | head -1 )
  if [ ${LN} -ne 0 ]; then
    sed -i '/SIDevice[0-9] *\= *[0-9]/d' "${MAIN_CONFIG}"
    sed -i "${LN} i SIDevice0=6\nSIDevice1=6\nSIDevice2=6\nSIDevice3=6" "${MAIN_CONFIG}"
  fi
}


init_config

jc_get_players
