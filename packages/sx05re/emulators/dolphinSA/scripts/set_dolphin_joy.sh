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

# Optional override: Dolphin axis number of hat 0 X (hat 0 Y is the next axis).
# Normally not needed, the hat axes are worked out from the evdev capabilities.
BTN_H0=$(get_ee_setting dolphin_btn_h0)

# Dolphin's evdev backend does not number inputs the same way SDL does, so the
# SDL indexes in the gamecontroller mapping can't be used as they are:
#  - Dolphin numbers every EV_KEY code of the device in ascending order from 0.
#    Keys below BTN_MISC (e.g. KEY_RECORD on Xbox Series pads, KEY_BACK,
#    KEY_HOMEPAGE) come first and shift every following "Button N".
#  - SDL numbers BTN_JOYSTICK (0x120)..KEY_MAX-1 first, then the codes below
#    BTN_JOYSTICK.
#  - Dolphin has no hats, they are plain axes (Axis N-/N+), and it numbers all
#    EV_ABS codes below ABS_MISC. SDL leaves digital hats out of its axes.
# The translation is built from /sys/class/input/jsX/device/capabilities.

SYSFS_INPUT="${SYSFS_INPUT:-/sys/class/input}"

BTN_JOYSTICK=$(( 0x120 ))
KEY_MAX=$(( 0x2ff ))
KEY_CNT=$(( 0x300 ))
ABS_HAT0X=$(( 0x10 ))
ABS_HAT3Y=$(( 0x17 ))
ABS_MISC=$(( 0x28 ))
ABS_MAX=$(( 0x3f ))

# sysfs prints capability bitmaps as words of the kernel's long size.
CAP_WORD_HEX="${CAP_WORD_HEX:-}"
if [[ -z "${CAP_WORD_HEX}" ]]; then
  case "$(uname -m)" in
    aarch64|arm64|x86_64|ppc64*|riscv64|mips64*) CAP_WORD_HEX=16 ;;
    *) CAP_WORD_HEX=8 ;;
  esac
fi

