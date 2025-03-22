#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# OpenBOR only works with Pak files, if you have an extracted game you will need to create a pak first.

OB=${2}
[[ -z ${OB} ]] && OB=OpenBOR

pakname=$(basename "${1}")
pakname="${pakname%.*}"

CONFIGDIR="/emuelec/configs/openbor"
PAKS="${CONFIGDIR}/Paks"
SAVES="${CONFIGDIR}/Saves"

# Make sure the folders exists
	mkdir -p "${PAKS}"
	mkdir -p "${SAVES}"

# make a symlink to the pak
    ln -sf "${1}" "${PAKS}"

# create symlink to master.cfg
rm "${SAVES}/${pakname}.cfg"
if [ ${OB} = "OpenBORff" ]; then
     ln -sf "${CONFIGDIR}/masterff.cfg" "${SAVES}/${pakname}.cfg"
else
     ln -sf "${CONFIGDIR}/master.cfg" "${SAVES}/${pakname}.cfg"
fi

# Run OpenBOR in the config folder
    cd "${CONFIGDIR}"
	SDL_AUDIODRIVER=alsa ${OB}

# Clear PAKS folder to avoid getting the launcher on nex run
rm -rf ${PAKS}/*
