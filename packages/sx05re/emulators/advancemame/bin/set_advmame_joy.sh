#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)

# 08/01/23 - Joshua L - Fixed a couple of issues.

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.advance"
CONFIG="${CONFIG_DIR}/advmame.rc"
ES_FEATURES="/storage/.config/emulationstation/es_features.cfg"

source joy_common.sh "advmame"

PLATFORM=${1}
ROMNAME=${2}


BTN_CFG="0 1 2 3 4 5 6 7"

BTN_H0=$(advj | grep -B 1 -E "^joy 0 .*" | grep sticks: | sed "s|sticks:\ ||" | tr -d ' ')

declare -A ADVMAME_VALUES=(
  ["b0"]="button1"
  ["b1"]="button2"
  ["b2"]="button3"
  ["b3"]="button4"
  ["b4"]="button5"
  ["b5"]="button6"
  ["b6"]="button7"
  ["b7"]="button8"
  ["b8"]="button9"
  ["b9"]="button10"
  ["b10"]="button11"
  ["b11"]="button12"
  ["b12"]="button13"
  ["b13"]="button14"
  ["b14"]="button15"
  ["b15"]="button16"
  ["b16"]="button17"
  ["b17"]="button18"
  ["h0.1"]="stick${BTN_H0},y,up"
  ["h0.4"]="stick${BTN_H0},y,down"
  ["h0.8"]="stick${BTN_H0},x,left"
  ["h0.2"]="stick${BTN_H0},x,right"
  ["a0,1"]="stick,y,up"
  ["a0,2"]="stick,y,down"
  ["a1,1"]="stick,x,left"
  ["a1,2"]="stick,x,right"
  ["a2,1"]="stick2,x,left"
  ["a2,2"]="stick2,x,right"
  ["a3,1"]="stick3,y,up"
  ["a3,2"]="stick3,y,down"
  ["a4,1"]="stick2,x,left"
  ["a4,2"]="stick2,x,right"
  ["a5,1"]="stick3,y,up"
  ["a5,2"]="stick3,y,down"
)

declare GC_ORDER=(
  "b"
  "a"
  "y"
  "x"
	"leftshoulder"
  "rightshoulder"
  "righttrigger"
  "lefttrigger"
)

declare -A GC_NAMES=()

get_button_cfg() {
	local BTN_INDEX=$(get_ee_setting "joy_btn_index" "${PLATFORM}" "${ROMNAME}")
  if [[ ! -z ${BTN_INDEX} ]]; then
		local BTN_SETTING="AdvanceMame.joy_btn_order.${BTN_INDEX}"
    local BTN_CFG_TMP="$(get_ee_setting ${BTN_SETTING})"
		[[ ! -z ${BTN_CFG_TMP} ]] && BTN_CFG="${BTN_CFG_TMP}"
	fi
	echo "${BTN_CFG}"
}


clean_pad() {
	sed -i "/device_joystick.*/d" ${CONFIG}
	sed -i "/input_map\[p${1}_.*/d" ${CONFIG}
	sed -i "/input_map\[coin${1}.*/d" ${CONFIG}
	sed -i "/input_map\[start${1}.*/d" ${CONFIG}

  if [[ "${1}" == "1" ]]; then
    sed -i '/input_map\[ui_[[:alpha:]]*\].*/d' ${CONFIG}
  fi
	echo "device_joystick raw" >> ${CONFIG}
}


