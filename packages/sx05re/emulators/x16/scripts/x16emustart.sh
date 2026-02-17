#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Wrapper-script for X16emu
# Copyright (C) 2025-present worstcase_scenario (https://github.com/worstcase-scenario)

SYSTEM_ROM="/usr/share/x16-emulator/rom.bin"
USER_ROM="/storage/roms/x16/rom.bin"
EMU_BIN="/usr/bin/x16emu"

if [ -f "${USER_ROM}" ]; then
  ROM="${USER_ROM}"
elif [ -f "${SYSTEM_ROM}" ]; then
  ROM="${SYSTEM_ROM}"
else
  echo "ERROR: No rom.bin found!"
  exit 1
fi

ARGS=(-rom "${ROM}" -fullscreen -quality best -scale 2 -joy1 -joy2 -joy3 -joy4)

if [ -n "$1" ]; then
  FILE="$1"
  EXT="${FILE##*.}"

  case "${EXT,,}" in
    prg|bas)
      GAME_DIR="$(dirname -- "${FILE}")"
      GAME_BASE="$(basename -- "${FILE}")"
      cd "${GAME_DIR}" || exit 1
      ;;
  esac

  case "${EXT,,}" in
    prg)
      ARGS+=(-prg "${GAME_BASE}" -run)
      ;;
    bas)
      ARGS+=(-bas "${GAME_BASE}" -run)
      ;;
    img)
      ARGS+=(-sdcard "${FILE}")
      ;;
    crt)
      ARGS+=(-cart "${FILE}")
      ;;
  esac
fi

exec "${EMU_BIN}" "${ARGS[@]}"
