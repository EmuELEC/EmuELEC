#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

dir="${1}"
name=${dir##*/}
name=${name%.*}
config="/storage/.config/emuelec/configs/hypseus"
configfile="${config}/hypinput.ini"

export AUDIODEV=hw:0,0

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

if [[ -f "${dir}/${name}.singe" ]]; then
    hypseus singe vldp -gamepad -manymouse -framefile "${dir}/${name}.txt" -script "${dir}/${name}.singe" -fullscreen -useoverlaysb 2 ${params}
else
    hypseus "${name}" vldp -gamepad -manymouse -framefile "${dir}/${name}.txt" -fullscreen -useoverlaysb 2 ${params}
fi
