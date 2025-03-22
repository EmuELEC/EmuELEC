#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.config/emuelec/configs/duckstation"
CONFIG=${CONFIG_DIR}/settings.ini

CONFIG_TMP=/tmp/jc/duckstation.tmp

source /usr/bin/joy_common.sh "duckstation"

declare -A GC_VALUES=(
[h0.1]="Button11"
[h0.4]="Button12"
[h0.8]="Button13"
[h0.2]="Button14"
[b0]="Button0"
[b1]="Button1"
[b2]="Button2"
[b3]="Button3"
[b4]="Button9"
[b5]="Button10"
[b6]="Button4"
[b7]="Button6"
[b8]="Button5"
[b9]="Button7"
[b10]="Button8"
[b11]="Button11"
[b12]="Button12"
[b13]="Button13"
[b14]="Button14"
[leftx]="Axis0"
[lefty]="Axis1"
[rightx]="Axis2"
[righty]="Axis3"
[lefttrigger]="+Axis4"
[righttrigger]="+Axis5"
)

declare -A GC_BUTTONS=(
  [dpleft]="ButtonLeft"
  [dpright]="ButtonRight"
  [dpup]="ButtonUp"
  [dpdown]="ButtonDown"
  [y]="ButtonTriangle"
  [x]="ButtonSquare"
  [b]="ButtonCircle"
  [a]="ButtonCross"
  [leftshoulder]="ButtonL1"
  [rightshoulder]="ButtonR1"
  [lefttrigger]="ButtonL2"
  [righttrigger]="ButtonR2"
  [leftstick]="ButtonL3"
  [rightstick]="ButtonR3"
  [back]="ButtonSelect"
  [start]="ButtonStart"
  [guide]="OpenQuickMenu"
  [leftx]="AxisLeftX"
  [lefty]="AxisLeftY"
  [rightx]="AxisRightX"
  [righty]="AxisRightY"
)

declare -A GC_STICKS=(
)

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"

  local START_DELETING=0
  local GC_REGEX="\[Controller${1}\]"
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

  touch "${CONFIG_TMP}"

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  echo -en "\n[Controller${1}]\n" >> ${CONFIG}
  declare -i JOY_INDEX=$(( ${1} - 1 ))
  echo "Type = AnalogController" >> ${CONFIG}

  local ANALOG_MODE=0
  local LINE_INSERT=
  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_BUTTONS[${BUTTON_INDEX}]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_VALUES[${TVAL}]}"

      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BUTTON_INDEX}" == "guide" ]]; then
          LINE_INSERT="${GC_INDEX} = Controller${JOY_INDEX}/${VAL}"
        else
          if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
            [[ ! -z "${VAL}" ]] && echo "${GC_INDEX} = Controller${JOY_INDEX}/${VAL}" >> ${CONFIG_TMP}
          fi
          if [[ "${BTN_TYPE}" == "a" ]]; then
              ANALOG_MODE=1
              VAL="${GC_VALUES[${BUTTON_INDEX}]}"
              [[ ! -z "${VAL}" ]] && echo "${GC_INDEX} = Controller${JOY_INDEX}/${VAL}" >> ${CONFIG_TMP}
          fi
        fi
      fi
  done

  if [[ "${ANALOG_MODE}" == "1" ]]; then
    echo "AnalogDPadInDigitalMode = true" >> ${CONFIG_TMP}
  fi

  cat "${CONFIG_TMP}" | sort >> ${CONFIG}

  if [[ ! -z "${LINE_INSERT}" ]]; then
    sed -i "/\[Hotkeys\]/c" ${CONFIG}
    sed -i "/OpenQuickMenu/c" ${CONFIG}
    echo -en "\n[Hotkeys]\n" >> ${CONFIG}
    echo "${LINE_INSERT}" >> ${CONFIG}
  fi

  rm "${CONFIG_TMP}"
}

jc_get_players
