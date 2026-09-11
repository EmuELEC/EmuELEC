#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile

ROM="$1"
ROMNAME="${ROM##*/}"
ROMBASE="${ROMNAME%.*}"

# Store original ROM path for .xr sidecar lookup
ORIGINAL_ROM="$ROM"

# Determine machine type based on ROM path
case "$ROM" in
  */dragon32/*) MACHINE="dragon32" ;;
  */dragon64/*) MACHINE="dragon64" ;;
  */coco/*)     MACHINE="coco" ;;
  */coco3/*)    MACHINE="coco3" ;;
  */mc10/*)     MACHINE="mc10" ;;
  *)            MACHINE="dragon64" ;;
esac

# Handle compressed files (ZIP and 7Z)
case "${ROM##*.}" in
  zip|ZIP|7z|7Z)
    TMPDIR="/tmp/xroar_rom_$$"
    mkdir -p "$TMPDIR"

    if [ "${ROM##*.}" = "7z" ] || [ "${ROM##*.}" = "7Z" ]; then
      7z x -q "$ROM" -o"$TMPDIR"
    else
      unzip -q "$ROM" -d "$TMPDIR"
    fi

    for EXT in cas c10 k7 bas asc rom ccc bin wav vdk dsk jvc os9 dmk; do
      FOUND=$(find "$TMPDIR" -type f -iname "*.${EXT}" | head -1)
      if [ -n "$FOUND" ]; then
        ROM="$FOUND"
        break
      fi
    done

    CLEANUP_TMPDIR=1
    ;;
esac

# Check for .xr sidecar file based on original ROM path
XR_FILE="${ORIGINAL_ROM%.*}.xr"
if [ -f "$XR_FILE" ]; then
  TYPE_CMD=$(cat "$XR_FILE")
  LOAD_FLAG="-load"
  TYPE_PARAM="-type ${TYPE_CMD}\r"
else
  case "${ROM##*.}" in
    vdk|VDK|dsk|DSK|jvc|JVC|os9|OS9|dmk|DMK)
      LOAD_FLAG="-run"
      TYPE_PARAM=""
      ;;
    *)
      LOAD_FLAG="-run"
      TYPE_PARAM=""
      ;;
  esac
fi

# Kill old instances
killall -9 gptokeyb 2>/dev/null

# Check for game-specific gptk config
GPTK_GAME="/storage/.config/emuelec/configs/xroar/gptk/${ROMBASE}.gptk"
GPTK_DEFAULT="/usr/config/emuelec/configs/xroar/gptk/xroar.gptk"

if [ -f "$GPTK_GAME" ]; then
    GPTK_CONFIG="$GPTK_GAME"
else
    GPTK_CONFIG="$GPTK_DEFAULT"
fi

# Pause EmulationStation
kill -SIGSTOP $(pgrep emulationstation) 2>/dev/null

# Start gptokeyb
gptokeyb 1 xroar -c "$GPTK_CONFIG" &

sleep 1

# Launch XRoar
LIBGL_NOTEST=1 /usr/bin/xroar -fs \
  -rompath /storage/roms/bios:/storage/roms/bios/xroar \
  -default-machine "$MACHINE" \
  ${LOAD_FLAG} "$ROM" \
  ${TYPE_PARAM}

# Resume EmulationStation
kill -SIGCONT $(pgrep emulationstation) 2>/dev/null

# Cleanup
killall -9 gptokeyb 2>/dev/null

if [ "$CLEANUP_TMPDIR" = "1" ]; then
  rm -rf "$TMPDIR"
fi