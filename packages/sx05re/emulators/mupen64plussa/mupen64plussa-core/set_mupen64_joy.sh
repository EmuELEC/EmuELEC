#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)
# Optimized application 2x faster 2025-present DiegroSan

# Source predefined functions and variables
. /etc/profile

# Configure Mupen64Plus players based on GameControllerDB
CONFIG_DIR="/storage/.config/emuelec/configs/mupen64plussa"
CONFIG="${CONFIG_DIR}/mupen64plus.cfg"
CONFIG_TMP="/tmp/jc/mupen64.tmp"

source joy_common.sh "mupen64plus"

BTN_H0=$(get_ee_setting mupen_btn_h0)
BTN_H0=${BTN_H0:-0}

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

clean_pad() {
    [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
    [[ ! -f "${CONFIG}" ]] && return
    
    local GC_REGEX="\[Input-SDL-Control${1}\]"
    local in_section=0
    local temp_file=$(mktemp)
    
    while IFS= read -r line; do
        if [[ "$line" =~ \[.*\] ]]; then
            if [[ "$line" =~ $GC_REGEX ]]; then
                in_section=1
                # Keep AnalogPeak and AnalogDeadZone if they exist
                grep -E "^AnalogPeak|^AnalogDeadZone" "${CONFIG}" | head -2 >> "${CONFIG_TMP}"
            else
                in_section=0
            fi
        fi
        
        if (( !in_section )); then
            echo "$line" >> "$temp_file"
        fi
    done < "${CONFIG}"
    
    mv "$temp_file" "${CONFIG}"
    rm -f "$temp_file"
}

set_pad() {
    local JSI=${2}
    local DEVICE_GUID=${3}
    local JOY_NAME="${4}"

    local GC_CONFIG="${5}"
    [[ -z ${GC_CONFIG} ]] && return

    local GC_MAP=$(cut -d',' -f3- <<< "${GC_CONFIG}")
    IFS=',' read -ra GC_ARRAY <<< "${GC_MAP}"

    for REC in "${GC_ARRAY[@]}"; do
        local BUTTON_INDEX=$(cut -d ":" -f 1 <<< "${REC}")
        local TVAL=$(cut -d ":" -f 2 <<< "${REC}")
        local BUTTON_VAL=${TVAL:1}
        local GC_INDEX="${GC_MUPEN64_BUTTONS[${BUTTON_INDEX}]}"
        local BTN_TYPE=${TVAL:0:1}
        local VAL="${GC_MUPEN64_VALUES[${TVAL}]}"

        case ${BUTTON_INDEX} in
            leftx|lefty)
                printf "%s = axis(%d-,%d+)\n" "${GC_INDEX}" "${BUTTON_VAL}" "${BUTTON_VAL}" >> "${CONFIG_TMP}"
                ;;
            rightx|righty)
                printf "%s = axis(%d-)\n" "${GC_MUPEN64_BUTTONS[${BUTTON_INDEX},0]}" "${BUTTON_VAL}" >> "${CONFIG_TMP}"
                printf "%s = axis(%d+)\n" "${GC_MUPEN64_BUTTONS[${BUTTON_INDEX},1]}" "${BUTTON_VAL}" >> "${CONFIG_TMP}"
                ;;
            *)
                if [[ -n "${GC_INDEX}" ]]; then
                    case "${BTN_TYPE}" in
                        b|h) [[ -n "${VAL}" ]] && echo "${GC_INDEX} = ${VAL}" >> "${CONFIG_TMP}" ;;
                        a) printf "%s = axis(%d+)\n" "${GC_INDEX}" "${BUTTON_VAL}" >> "${CONFIG_TMP}" ;;
                    esac
                fi
                ;;
        esac
    done

    {
        printf "\n\n[Input-SDL-Control%s]\n" "${1}"
        echo "version = 2.000000"
        echo "mode = 0"
        echo "device = ${JSI:2:1}"
        echo "name = \"${JOY_NAME}\""
        echo "plugged = True"
        echo "plugin = 2"
        echo "mouse = False"
        echo "Mempak switch = \"\""
        echo "Rumblepak switch = \"\""
    } >> "${CONFIG}"

    # Add default values if they don't exist
    grep -q "^AnalogPeak" "${CONFIG_TMP}" || echo "AnalogPeak = \"32768,32768\"" >> "${CONFIG_TMP}"
    grep -q "^AnalogDeadzone" "${CONFIG_TMP}" || echo "AnalogDeadzone = \"4096,4096\"" >> "${CONFIG_TMP}"

    sort "${CONFIG_TMP}" >> "${CONFIG}"
    rm -f "${CONFIG_TMP}"
}

jc_get_players
