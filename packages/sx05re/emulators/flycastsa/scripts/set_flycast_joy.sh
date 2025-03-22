#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.config/flycast"
EMU_FILE="${CONFIG_DIR}/emu.cfg"
MAPPING_DIR="${CONFIG_DIR}/mappings"

source joy_common.sh "flycast"

CONFIG_TMP_A="/tmp/jc/SDLflycastA.tmp"
CONFIG_TMP_D="/tmp/jc/SDLflycastD.tmp"
CONFIG_TMP_E="/tmp/jc/SDLflycastE.tmp"


BTN_H0=$(get_ee_setting flycast_btn_h0)
[[ -z "${BTN_H0}" ]] && BTN_H0=255

declare -A FLYCAST_D_INDEXES=(
  [h0.1]=$(( BTN_H0+1 ))
  [h0.4]=$(( BTN_H0+2 ))
  [h0.8]=$(( BTN_H0+3 ))
  [h0.2]=$(( BTN_H0+4 ))
)

# Only needed for version 3.
#declare -A FLYCAST_D_BIND=(
#  [a]=1
#  [b]=0
#  [x]=3
#  [y]=2
#  [leftshoulder]=4
#  [rightshoulder]=5
#  [lefttrigger]=6
#  [righttrigger]=7
#  [back]=8
#  [start]=9
#  [guide]=10
#  [dpup]=11
#  [dpdown]=12
#  [dpleft]=13
#  [dpright]=14
#)

# Regular buttons a,b,x,y flipped.
declare -A FLYCAST_D_BUTTONS=(
  [x]="btn_y"
  [y]="btn_x"
  [a]="btn_b"
  [b]="btn_a"
  [leftshoulder]="btn_c"
  [rightshoulder]="btn_d"
  [lefttrigger]="btn_trigger_left"
  [righttrigger]="btn_trigger_right"
  [back]="btn_menu"
  [start]="btn_start"
  [guide]="btn_escape"
  [dpup]="btn_dpad1_up"
  [dpdown]="btn_dpad1_down"
  [dpleft]="btn_dpad1_left"
  [dpright]="btn_dpad1_right"
  [leftx,0]="axis_x"
  [leftx,1]="axis_dpad1_x"
  [lefty,0]="axis_y"
  [lefty,1]="axis_dpad1_y"
  [rightx]="axis_right_x"
  [righty]="axis_right_y"
)

BTN_SWAP_XY=$(get_ee_setting flycast_joy_swap_xy)
if [[ "${BTN_SWAP_XY}" == "1" ]]; then
  FLYCAST_D_BUTTONS[x]="btn_x"
  FLYCAST_D_BUTTONS[y]="btn_y"
fi

BTN_SWAP_AB=$(get_ee_setting flycast_joy_swap_ab)
if [[ "${BTN_SWAP_AB}" == "1" ]]; then
  FLYCAST_D_BUTTONS[a]="btn_a"
  FLYCAST_D_BUTTONS[b]="btn_b"
fi


# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {
  #echo "Cleaning pad ${1} ${2}" #debug
  [[ -f "${CONFIG_TMP_A}" ]] && rm "${CONFIG_TMP_A}"
  [[ -f "${CONFIG_TMP_D}" ]] && rm "${CONFIG_TMP_D}"
  [[ -f "${CONFIG_TMP_E}" ]] && rm "${CONFIG_TMP_E}"
  sed -i "s/device${1}\.2.*/device${1}.2 = 10/g" "${EMU_FILE}"
  sed -i "s/device${1}\.1.*/device${1}.1 = 10/g" "${EMU_FILE}"
  sed -i "s/device${1} .*/device${1} = 10/g" "${EMU_FILE}"
  local i=$(( ${1} - 1 ))
  sed -i "s/maple_sdl_joystick_${i}.*/maple_sdl_joystick_${i} = -1/g" "${EMU_FILE}"  
}

# Sets pad depending on parameters.
# ${1} = Player Number
# ${2} = js[0-7]
# ${3} = Device GUID
# ${4} = Device Name

