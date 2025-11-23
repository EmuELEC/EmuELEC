#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

. /run/sway/sway-daemon.conf
SWAY_LOG_FILE=/var/log/sway.log

if [ ! -z "$(lsmod | grep 'nvidia')" ]; then
  export WLR_NO_HARDWARE_CURSORS=1
  SWAY_GPU_ARGS="--unsupported-gpu"
fi

# start sway, even if no input devices are connected
export WLR_LIBINPUT_NO_DEVICES=1

logger -t Sway "### Starting Sway with -V ${SWAY_GPU_ARGS} ${SWAY_DAEMON_ARGS}"
/usr/bin/sway -V ${SWAY_GPU_ARGS} ${SWAY_DAEMON_ARGS} >${SWAY_LOG_FILE} 2>&1
