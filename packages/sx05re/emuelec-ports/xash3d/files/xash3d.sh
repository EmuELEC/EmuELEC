#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

XHAS3D_LIBS="/usr/lib/xash3d/valve"

# Exports for xash3d
export XASH3D_BASEDIR=/storage/roms/ports/half-life
export XASH3D_VALVEDIR=${XASH3D_BASEDIR}/valve


# Check if the valve dir exists
if [ ! -x "${XASH3D_VALVEDIR}" ]; then
  text_viewer -e -w -t "ERROR!" -f 24 -m "You need to copy the Half-Life valve folder to ${XASH3D_BASEDIR}!"
  exit 0
fi

if [ ! -e ${XASH3D_VALVEDIR}/emuelec.config.done ]; then
 cp -rf ${XHAS3D_LIBS}/* ${XASH3D_VALVEDIR}/
 cp -rf /usr/emuelec/configs/hl/config.cfg  ${XASH3D_VALVEDIR}/config.cfg
 touch ${XASH3D_VALVEDIR}/emuelec.config.done
fi

# Change to binary folder and run HL
cd /usr/bin/xash3d/usr
./xash3d -ref gles2 -console &> /emuelec/logs/xash3d.log
killall gptokeyb
