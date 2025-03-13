#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)
# Copyright (C) 2024-present DiegroSan (https://github.com/Diegrosan)

# Read the video output mode and set it for emuelec to avoid video flicking.

# This file sets the hdmi output and frame buffer to the argument in pixel width.
# Allowed argument example ./setres.sh 1080p60hz <-- For height 1080 pixels.

# set -x #echo on

# Source predefined functions and variables
. /etc/profile

FILE_MODE="/sys/class/display/mode"
PLATFORM=""
FBN="fb0"

if [ -d "/sys/class/graphics/fb1" ]; then
    FBN="fb1"
fi

switch_resolution()
{
  local MODE=${1}

  # Here we first clear the primary display buffer of leftover artifacts then set
  # the secondary small buffers flag to stop copying across.
  blank_buffer >> /dev/null

  case ${MODE} in
    480cvbs|576cvbs|480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*|*x*)
      echo null > "${FILE_MODE}"
      sleep 1
      echo ${MODE} > "${FILE_MODE}"
  esac
  NEW_MODE=$( cat ${FILE_MODE} )
  [[ "${NEW_MODE}" != "${MODE}" ]] && exit 1
}

get_resolution_size()
{
  local MODE=${1}

  # Here we set the Height and Width of the particular resolution.
  # FBW - Frame Buffer Width, PSW - Physical Screen Width.
  # FBH - Frame Buffer Height, PSH - Physical Screen Height.

  local FBW=${2}
  local FBH=${3}

  local PSW=0
  local PSH=0

  case ${MODE} in
    480cvbs)
      PSW=720
      PSH=480
      [[ -z "${FBW}" ]] && FBW=1024
      [[ -z "${FBH}" ]] && FBH=768
      ;;
    576cvbs)
      PSW=720
      PSH=576
      [[ -z "${FBW}" ]] && FBW=1024
      [[ -z "${FBH}" ]] && FBH=768
      ;;
    480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
      # For resolution with 2 width and height resolution numbers extract the Height.
      # *p* stand for progressive and *i* stand for interlaced.
      case ${MODE} in
        *p*) PSH=$(echo ${MODE} | cut -d'p' -f 1) ;;
        *i*) PSH=$(echo ${MODE} | cut -d'i' -f 1) ;;
      esac
      PSW=$(( ${PSH}*16/9 ))
      [[ "${MODE}" == "480"* ]] && PSW=640
      [[ -z "${FBW}" || ${FBW} == 0 ]] && FBW=${PSW}
      [[ -z "${FBH}" || ${FBH} == 0 ]] && FBH=${PSH}
      ;;
    *x*)
      PSW=$(echo ${MODE} | cut -d'x' -f 1)
      PSH=$(echo ${MODE} | cut -d'x' -f 2 | cut -d'p' -f 1)
      [ ! -n "${PSH}" ] && PSH=$(echo ${MODE} | cut -d'x' -f 2 | cut -d'i' -f 1)
      [[ -z "${FBW}" || ${FBW} == 0 ]] && FBW=${PSW}
      [[ -z "${FBH}" || ${FBH} == 0 ]] && FBH=${PSH}
      ;;
  esac
  echo "${FBW} ${FBH} ${PSW} ${PSH}"
}

set_main_framebuffer() {
  local FBW=${1}
  local FBH=${2}
  local BPP=32

  if [[ -n "${FBW}" && "${FBW}" > 0 && -n "${FBH}" && "${FBH}" > 0 ]]; then
    MFBH=$(( FBH*2 ))
    fbset -fb /dev/${FBN} -g ${FBW} ${FBH} ${FBW} ${MFBH} ${BPP}
    [ -f "/sys/class/graphics/${FBN}/free_scale_axis" ] && echo 0 $(( FBW-1 )) $(( FBH-1 )) > /sys/class/graphics/${FBN}/free_scale_axis
    [ -f "/sys/class/graphics/${FBN}/free_scale" ] && echo 0 > /sys/class/graphics/${FBN}/free_scale
    [ -f "/sys/class/graphics/${FBN}/freescale_mode" ] && echo 0 > /sys/class/graphics/${FBN}/freescale_mode
  fi
}

