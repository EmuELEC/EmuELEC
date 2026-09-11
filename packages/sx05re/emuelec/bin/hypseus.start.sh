#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

dir="${1%/}"
name=${dir##*/}
name=${name%.*}
config="/storage/.config/emuelec/configs/hypseus"
configfile="${config}/hypinput.ini"

# hypseus core (SDL_OpenAudioDevice) and Singe (Mix_OpenAudio) both open
# the audio device since 2.11.4 - raw hw:0,0 only allows one client,
# so use dmix for software mixing.
export AUDIODEV="plug:dmix"

if [[ ! -f "${config}/ee_updated" ]]; then
    cp "/usr/config/emuelec/configs/hypseus/hypinput_gamepad.ini" "${configfile}"
fi
touch "${config}/ee_updated"

if [[ -f "${dir}/${name}.commands" ]]; then
    params=$(<"${dir}/${name}.commands")
fi

# Not all gamepads use a trigger.
sed -i 's|AXIS_TRIGGER_RIGHT|BUTTON_X AXIS_TRIGGER_RIGHT|' ${configfile}

cd "${config}"

# -useoverlaysb is only valid for lair/ace/tq since hypseus 2.12,
# any other game type will hard-fail on this argument
sboverlay=""
case "${name}" in
    lair|ace|tq)
        sboverlay="-useoverlaysb 2"
        ;;
esac

# Load bezel from the game dir if present (both naming conventions)
bezel=""
if [[ -f "${dir}/bezel_${name}.png" ]]; then
    bezel="-bezeldir ${dir} -bezel bezel_${name}.png"
elif [[ -f "${dir}/${name}.png" ]]; then
    bezel="-bezeldir ${dir} -bezel ${name}.png"
fi

if [[ -f "${dir}/${name}.zip" ]]; then
    hypseus singe vldp -gamepad -manymouse -framefile "${dir}/${name}.txt" -zlua "${dir}/${name}.zip" -fullscreen ${bezel} ${params}
elif [[ -f "${dir}/${name}.singe" ]]; then
    hypseus singe vldp -gamepad -manymouse -framefile "${dir}/${name}.txt" -script "${dir}/${name}.singe" -fullscreen ${bezel} ${params}
else
    hypseus "${name}" vldp -gamepad -manymouse -framefile "${dir}/${name}.txt" -fullscreen ${sboverlay} ${params}
fi

ret=$?

if [[ ${ret} -eq 143 ]]; then
    exit 0
fi
exit ${ret}