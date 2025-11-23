#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

FOOT_CONFIG_DIR=/storage/.config/foot
FOOT_CONFIG_DEFAULT=/usr/share/foot/foot.ini
FOOT_LOG_FILE=/var/log/foot.log

if [ ! -f ${FOOT_CONFIG_DIR}/foot.ini ]; then
  mkdir -p ${FOOT_CONFIG_DIR}
  cp ${FOOT_CONFIG_DEFAULT} ${FOOT_CONFIG_DIR}
fi

if [ -z "${LOCPATH}" ]; then
  export LOCPATH="/storage/.cache/locpath"
fi

/usr/bin/foot >${FOOT_LOG_FILE} 2>&1
