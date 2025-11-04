#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile


[ -n "$1" ] || exit 1
IN="$1"

# Resolution -> "-z WxH,32"
MODE="$(get_resolution 2>/dev/null || echo '640 480')"
case "$MODE" in
  *x*) W="${MODE%x*}"; H="${MODE#*x}";;
  *) set -- $MODE; W="$1"; H="$2";;
esac
case "$W" in *[!0-9]*|'') W=640;; esac
case "$H" in *[!0-9]*|'') H=480;; esac
[ "$W" -lt 320 ] 2>/dev/null && W=640
[ "$H" -lt 200 ] 2>/dev/null && H=480
RES="${W}x${H},32"

# ZIP -> pick first valid cart
TMP=""
trap '[ -n "$TMP" ] && rm -rf "$TMP"' EXIT
ROM="$IN"
case "$IN" in
  *.zip|*.ZIP|*.Zip)
    TMP="$(mktemp -d)"
    if command -v unzip >/dev/null 2>&1; then
      unzip -o -qq "$IN" -d "$TMP"
    elif command -v bsdtar >/dev/null 2>&1; then
      bsdtar -xf "$IN" -C "$TMP"
    else
      echo "Need unzip or bsdtar" >&2
      exit 1
    fi
    ROM="$(find "$TMP" -type f \( -iname '*.cfg' -o -iname '*.rom' -o -iname '*.cc3' -o -iname '*.bin' -o -iname '*.int' -o -iname '*.itv' \) | head -n1)"
    [ -n "$ROM" ] || { echo "No cart file in ZIP" >&2; exit 1; }
    ;;
esac

# Optional keyboard hack
KBD="/emuelec/configs/jzintv_keyb.hack"
[ -f "$KBD" ] && KBD_OPT="--kbdhackfile $KBD" || KBD_OPT=""

exec jzintv -f1 -z "$RES" -p /storage/roms/bios/ "$ROM" $KBD_OPT
