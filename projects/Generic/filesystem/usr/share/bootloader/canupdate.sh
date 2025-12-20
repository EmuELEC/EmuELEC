# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

# Allow upgrades between different Generic builds
if [ "$1" = "Virtual.x86_64" -o "$1" = "Generic.x86_64" -o "$1" = "Generic-legacy.x86_64" -o "$1" = "gbm.x86_64" -o "$1" = "wayland.x86_64" -o "$1" = "x11.x86_64" ]; then
  exit 0
else
  exit 1
fi
