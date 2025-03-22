#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

[[ ! -d "/emuelec/configs/solarus/saves/" ]] && mkdir -p "/emuelec/configs/solarus/saves/"

if [ "${EE_DEVICE}" == "OdroidGoAdvance" ] || ["${EE_DEVICE}" == "Amlogic-ng" ] || [ "${EE_DEVICE}" == "GameForce" ]; then 
    gptokeyb -c /emuelec/configs/gptokeyb/solarus-run.gptk &
    SDL_GAMECONTROLLERCONFIG_FILE="" solarus-run -fullscreen=yes ${1}
    killall gptokeyb
else
    solarus-run -fullscreen=yes ${1}
fi

exit 0
