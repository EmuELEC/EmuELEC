# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

# Allow upgrades between arm and aarch64
if [ "$1" = "@PROJECT@.arm" -o "$1" = "@PROJECT@.aarch64" ]; then
  exit 0
else
  exit 1
fi