set_fb_borders() {
  local CUSTOM_OFFSETS=( ${1} ${2} ${3} ${4} )
  local COUNT_ARGS=${#CUSTOM_OFFSETS[@]}
  if [[ "${COUNT_ARGS}" == "4" ]]; then
    echo ${CUSTOM_OFFSETS[@]} > /sys/class/graphics/${FBN}/window_axis
    [ -f "/sys/class/graphics/${FBN}/freescale_mode" ] && echo 1 > /sys/class/graphics/${FBN}/freescale_mode
    [ -f "/sys/class/graphics/${FBN}/free_scale" ] && echo 0x10001 > /sys/class/graphics/${FBN}/free_scale
  fi
}

# Main script starts here

MODE=$( cat ${FILE_MODE} )
BPP=32

ES_MODE=""

if [[ $# == 1 ]]; then
  MODE=${1}
  ES_MODE="ee_es."
fi

if [[ $# == 2 ]]; then
  MODE=${1}
  PLATFORM=${2}
fi

if [[ $# == 3 ]]; then
  MODE=${1}
  PLATFORM=${2}
  ROMNAME=${3}
fi

FBW=0
FBH=0

blank_buffer >> /dev/null

OLD_MODE=$( cat ${FILE_MODE} )

BORDER_VALS=$(get_ee_setting ee_videowindow)

BUFF=$(get_ee_setting ee_video_fb1_size)
[[ -z "${BUFF}" ]] && BUFF=32

if [[ -n "${BUFF}" ]] && [[ ${BUFF} > 0 ]]; then
  fbset -fb /dev/fb1 -g ${BUFF} ${BUFF} ${BUFF} ${BUFF} ${BPP}
fi

[ -f "/sys/class/ppmgr/ppscaler" ] && echo 0 > /sys/class/ppmgr/ppscaler

CVBS_RES_FILE="/storage/.config/cvbs_resolution.txt"
if [[ "${MODE}" == *"cvbs" ]]; then
  if [[ -f "${CVBS_RES_FILE}" ]]; then
    declare -a CVBS_RES=($(cat "${CVBS_RES_FILE}"))
    if [[ ! -z "${CVBS_RES[@]}" ]]; then
        FBW=${CVBS_RES[0]}
        FBH=${CVBS_RES[1]}
    fi
  fi
fi

CUSTOM_RES=$(get_ee_setting ${ES_MODE}framebuffer "${PLATFORM}" "${ROMNAME}")
if [[ ! -z "${CUSTOM_RES}" ]]; then
  declare -a RES=($(echo "${CUSTOM_RES}"))
  if [[ ! -z "${RES[@]}" ]]; then
      FBW=${RES[0]}
      FBH=${RES[1]}
  fi
fi

[[ ${OLD_MODE} != ${MODE} ]] && switch_resolution ${MODE}
MODE=$( cat ${FILE_MODE} )

declare -a SIZE=($( get_resolution_size ${MODE} ${FBW} ${FBH}))

FBW=${SIZE[0]}
FBH=${SIZE[1]}
PSW=${SIZE[2]}
PSH=${SIZE[3]}

if [[ "${EE_DEVICE}" == "Amlogic" ]]; then
  FBW=1920
  FBH=1080
fi

CURRENT_MODE=$( cat ${FILE_MODE} )
if [[ "${CURRENT_MODE}" == "${MODE}" ]]; then
  echo "SET MAIN FRAME BUFFER"
  set_main_framebuffer ${FBW} ${FBH}
  blank_buffer
fi

declare -a CUSTOM_OFFSETS
if [[ -f "/storage/.config/${MODE}_offsets" ]]; then
  CUSTOM_OFFSETS=( $( cat "/storage/.config/${MODE}_offsets" ) )
fi

OFFSET_SETTING=$(get_ee_setting ${ES_MODE}framebuffer_border "${PLATFORM}" "${ROMNAME}")
if [[ ! -z "${OFFSET_SETTING}" ]]; then
  CUSTOM_OFFSETS=( ${OFFSET_SETTING} )
  CUSTOM_OFFSETS[2]=$(( ${PSW} - CUSTOM_OFFSETS[2] - 1 ))
  CUSTOM_OFFSETS[3]=$(( ${PSH} - CUSTOM_OFFSETS[3] - 1 ))
fi

COUNT_ARGS=${#CUSTOM_OFFSETS[@]}
if [[ -z "${OFFSET_SETTING}" ]] && [[ "${MODE}" == *"cvbs" ]]; then
  if [[ "${COUNT_ARGS}" == "0" ]]; then
    [[ "${MODE}" == "480cvbs" ]] && CUSTOM_OFFSETS="30 10 669 469"
    [[ "${MODE}" == "576cvbs" ]] && CUSTOM_OFFSETS="35 20 680 565"
  fi
fi

COUNT_ARGS=${#CUSTOM_OFFSETS[@]}
if [[ "${COUNT_ARGS}" == "0" ]] && [[ ${FBW} != ${PSW} || ${FBH} != ${PSH} ]]; then
  CUSTOM_OFFSETS=(0 0 $(( PSW - 1 )) $(( PSH - 1 )))
elif [[ "${COUNT_ARGS}" == "2" ]]; then
  TMP="${CUSTOM_OFFSETS[0]}"
  CUSTOM_OFFSETS[2]=$(( ${PSW} - ${TMP} - 1 ))
  TMP="${CUSTOM_OFFSETS[1]}"
  CUSTOM_OFFSETS[3]=$(( ${PSH} - ${TMP} - 1 ))
fi

if [[ "${#CUSTOM_OFFSETS[@]}" == "4" ]]; then
  set_fb_borders ${CUSTOM_OFFSETS[@]}
  exit 0
fi

declare -a BORDERS
BORDER_VALS=$(get_ee_setting ee_videowindow)
if [[ ! -z "${BORDER_VALS}" ]]; then
  BORDERS=(${BORDER_VALS})
  COUNT_ARGS=${#BORDERS[@]}
  if [[ ${COUNT_ARGS} != 4 && ${COUNT_ARGS} != 2 ]]; then
    exit 0
  fi
  A1=${BORDERS[0]}
  A2=${BORDERS[1]}
  A3=${BORDERS[2]}
  [[ -z "${A3}" ]] && A3=${PSW}
  A4=${BORDERS[3]}
  [[ -z "${A4}" ]] && A4=${PSH}

  if [[ ! -n "${A1}" || ! -n "${A2}" || ! -n "${A3}" || ! -n "${A4}" ]]; then
    exit 0
  fi
  A3=$(( PSW-A1-1 ))
  A4=$(( PSH-A2-1 ))
  set_fb_borders ${A1} ${A2} ${A3} ${A4}
fi
# End Legacy code

