#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.config/emuelec/configs/dolphin-emu"
CONFIG=${CONFIG_DIR}/GCPadNew.ini
WII_CONFIG=${CONFIG_DIR}/WiimoteNew.ini
MAIN_CONFIG=${CONFIG_DIR}/Dolphin.ini
CONFIG_TMP=/tmp/jc/GCPadNew.tmp
WII_CONFIG_TMP=/tmp/jc/WiimoteNew.tmp

source joy_common.sh "dolphin"

BTN_H0=$(get_ee_setting dolphin_btn_h0)
[[ -z "${BTN_H0}" ]] && BTN_H0=6

H0_AXIS1=$(( BTN_H0+0 ))
H0_AXIS2=$(( BTN_H0+1 ))

declare -A GC_DOLPHIN_VALUES=(
[h0.1]="Hat 0 N"
[h0.4]="Hat 0 S"
[h0.8]="Hat 0 W"
[h0.2]="Hat 0 E"
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
  [x]="Buttons/X"
  [y]="Buttons/Y"
  [a]="Buttons/A"
  [b]="Buttons/B"
  [lefttrigger]="Triggers/L"
  [righttrigger]="Triggers/R"
  [start]="Buttons/Start"
  [rightshoulder]="Buttons/Z"
  [guide]="Buttons/Hotkey"
)

declare -A WII_DOLPHIN_BUTTONS=(
  [dpleft]="D-Pad/Left"
  [dpright]="D-Pad/Right"
  [dpup]="D-Pad/Up"
  [dpdown]="D-Pad/Down"
  [x]="Buttons/X"
  [y]="Buttons/Y"
  [a]="Buttons/A"
  [b]="Buttons/B"
  [leftshoulder]="Triggers/L"
  [rightshoulder]="Triggers/R"
  [back]="Buttons/-"
  [start]="Buttons/+"
  [lefttrigger]="Buttons/L-Analog"
  [righttrigger]="Buttons/R-Analog"
  [guide]="Buttons/Home"
  [leftstick]="Buttons/ZL"
  [rightstick]="Buttons/ZR"
)

BTN_SWAP_XY=$(get_ee_setting dolphin_joy_swap_xy)
if [[ "${BTN_SWAP_XY}" == "1" ]]; then
  GC_DOLPHIN_BUTTONS[x]="Buttons/Y"
  GC_DOLPHIN_BUTTONS[y]="Buttons/X"
  WII_DOLPHIN_BUTTONS[x]="Buttons/Y"
  WII_DOLPHIN_BUTTONS[y]="Buttons/X"
fi
BTN_SWAP_AB=$(get_ee_setting dolphin_joy_swap_ab)
if [[ "${BTN_SWAP_AB}" == "1" ]]; then
  GC_DOLPHIN_BUTTONS[a]="Buttons/B"
  GC_DOLPHIN_BUTTONS[b]="Buttons/A"
  WII_DOLPHIN_BUTTONS[a]="Buttons/B"
  WII_DOLPHIN_BUTTONS[b]="Buttons/A"
fi

declare -A WII_DOLPHIN_STICKS=(
  ["leftx,0"]="Left Stick/Left"
  ["leftx,1"]="Left Stick/Right"
  ["lefty,0"]="Left Stick/Up"
  ["lefty,1"]="Left Stick/Down"
  ["rightx,0"]="Right Stick/Left"
  ["rightx,1"]="Right Stick/Right"
  ["righty,0"]="Right Stick/Up"
  ["righty,1"]="Right Stick/Down"
)

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

# Declare an associative array to store ID counts
declare -A id_counts=()