set_pad() {
  echo "set_pad params: ${1} ${2} ${3} ${4}"
  local JSI="${2}"
  local DEVICE_GUID=${3}
  local JOY_NAME="${4}"

  # Insert the correct configs into emu.cfg to enable sdl to work.
  declare -i LN=$( cat "${EMU_FILE}" | grep -n "\[input\]" | cut -d: -f1 | head -1 )

  declare -i index=$(( ${1} - 1 ))
  sed -i "/device${1}/d" "${EMU_FILE}"
  sed -i "/maple_sdl_joystick_${index}/d" "${EMU_FILE}"

  local DEVICE="maple_sdl_joystick_${index} = ${index}\ndevice${1} = 0\ndevice${1}.1 = 1\ndevice${1}.2 = 1\n"
  [[ "${LN}" -gt "0" ]] && LN=$(( LN+1 )) && sed -i "${LN} i ${DEVICE}" "${EMU_FILE}"

  local CONFIG="${MAPPING_DIR}/SDL_${JOY_NAME}.cfg"
  [[ -f "${CONFIG}" ]] && return

  #echo "DEVICE_GUID=${DEVICE_GUID}"

  touch "${CONFIG_TMP_A}"
  touch "${CONFIG_TMP_D}"
  touch "${CONFIG_TMP_E}"

  echo "axis_right_x_inverted = no" >> ${CONFIG_TMP_A}
  echo "axis_right_y_inverted = no" >> ${CONFIG_TMP_A}
  echo "axis_x_inverted = no" >> ${CONFIG_TMP_A}
  echo "axis_y_inverted = no" >> ${CONFIG_TMP_A}

  local GC_RECORD
  [[ -f "${CONFIG}" ]] && GC_RECORD=$(cat "${CONFIG}" | grep -E "^dead_zone = [0-9]*$")
  [[ -z "${GC_RECORD}" ]] && GC_RECORD="dead_zone = 10"
  echo "${GC_RECORD}" >> ${CONFIG_TMP_E}

  [[ -f "${CONFIG}" ]] && rm "${CONFIG}"

  echo "mapping_name = ${JOY_NAME}" >> ${CONFIG_TMP_E}
  echo "version = 2" >> ${CONFIG_TMP_E}

  local GC_CONFIG=$(cat "${GCDB}" | grep "${DEVICE_GUID}" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })

  for index in "${!GC_ARRAY[@]}"; do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BTN_TYPE="${TVAL:1}"
      local FC_INDEX_D=${FLYCAST_D_BUTTONS[${BUTTON_INDEX}]}
      local ABORT_ENTRY=0
      local BTN_TYPE=${TVAL:0:1}
      local NUM=${TVAL:1}

      if [[ ${BUTTON_INDEX} == "leftx" || ${BUTTON_INDEX} == "lefty" ]]; then
        FC_INDEX_D=${FLYCAST_D_BUTTONS[${BUTTON_INDEX},0]}
        echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_D} 
        FC_INDEX_D=${FLYCAST_D_BUTTONS[${BUTTON_INDEX},1]}
        echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_A}
        continue
      fi
      if [[ ! -z "${FC_INDEX_D}" ]]; then
          [[ ${BUTTON_INDEX} == "lefttrigger" ]] && ABORT_ENTRY=1
          [[ ${BUTTON_INDEX} == "righttrigger" ]] && ABORT_ENTRY=1
          [[ ${BUTTON_INDEX} == "back" ]]  && ABORT_ENTRY=1 && echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_E}
          [[ ${BUTTON_INDEX} == "guide" ]] && ABORT_ENTRY=1 && echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_E}

          if [[ ${ABORT_ENTRY} == 0 ]]; then
            [[ ${BTN_TYPE} == "a" ]] && echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_D}
            [[ ${BTN_TYPE} == "b" ]] && echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_D}
            [[ ${BTN_TYPE} == "h" ]] && NUM=${FLYCAST_D_INDEXES[${TVAL}]} && echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_D}
          fi
      fi

      local FC_INDEX_A=${FLYCAST_D_BUTTONS[${BUTTON_INDEX}]}
      if [[ ! -z "${FC_INDEX_A}" ]]; then
        case ${BUTTON_INDEX} in
          "lefttrigger")
            echo "${FC_INDEX_A} = ${NUM}" >> ${CONFIG_TMP_A}
            ;;
          "righttrigger")
            echo "${FC_INDEX_A} = ${NUM}" >> ${CONFIG_TMP_A}
            ;;
        esac
      fi
  done

  echo "[compat]" >> "${CONFIG}"
  cat "${CONFIG_TMP_A}" | sort >> "${CONFIG}"

  echo -e "\n[dreamcast]" >> "${CONFIG}"
  cat "${CONFIG_TMP_D}" | sort >> "${CONFIG}"

  echo -e "\n[emulator]" >> "${CONFIG}"
  cat "${CONFIG_TMP_E}" | sort >> "${CONFIG}"

  rm "${CONFIG_TMP_A}"
  rm "${CONFIG_TMP_D}"
  rm "${CONFIG_TMP_E}"

  local ARCADE_CFG="${CONFIG:0:-4}_arcade.cfg"
  cp -f "${CONFIG}" "${ARCADE_CFG}"

  sed -i '/axis_dpad1_x =/d' "${CONFIG}"
  sed -i '/axis_dpad1_y =/d' "${CONFIG}"
  
}

init_config() {
  mkdir -p "/storage/.config/flycast/mappings"

  # Adjust the emulator config file to load sdl controller files.
  local SDL_JOYSTICK="maple_sdl_joystick_0 = 0\nmaple_sdl_joystick_1 = 1\n"
  local DEVICES="device1 = 0\ndevice1.1 = 1\ndevice1.2 = 1\ndevice2 = 0\ndevice2.1 = 1\ndevice2.2 = 1\n"
  if [[ ! -f "${EMU_FILE}" ]]; then
    echo "[input]" >> "${EMU_FILE}"
    echo -e "${SDL_JOYSTICK}" >> "${EMU_FILE}"
    echo -e "${DEVICES}" >> "${EMU_FILE}"
    return
  fi
}


init_config

jc_get_players
