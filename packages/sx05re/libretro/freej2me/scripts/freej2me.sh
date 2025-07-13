#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

# Lets check if java is installed and up to date, called from profile
install_java

if [[ -f "/storage/roms/bios/jdk/eeversion" ]]; then
    cp -rf /usr/lib/libretro/freej2me-lr.jar ${HOME}/roms/bios
else
    exit 1
fi
exit 0