# Prints the bits set in a sysfs capability bitmap, in ascending order.
# ${1} = capability file
cap_bits() {
  local WORDS=($(cat "${1}"))
  local HEX="" WORD
  for WORD in "${WORDS[@]}"; do
    while (( ${#WORD} < CAP_WORD_HEX )); do WORD="0${WORD}"; done
    HEX+="${WORD}"
  done
  local BIT=0 DIGIT i b
  for (( i=${#HEX}-1; i>=0; i-- )); do
    DIGIT=$(( 16#${HEX:i:1} ))
    for b in 0 1 2 3; do
      (( (DIGIT >> b) & 1 )) && echo $(( BIT + b ))
    done
    BIT=$(( BIT + 4 ))
  done
  return 0
}

declare -A SDL_BTN_MAP=()
declare -A SDL_AXIS_MAP=()
declare -A SDL_HAT_X_MAP=()
declare -A SDL_HAT_Y_MAP=()
EVDEV_MAPS=0

# Builds the SDL index -> Dolphin index maps for a pad.
# ${1} = js[0-7]
build_evdev_maps() {
  SDL_BTN_MAP=()
  SDL_AXIS_MAP=()
  SDL_HAT_X_MAP=()
  SDL_HAT_Y_MAP=()
  EVDEV_MAPS=0

  local CAPS="${SYSFS_INPUT}/${1}/device/capabilities"
  [[ ! -r "${CAPS}/key" || ! -r "${CAPS}/abs" ]] && return

  local KEYS=($(cap_bits "${CAPS}/key"))
  local ABSS=($(cap_bits "${CAPS}/abs"))

  declare -A DOLPHIN_BTN=()
  declare -A DOLPHIN_AXIS=()
  declare -A HAS_ABS=()
  local CODE IDX

  # Dolphin: all key codes in ascending order.
  IDX=0
  for CODE in "${KEYS[@]}"; do
    (( CODE < KEY_CNT )) || continue
    DOLPHIN_BTN[${CODE}]=${IDX}
    IDX=$(( IDX + 1 ))
  done

  # SDL: BTN_JOYSTICK..KEY_MAX-1 first, then the codes below BTN_JOYSTICK.
  IDX=0
  for CODE in "${KEYS[@]}"; do
    (( CODE >= BTN_JOYSTICK && CODE < KEY_MAX )) || continue
    SDL_BTN_MAP[${IDX}]=${DOLPHIN_BTN[${CODE}]}
    IDX=$(( IDX + 1 ))
  done
  for CODE in "${KEYS[@]}"; do
    (( CODE < BTN_JOYSTICK )) || continue
    SDL_BTN_MAP[${IDX}]=${DOLPHIN_BTN[${CODE}]}
    IDX=$(( IDX + 1 ))
  done

  # Dolphin: all abs codes below ABS_MISC in ascending order (hats included).
  IDX=0
  for CODE in "${ABSS[@]}"; do
    HAS_ABS[${CODE}]=1
    (( CODE < ABS_MISC )) || continue
    DOLPHIN_AXIS[${CODE}]=${IDX}
    IDX=$(( IDX + 1 ))
  done

  # SDL hats: every ABS_HATnX/ABS_HATnY pair that exists (assumed digital).
  IDX=0
  for (( CODE=ABS_HAT0X; CODE<=ABS_HAT3Y; CODE+=2 )); do
    [[ -n "${HAS_ABS[${CODE}]}" || -n "${HAS_ABS[$(( CODE + 1 ))]}" ]] || continue
    SDL_HAT_X_MAP[${IDX}]=${DOLPHIN_AXIS[${CODE}]}
    SDL_HAT_Y_MAP[${IDX}]=${DOLPHIN_AXIS[$(( CODE + 1 ))]}
    IDX=$(( IDX + 1 ))
  done

  # SDL axes: abs codes below ABS_MAX in ascending order, hats skipped.
  IDX=0
  for CODE in "${ABSS[@]}"; do
    (( CODE < ABS_MAX )) || continue
    (( CODE >= ABS_HAT0X && CODE <= ABS_HAT3Y )) && continue
    SDL_AXIS_MAP[${IDX}]=${DOLPHIN_AXIS[${CODE}]}
    IDX=$(( IDX + 1 ))
  done

  EVDEV_MAPS=1
}

# ${1} = SDL button index. Prints the Dolphin input name.
dolphin_button() {
  if [[ "${EVDEV_MAPS}" == "1" ]]; then
    [[ -n "${SDL_BTN_MAP[${1}]}" ]] && echo "Button ${SDL_BTN_MAP[${1}]}"
  else
    echo "Button ${1}"
  fi
  return 0
}

# ${1} = SDL axis index. Prints the Dolphin axis number.
dolphin_axis() {
  if [[ "${EVDEV_MAPS}" == "1" ]]; then
    [[ -n "${SDL_AXIS_MAP[${1}]}" ]] && echo "${SDL_AXIS_MAP[${1}]}"
  else
    echo "${1}"
  fi
  return 0
}

# ${1} = SDL hat value, e.g. 0.1. Prints the Dolphin input name.
dolphin_hat() {
  local HAT=${1%%.*}
  local MASK=${1#*.}
  local X Y
  if [[ -n "${BTN_H0}" && "${HAT}" == "0" ]]; then
    X=${BTN_H0}
    Y=$(( BTN_H0 + 1 ))
  elif [[ "${EVDEV_MAPS}" == "1" ]]; then
    X=${SDL_HAT_X_MAP[${HAT}]}
    Y=${SDL_HAT_Y_MAP[${HAT}]}
  else
    X=$(( 6 + HAT * 2 ))
    Y=$(( X + 1 ))
  fi
  case "${MASK}" in
    1) [[ -n "${Y}" ]] && echo "Axis ${Y}-" ;;
    4) [[ -n "${Y}" ]] && echo "Axis ${Y}+" ;;
    8) [[ -n "${X}" ]] && echo "Axis ${X}-" ;;
    2) [[ -n "${X}" ]] && echo "Axis ${X}+" ;;
  esac
  return 0
}

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

  build_evdev_maps "${2}"
  echo "EVDEV_MAPS=${EVDEV_MAPS}"

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)

      # Half axis (+a2 / -a2) and inverted axis (a2~) inputs.
      local HALF=""
      if [[ "${TVAL:0:1}" == "+" || "${TVAL:0:1}" == "-" ]]; then
        HALF=${TVAL:0:1}
        TVAL=${TVAL:1}
      fi
      local NEG="-"
      local POS="+"
      if [[ "${TVAL: -1}" == "~" ]]; then
        TVAL=${TVAL%"~"}
        NEG="+"
        POS="-"
      fi

      local BTN_TYPE=${TVAL:0:1}
      local BUTTON_VAL=${TVAL:1}
      local VAL=""
      local AXIS=""
      case "${BTN_TYPE}" in
        b) VAL=$(dolphin_button "${BUTTON_VAL}") ;;
        h) VAL=$(dolphin_hat "${BUTTON_VAL}") ;;
        a) AXIS=$(dolphin_axis "${BUTTON_VAL}") ;;
      esac

      # CREATE BUTTON MAPS (inlcuding hats).
      local GC_INDEX="${GC_DOLPHIN_BUTTONS[${BUTTON_INDEX}]}"
      if [[ ! -z "${GC_INDEX}" ]]; then
        [[ ! -z "${VAL}" ]] && echo "${GC_INDEX} = \`${VAL}\`" >> ${CONFIG_TMP}
        [[ ! -z "${AXIS}" ]] && echo "${GC_INDEX} = \`Axis ${AXIS}${HALF:-${POS}}\`" >> ${CONFIG_TMP}
      fi

      # Wii CREATE BUTTON MAPS (inlcuding hats).
      local WII_INDEX="${WII_DOLPHIN_BUTTONS[${BUTTON_INDEX}]}"
      if [[ ! -z "${WII_INDEX}" ]]; then
        [[ ! -z "${VAL}" ]] && echo "Classic/${WII_INDEX} = \`${VAL}\`" >> ${WII_CONFIG_TMP}
        [[ ! -z "${AXIS}" ]] && echo "Classic/${WII_INDEX} = \`Axis ${AXIS}${HALF:--+}\`" >> ${WII_CONFIG_TMP}
      fi

      # Create Axis Maps (GC and Wii)
      if [[ "${BTN_TYPE}" == "a" && ! -z "${AXIS}" ]]; then
        case ${BUTTON_INDEX} in
          leftx|lefty|rightx|righty)
            echo "${GC_DOLPHIN_STICKS[${BUTTON_INDEX},0]} = \`Axis ${AXIS}${NEG}\`" >> ${CONFIG_TMP}
            echo "${GC_DOLPHIN_STICKS[${BUTTON_INDEX},1]} = \`Axis ${AXIS}${POS}\`" >> ${CONFIG_TMP}
            echo "Classic/${WII_DOLPHIN_STICKS[${BUTTON_INDEX},0]} = \`Axis ${AXIS}${NEG}\`" >> ${WII_CONFIG_TMP}
            echo "Classic/${WII_DOLPHIN_STICKS[${BUTTON_INDEX},1]} = \`Axis ${AXIS}${POS}\`" >> ${WII_CONFIG_TMP}
            ;;
        esac
      fi
  done
  set +f

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
  echo 'Rumble/Motor = `Strong`|`Weak`' >> ${CONFIG}
  echo "Rumble/Motor/Range = ${RUMBLE}" >> ${CONFIG}

  rm "${CONFIG_TMP}"

  cat "${WII_CONFIG_TMP}" | sort >> ${WII_CONFIG}
  echo 'Rumble/Motor = `Strong`|`Weak`' >> ${WII_CONFIG}
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
