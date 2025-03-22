#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

DATADIR="/storage/roms/ports/bstone/aog"

if [ "${1}" == "ps" ]; then 
    DATADIR="/storage/roms/ports/bstone/ps"
fi

CONFIGFOLDER="/storage/.config/emuelec/configs/bstone"
PORTNAME="bstone"
GPTOKEYB_CONFIG="/emuelec/configs/gptokeyb/default.gptk"

[[ -e "/emuelec/configs/gptokeyb/bstone.gptk" ]] && GPTOKEYB_CONFIG="/emuelec/configs/gptokeyb/bstone.gptk"

gptokeyb -c "${GPTOKEYB_CONFIG}" &

mkdir -p "${CONFIGFOLDER}"
cd "${CONFIGFOLDER}"

if [ "${EE_DEVICE}" == "Amlogic-ng" ]; then 
    params="--vid_renderer software --vid_width 1920 --vid_height 1080 --vid_is_widescreen 1"
else
    params="--vid_renderer auto-detect"
    case $(oga_ver) in
        "OGS")
            params+=" --vid_width 854 --vid_height 480 --vid_is_widescreen 1"
        ;;
        "OGA")
            params+=" --vid_width 480 --vid_height 320 --vid_is_widescreen 1"
        ;;
        "GF")
            params+=" --vid_width 640 --vid_height 480 --vid_is_widescreen 0"
        ;;
    esac
fi

bstone --profile_dir "${CONFIGFOLDER}" --data_dir "${DATADIR}" ${params}
