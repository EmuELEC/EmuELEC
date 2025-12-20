# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

# devices have been renamed after LE9.2
if [ "${1}" = "TinkerBoard.arm" -o "${1}" = "MiQi.arm" ]; then
  if [ "${2}" = "RK3288.arm" ]; then
    exit 0
  fi
fi

# Allow upgrades between arm and aarch64
if [ "${1}" = "@PROJECT@.arm" -o "${1}" = "@PROJECT@.aarch64" ]; then
  exit 0
else
  exit 1
fi