# Sets pad depending on parameters ${GAMEPAD} = name ${1} = player
set_pad(){
  local P_INDEX=$(( ${1} - 1 ))
  local DEVICE_GUID=${3}
  local JOY_NAME="${4}"

  local GC_CONFIG=$(cat "${GCDB}" | grep "${DEVICE_GUID}" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  JOY_NAME="$(cat "/tmp/JOYPAD_NAMES/JOYPAD${1}.txt" | cut -d'"' -f2 )"
  [[ -z "${JOY_NAME}" ]] && return

  local GAMEPAD="$(advj | grep "'${JOY_NAME}'" | cut -d"'" -f2 | head -n 1 )"
  [[ -z "${GAMEPAD}" ]] && return

  BTN_H0=$(advj | grep -B 1 -E "^joy ${P_INDEX}.*" | grep sticks: | sed "s|sticks:\ ||" | tr -d ' ')
  ADVMAME_VALUES["h0.1"]="stick${BTN_H0},y,up"
  ADVMAME_VALUES["h0.4"]="stick${BTN_H0},y,down"
  ADVMAME_VALUES["h0.8"]="stick${BTN_H0},x,left"
  ADVMAME_VALUES["h0.2"]="stick${BTN_H0},x,right"

  ADVMAME_VALUES["a0,1"]="stick,y,up"
  ADVMAME_VALUES["a0,2"]="stick,y,down"
  ADVMAME_VALUES["a1,1"]="stick,x,left"
  ADVMAME_VALUES["a1,2"]="stick,x,right"

local INVERT_AXIS=$(get_ee_setting "advmame_invert_axis")
  if [[ ${INVERT_AXIS} == 1 ]]; then
      ADVMAME_VALUES["a1,1"]="stick,y,up"
      ADVMAME_VALUES["a1,2"]="stick,y,down"
      ADVMAME_VALUES["a0,1"]="stick,x,left"
      ADVMAME_VALUES["a0,2"]="stick,x,right"
    fi

  local NAME_NUM="${GC_NAMES[${GAMEPAD}]}"
  if [[ -z "NAME_NUM" ]]; then
    GC_NAMES[${GAMEPAD}]=1
  else
    GC_NAMES[${GAMEPAD}]=$(( NAME_NUM+1 ))
  fi
	[[ "${GC_NAMES[${GAMEPAD}]}" -gt "1" ]] && GAMEPAD="${GAMEPAD}_${GC_NAMES[${GAMEPAD}]}"
#  GAMEPAD=0

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  declare DIRS=()
  declare -A DIR_INDEX=(
    [dpup]="0"
    [dpdown]="1"
    [dpleft]="2"
    [dpright]="3"
    [leftx]="0,1"
    [lefty]="2,3"
  )
  local ADD_HAT=$(get_ee_setting advmame_add_hat)
  local i=1
  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  declare -A GC_ASSOC=()
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local GC_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      [[ ${GC_INDEX} == "" || ${GC_INDEX} == "platform" ]] && continue

      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      GC_ASSOC["${GC_INDEX}"]=${TVAL}

      [[ " ${GC_ORDER[*]} " == *" ${GC_INDEX} "* ]] && continue
      local BUTTON_VAL=${TVAL:1}
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${ADVMAME_VALUES[${TVAL}]}"
      local I="${DIR_INDEX[${GC_INDEX}]}"
      local DIR="${DIRS[${I}]}"

      # Create Axis Maps
      case ${GC_INDEX} in
        dpup|dpdown|dpleft|dpright)
          [[ ! -z "${DIR}" ]] && DIR+=" or "
    		  if [[ "${BTN_TYPE}" == "a" ]]; then
      			local direction
      			case ${GC_INDEX} in
      				dpleft|dpup)
      					direction=1
      					;;
      				dpright|dpdown)
      					direction=2
      					;;
      			esac
      			VAL="${ADVMAME_VALUES[${TVAL},${direction}]}"
      			DIR+="joystick_digital[${GAMEPAD},${VAL}]"
      			DIRS["${I}"]="${DIR}"
    		  else
      			[[ "${BTN_TYPE}" == "b" ]] && DIR+="joystick_button[${GAMEPAD},${VAL}]"
      			[[ "${BTN_TYPE}" == "h" ]] && DIR+="joystick_digital[${GAMEPAD},${VAL}]"
      			DIRS["${I}"]="${DIR}"
    		  fi
          ;;
        leftx|lefty)
          for i in {1..2}; do
            I=$(echo "${DIR_INDEX[${GC_INDEX}]}" | cut -d, -f "${i}")
            DIR="${DIRS[${I}]}"
            [[ ! -z "${DIR}" ]] && DIR+=" or "
            VAL="${ADVMAME_VALUES[${TVAL},${i}]}"
            DIR+="joystick_digital[${GAMEPAD},${VAL}]"
            DIRS["${I}"]=${DIR}
          done
          ;;
        start)
          echo "input_map[start${1}] joystick_button[${GAMEPAD},${VAL}]" >> ${CONFIG}
          ;;
        back)
          echo "input_map[coin${1}] joystick_button[${GAMEPAD},${VAL}]" >> ${CONFIG}
          ;;
      esac
  done

  declare -i i=1
  for bi in ${BTN_CFG}; do
    local button="${GC_ORDER[${bi}]}"
    [[ -z "${button}" ]] && continue
    button="${GC_ASSOC[${button}]}"

    local BTN_TYPE="${button:0:1}"
    if [[ "${BTN_TYPE}" == "a" ]]; then
      local STR="input_map[p${1}_button${i}]"
      for j in {1..2}; do
        local VAL="${ADVMAME_VALUES[${button},${j}]}"
        STR+=" joystick_digital[${GAMEPAD},${VAL}]"
      done
      echo "${STR}" >> ${CONFIG}
    elif [[ "${BTN_TYPE}" == "b" ]]; then
      local VAL="${ADVMAME_VALUES[${button}]}"
      echo "input_map[p${1}_button${i}] joystick_button[${GAMEPAD},${VAL}]" >> ${CONFIG}
    fi
    (( i++ ))
  done

  echo "input_map[p${1}_up] ${DIRS[0]}" >> ${CONFIG}
  echo "input_map[p${1}_down] ${DIRS[1]}" >> ${CONFIG}
  echo "input_map[p${1}_left] ${DIRS[2]}" >> ${CONFIG}
  echo "input_map[p${1}_right] ${DIRS[3]}" >> ${CONFIG}

  # Menu should only be set to player 1
  if [[ "${1}" == "1" ]]; then
  #echo "Setting menu buttons for player 1" #debug
    echo "input_map[ui_up] keyboard[0,up] or keyboard[1,up] or ${DIRS[0]}" >> ${CONFIG}
    echo "input_map[ui_down] keyboard[0,down] or keyboard[1,down] or ${DIRS[1]}" >> ${CONFIG}
    echo "input_map[ui_left] keyboard[0,left] or keyboard[1,left] or ${DIRS[2]}" >> ${CONFIG}
    echo "input_map[ui_right] keyboard[0,right] or keyboard[1,right] or ${DIRS[3]}" >> ${CONFIG}

    local button="${GC_ASSOC[b]}"
    local VAL="${ADVMAME_VALUES[${button}]}"
    if [ ! -z "${VAL}" ]; then
      echo "input_map[ui_select] keyboard[0,enter] or keyboard[1,enter] or joystick_button[${GAMEPAD},${VAL}]" >> ${CONFIG}
    fi

    local record="input_map[ui_cancel] keyboard[0,backspace] or keyboard[1,backspace]"
    button="${GC_ASSOC[leftstick]}"
    if [[ ! -z "${button}" ]]; then
      VAL="${ADVMAME_VALUES[${button}]}"
      if [ ! -z "${VAL}" ]; then
        record="${record} or joystick_button[${GAMEPAD},${VAL}]"
      fi
    fi
    echo "${record}"  >> ${CONFIG}

    VAL=""
    button="${GC_ASSOC[rightstick]}"
    if [[ ! -z "${button}" ]]; then
      VAL="${ADVMAME_VALUES[${button}]}"
    elif [[ "${GC_ASSOC[guide]}" != "${GC_ASSOC[back]}" ]]; then
      button="${GC_ASSOC[guide]}"
      VAL="${ADVMAME_VALUES[${button}]}"
    fi

    record="input_map[ui_configure] keyboard[1,tab] or keyboard[0,tab]"
    if [ ! -z "${VAL}" ]; then
      record="${record} or joystick_button[${GAMEPAD},${VAL}]"
    fi
    echo "${record}" >> ${CONFIG}
  fi
}

ADVMAME_REGEX="<emulator.*name=\"AdvanceMame\" +features=.*[ ,\"]joybtnremap[ ,\"].*/>"
ADVMAME_REMAP=$(cat "${ES_FEATURES}" | grep -E "${ADVMAME_REGEX}")
[[ ! -z "${ADVMAME_REMAP}" ]] && BTN_CFG=$(get_button_cfg)
echo "BTN_CFG=${BTN_CFG}"

jc_get_players
