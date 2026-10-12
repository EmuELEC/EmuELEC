#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

[ ! -e "/storage/roms/ports/gmloader/libc++_shared.so" ] && cp "/usr/config/emuelec/configs/gmloader/libc++_shared.so" "/storage/roms/ports/gmloader/libc++_shared.so"

cd /storage/roms/ports/gmloader
LD_PRELOAD=/usr/lib32/sdl_swcursor.so gmloader "${1}"
