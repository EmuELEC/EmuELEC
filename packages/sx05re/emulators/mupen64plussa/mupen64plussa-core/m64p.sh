#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)
#
# 2025 to the present DiegroSan (https://github.com/Diegrosan)
# Multithreading used for faster extraction.
# Simultaneous execution of set_mupen64_joy.sh and 7za
# Add suport 64DD...

# Source predefined functions and variables
. /etc/profile

CONFIGDIR="/emuelec/configs/mupen64plussa"
SAVEDIR="/storage/roms/savestates/mupen64plussa"
BIOSDIR="/storage/roms/bios/Mupen64plus"

mkdir -p ${CONFIGDIR}
mkdir -p ${SAVEDIR}

# Setup configs
for files in /usr/local/share/mupen64plus/*; do
    dest_file="${CONFIGDIR}/$(basename "$files")"
    [[ -f "$dest_file" ]] || cp "$files" "$dest_file"
done

FILE="$1"

GAMEDIR=$(dirname "${FILE}")

extract_archive() {
    mkdir -p /tmp/mupen64plus
    rm -rf /tmp/mupen64plus/*

    7za x -mmt=on -y "$FILE" -o/tmp/mupen64plus >/dev/null 2>&1
    find /tmp/mupen64plus -maxdepth 1 \( -name "*.z64" -o -name "*.n64" -o -name "*.v64" -o -name "*.bin" -o -name "*.rom" \) | head -n1
}

setup_gamepad() {
    AUTOGP=$(get_ee_setting mupen64plus_auto_gamepad)
    [[ "$AUTOGP" != "0" ]] && set_mupen64_joy.sh
}

EXT="${FILE##*.}"
if [[ "$EXT" == "zip" || "$EXT" == "7z" ]]; then
    setup_gamepad &
    pad_pid=$!
    
    EXTRACTED_ROM=$(extract_archive)
    
    wait $pad_pid
    
    if [[ -n "$EXTRACTED_ROM" ]]; then
        FILE="$EXTRACTED_ROM"
    else
        echo "Error: No valid ROM found in compressed file."
        exit 1
    fi
else
    setup_gamepad
fi

GAMENAME=$(basename "${FILE%.*}")

IPLROM="${BIOSDIR}/N64DD IPLROM (J).n64"
[ ! -f "${IPLROM}" ] && IPLROM="${BIOSDIR}/IPL.n64"

if [ -f "${GAMEDIR}/${GAMENAME}.ndd" ] && [ -f "${IPLROM}" ]; then
    RENMODE="1"
    SETMEMORY="DisableExtraMem[Core]=False"
    DDDISK="${GAMEDIR}/${GAMENAME}.ndd"
else
    RENMODE="2"
    SETMEMORY="DisableExtraMem[Core]=True"
    IPLROM=""
    DDDISK=""
fi

# Get resolution
case "$(oga_ver)" in
    "OGA"*) RES_W="480"; RES_H="320" ;;
    "OGS")  RES_W="854"; RES_H="480" ;;
    "GF")   RES_W="640"; RES_H="480" ;;
    *)      read -r RES_W RES_H <<< "$(echo $(get_resolution))" ;;
esac

RES="${RES_W}x${RES_H}"
echo "RESOLUTION=$RES"

#RES="800x400" #test
#echo " --emumode "${RENMODE}" --set "${SETMEMORY}" --dd-ipl-rom "${IPLROM}" --dd-disk "${DDDISK}" "${FILE}""

# Launch emulator
case "$2" in
    "m64p_gl64mk2")
        mupen64plus --fullscreen --resolution "$RES" --emumode "${RENMODE}" --set "${SETMEMORY}" --configdir "$CONFIGDIR" --datadir "$CONFIGDIR" --savestate "$SAVEDIR" --gfx mupen64plus-video-glide64mk2.so --dd-ipl-rom "${IPLROM}" --dd-disk "${DDDISK}" "${FILE}" ;;
    *)
        mupen64plus --fullscreen --resolution "$RES" --emumode "${RENMODE}" --set "${SETMEMORY}" --configdir "$CONFIGDIR" --datadir "$CONFIGDIR" --savestate "$SAVEDIR" --gfx mupen64plus-video-rice.so --dd-ipl-rom "${IPLROM}" --dd-disk "${DDDISK}" "${FILE}" ;;
esac

# Cleanup
rm -rf /tmp/mupen64plus/*

