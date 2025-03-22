#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Héctor C.M. (github.com/kelvfimer)


if [ ! -f "/storage/roms/bios/mame/hash/fmtowns_cd.xml" ]; then
    mkdir -p /storage/roms/bios/mame/hash
    cp -rf "/usr/config/emuelec/configs/multiemu/hash/"fm* "/storage/roms/bios/mame/hash"
fi

if [ ! -f "/storage/roms/bios/mame/ini/fmtownsux.ini" ]; then
    mkdir -p /storage/roms/bios/mame/ini
    cp -rf "/usr/config/emuelec/configs/multiemu/ini/"fm* "/storage/roms/bios/mame/ini"
fi

if [ ! -f "/storage/roms/bios/mame/ini/mame.ini" ]; then
    mkdir -p /storage/roms/bios/mame/ini
    cp -rf "/usr/config/emuelec/configs/multiemu/ini/"mame* "/storage/roms/bios/mame/ini"
fi