# Function to add or increment an ID
add_or_increment_id() {
    local id=$1

    # Check if the ID already exists as a key in the associative array
    if [[ -v id_counts["${id}"] ]]; then
        # If present, increment its value (count)
        (( id_counts["${id}"]++ ))
    else
        # If not present, add it to the array and set the count to 1
        id_counts["$id"]=0
    fi
}

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {

  declare -a params=(".*Stick\/Modifier\/Range" ".*Stick\/Dead\ Zone")
  jc_wipe_config_sub_heading "${CONFIG}" "[GCPad${1}]" "${CONFIG_TMP}" "${params[@]}"

  jc_wipe_config_sub_heading "${WII_CONFIG}" "[Wiimote${1}]" "${WII_CONFIG_TMP}"
  echo "[Wiimote${1}]" >> ${WII_CONFIG}
  echo "Source = 0" >> ${WII_CONFIG}
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

  local GC_CONFIG="${5}"
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  sed -i "/\[Wiimote${1}\]/,+1 d" ${WII_CONFIG}

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  echo "[GCPad${1}]" >> ${CONFIG}

  add_or_increment_id "${JOY_NAME}"
  local JOY_INDEX=${id_counts[${JOY_NAME}]}
  echo "Device = evdev/${JOY_INDEX}/${JOY_NAME}" >> ${CONFIG}

  echo "[Wiimote${1}]" >> ${WII_CONFIG}
  echo "Device = evdev/${JOY_INDEX}/${JOY_NAME}" >> ${WII_CONFIG}
  echo "Extension = Classic" >> ${WII_CONFIG}
  echo "Source = 1" >> ${WII_CONFIG}

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_DOLPHIN_VALUES[${TVAL}]}"

      # CREATE BUTTON MAPS (inlcuding hats).
      local GC_INDEX="${GC_DOLPHIN_BUTTONS[${BUTTON_INDEX}]}"
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
          [[ ! -z "${VAL}" ]] && echo "${GC_INDEX} = \`${VAL}\`" >> ${CONFIG_TMP}
        fi
        if [[ "${BTN_TYPE}" == "a" ]]; then
          echo "${GC_INDEX} = \`Axis ${BUTTON_VAL}+\`" >> ${CONFIG_TMP}
        fi
      fi

      # Wii CREATE BUTTON MAPS (inlcuding hats).
      local WII_INDEX="${WII_DOLPHIN_BUTTONS[${BUTTON_INDEX}]}"
      if [[ ! -z "${WII_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
          [[ ! -z "${VAL}" ]] && echo "Classic/${WII_INDEX} = \`${VAL}\`" >> ${WII_CONFIG_TMP}
        fi
        if [[ "${BTN_TYPE}" == "a" ]]; then
          echo "Classic/${WII_INDEX} = \`Axis ${BUTTON_VAL}-+\`" >> ${WII_CONFIG_TMP}
        fi
      fi

      # Create Axis Maps
      case ${BUTTON_INDEX} in
        leftx|lefty|rightx|righty)
          GC_INDEX="${GC_DOLPHIN_STICKS[${BUTTON_INDEX},0]}"
          echo "${GC_INDEX} = \`Axis ${BUTTON_VAL}-\`" >> ${CONFIG_TMP}
          GC_INDEX="${GC_DOLPHIN_STICKS[${BUTTON_INDEX},1]}"
          echo "${GC_INDEX} = \`Axis ${BUTTON_VAL}+\`" >> ${CONFIG_TMP}
          ;;
      esac

      # Wii Create Axis Maps
      case ${BUTTON_INDEX} in
        leftx|lefty|rightx|righty)
          WII_INDEX="${WII_DOLPHIN_STICKS[${BUTTON_INDEX},0]}"
          echo "Classic/${WII_INDEX} = \`Axis ${BUTTON_VAL}-\`" >> ${WII_CONFIG_TMP}
          WII_INDEX="${WII_DOLPHIN_STICKS[${BUTTON_INDEX},1]}"
          echo "Classic/${WII_INDEX} = \`Axis ${BUTTON_VAL}+\`" >> ${WII_CONFIG_TMP}
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

  RUMBLE=$(get_ee_setting ee_rumble_strength)
  [[ -z "${RUMBLE}" ]] && RUMBLE=0
  echo "Rumble/Motor = `Strong`|`Weak`" >> ${CONFIG}
  echo "Rumble/Motor/Range = ${RUMBLE}" >> ${CONFIG}

  rm "${CONFIG_TMP}"

  cat "${WII_CONFIG_TMP}" | sort >> ${WII_CONFIG}
  echo "Rumble/Motor = `Strong`|`Weak`" >> ${WII_CONFIG}
  echo "Rumble/Motor/Range = ${RUMBLE}" >> ${WII_CONFIG}

  rm "${WII_CONFIG_TMP}"
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
