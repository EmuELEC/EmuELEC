#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

AUTOGP=$(get_ee_setting ppsspp_auto_gamepad)
if [[ "${AUTOGP}" == "1" ]]; then
	set_ppsspp_joy.sh
fi

ppssppcheevos.sh

cp -Rf /usr/config/ppsspp/PSP/Cheats/. /storage/roms/savestates/PPSSPPSDL/PSP/Cheats

ARG=${1//[\\]/}
export SDL_AUDIODRIVER=alsa          
PPSSPPSDL --fullscreen "${ARG}"
