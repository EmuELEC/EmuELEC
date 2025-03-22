#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/roms/saturn/yabasanshiro1_5"
CONFIG="${CONFIG_DIR}/keymapv2.json"

CONFIG_TMP=/tmp/jc/yabasan.tmp

source /usr/bin/joy_common.sh "yabasanshiro"

declare -A GC_VALUES=(
[h0.1]="1"
[h0.4]="4"
[h0.8]="8"
[h0.2]="2"

[b0]="0"
[b1]="1"
[b2]="2"
[b3]="3"
[b4]="4"
[b5]="5"
[b6]="6"
[b7]="7"
[b8]="8"
[b9]="9"
[b10]="10"
[b11]="11"
[b12]="12"
[b13]="13"
[b14]="14"
[b15]="15"
[b16]="16"

[a0]="0"
[a1]="1"
[a2]="2"
[a3]="3"
[a4]="4"
[a5]="5"
)

declare -A GC_TYPES=(
[h0.1]="hat"
[h0.4]="hat"
[h0.8]="hat"
[h0.2]="hat"

[b0]="button"
[b1]="button"
[b2]="button"
[b3]="button"
[b4]="button"
[b5]="button"
[b6]="button"
[b7]="button"
[b8]="button"
[b9]="button"
[b10]="button"
[b11]="button"
[b12]="button"
[b13]="button"
[b14]="button"
[b15]="button"
[b16]="button"

[a0]="axis"
[a1]="axis"
[a2]="axis"
[a3]="axis"
[a4]="axis"
[a5]="axis"
)

declare -A GC_BUTTONS=(
  [dpleft]="left"
  [dpright]="right"
  [dpup]="up"
  [dpdown]="down"
  [x]="y"
  [y]="x"
  [a]="b"
  [b]="a"
  [leftshoulder]="z"
  [rightshoulder]="c"
  [lefttrigger]="l"
  [righttrigger]="r"
  #[leftstick]=""
  #[rightstick]=""
  [back]="select"
  [start]="start"
  #[guide]=""
  [leftx0]="analogx"
  [leftx1]="analogy"
  [lefty0]="analogl"
  [lefty1]="analogr"
)

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
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

  JOY_NAME="$(echo ${GC_CONFIG} | cut -d',' -f2)"

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  [[ "${1}" != "1" ]] && echo "," >> ${CONFIG_TMP}

  declare -i JOY_INDEX=$(( ${1} - 1 ))
  echo -e "\t\"${JOY_INDEX}_${JOY_NAME}_${DEVICE_GUID}\": {" >> ${CONFIG_TMP}

  local ADD_ANALOG=0

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
      local TYPE="${GC_TYPES[${TVAL}]}"

      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b" ]]; then
          [[ ! -z "${VAL}" ]] && echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": 1 }," >> ${CONFIG_TMP}
        fi
        if [[ "${BTN_TYPE}" == "h" ]]; then
          [[ ! -z "${VAL}" ]] && echo -e "\t\t\"${GC_INDEX}\": { \"id\": 0, \"type\": \"${TYPE}\", \"value\": ${VAL} }," >> ${CONFIG_TMP}
        fi
        if [[ "${BTN_TYPE}" == "a" ]]; then
          case ${BUTTON_INDEX} in
            leftx|rightx|lefty|righty)
              continue
              ;;
          esac
          [[ ! -z "${VAL}" ]] && echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": 1 }," >> ${CONFIG_TMP}
        fi
      fi
      if [[ "${BTN_TYPE}" == "a" ]]; then
        case ${BUTTON_INDEX} in
          leftx|lefty)
            #ADD_ANALOG=1
            GC_INDEX="${GC_BUTTONS[${BUTTON_INDEX}0]}"
            echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": -1 }," >> ${CONFIG_TMP}
            GC_INDEX="${GC_BUTTONS[${BUTTON_INDEX}1]}"
            echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": 1 }," >> ${CONFIG_TMP}
            ;;
        esac
      fi      
  done

  local AXIS="$( cat /tmp/sdljoytest.txt | grep "Joystick ${JOY_INDEX} Axes" | cut -d' ' -f4 | sed 's/^0*//' )"
  if [[ ! -z "${AXIS}" ]]; then
    local AXIS_LEFT=$(( AXIS - 2 ))
    local AXIS_RIGHT=$(( AXIS - 1 ))
    echo -e "\t\t\"analogleft\": { \"id\": ${AXIS_LEFT}, \"type\": \"axis\", \"value\": 0 }," >> ${CONFIG_TMP}
    echo -e "\t\t\"analogright\": { \"id\": ${AXIS_RIGHT}, \"type\": \"axis\", \"value\": 0 }," >> ${CONFIG_TMP}
  fi

  # remove last character
  sed -i '$ s/.$//' ${CONFIG_TMP}

  echo -e "\t}," >> ${CONFIG_TMP}
  echo -e "\t\"player${1}\": {" >> ${CONFIG_TMP}
  echo -e "\t\t\"DeviceID\": ${JOY_INDEX}," >> ${CONFIG_TMP}
  echo -e "\t\t\"deviceGUID\": \"${DEVICE_GUID}\"," >> ${CONFIG_TMP}
  echo -e "\t\t\"deviceName\": \"${JOY_NAME}\"," >> ${CONFIG_TMP}
  echo -e "\t\t\"padmode\": ${ADD_ANALOG}" >> ${CONFIG_TMP}
  echo -e "\t}" >> ${CONFIG_TMP}

  cat "${CONFIG_TMP}" >> ${CONFIG}

  rm "${CONFIG_TMP}"
}

sdljoytest -skip_loop > /tmp/sdljoytest.txt

rm ${CONFIG}
echo "{" >> ${CONFIG}

jc_get_players

echo "}" >> ${CONFIG}

