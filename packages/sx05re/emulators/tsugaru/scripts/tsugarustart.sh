#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present worstcase_scenario (https://github.com/worstcase-scenario)
. /etc/profile

ROM="$1"
BIOS="/storage/roms/bios/fmtowns"
[ -f "$BIOS/FMT_SYS.ROM" ] || BIOS="/storage/roms/bios"
LOG="/emuelec/logs/tsugaru.log"
BIN="/usr/bin/tsugaru"
mkdir -p /emuelec/logs
exec >> "$LOG" 2>&1
echo "=== $(date) tsugaru launch: $ROM"
# create uppercase ROM symlinks (Tsugaru needs UPPERCASE, MAME sets are lowercase)
for rom in FMT_SYS FMT_DOS FMT_FNT FMT_F20 FMT_DIC; do
    lower="$(echo "$rom" | tr 'A-Z' 'a-z')"
    if [ ! -e "$BIOS/$rom.ROM" ] && [ -f "$BIOS/$lower.rom" ]; then
        ln -sf "$lower.rom" "$BIOS/$rom.ROM"
        echo "bios: symlink $rom.ROM -> $lower.rom"
    fi
done
if [ ! -f "$BIOS/FMT_SYS.ROM" ]; then
    echo "ERROR: FM Towns BIOS not found in $BIOS"
    exit 1
fi
if [ ! -f "$ROM" ]; then
    echo "ERROR: ROM not found: $ROM"
    exit 1
fi
# --- media type by extension -------------------------------------------------
base="${ROM%.*}"
ext="$(echo "${ROM##*.}" | tr 'A-Z' 'a-z')"
case "$ext" in
    cue|iso|mds|ccd)  MEDIA="-CD" ;;
    d77|d88|hdm|xdf|bin) MEDIA="-FD0" ;;
    *)                MEDIA="-CD" ;;
esac
# --- per-game options: <rom>.opts ---------------------------------------------
EXTRA=""
[ -f "${base}.opts" ] && EXTRA="$(head -1 "${base}.opts")"

GAMEPORT0="KEY"

GPTK_DIR="/emuelec/configs/tsugaru/gptk"
mkdir -p "$GPTK_DIR"
if [ ! -f "$GPTK_DIR/tsugaru.gptk" ] && [ -f /usr/config/tsugaru/tsugaru.gptk ]; then
    cp /usr/config/tsugaru/tsugaru.gptk "$GPTK_DIR/tsugaru.gptk"
fi

GPTK="$GPTK_DIR/$(basename "$base").gptk"
[ -f "$GPTK" ] || GPTK="$GPTK_DIR/tsugaru.gptk"

GPTOKEYB_PID=""
if [ -f "$GPTK" ] && command -v gptokeyb >/dev/null; then
    gptokeyb "tsugaru_pad" -c "$GPTK" &
    GPTOKEYB_PID=$!
    sleep 0.3
    echo "gptk: $GPTK active (pid $GPTOKEYB_PID)"
else
    echo "WARNING: no gptk config found ($GPTK)"
fi

# --- run ----------------------------------------------------------------------
SDL_VIDEODRIVER=mali "$BIN" "$BIOS" \
    -FULLSCREEN -AUTOSCALE -CDSPEED 32 \
    -HIGHRES -MAXSNDDBLBUF -NODAMPERWIRELINE \
    -GAMEPORT0 "$GAMEPORT0" \
    $MEDIA "$ROM" $EXTRA < /dev/null
RC=$?

[ -n "$GPTOKEYB_PID" ] && kill "$GPTOKEYB_PID" 2>/dev/null

echo "=== tsugaru exited rc=$RC"
exit $RC