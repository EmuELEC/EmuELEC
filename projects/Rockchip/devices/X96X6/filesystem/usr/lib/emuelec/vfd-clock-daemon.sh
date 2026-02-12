#!/bin/sh
# VFD Clock and Status Daemon for X96X6
#
# Controls the FD628 front-panel display:
#   - "Init" text during first boot filesystem resize
#   - Boot animation before and during EmulationStation load
#   - Clock display (HH:MM with colon) after ES is ready
#   - Dashes (--:--) until NTP sync
#   - Automatic status icons: wifi, data, usb, card
#   - External icon control via /tmp/vfd-icon-cmd

. /usr/lib/emuelec/vfd-fd628.sh
vfd_init
vfd_brightness 7

# Graceful shutdown: show BYE and exit
trap '/usr/lib/emuelec/vfd-bye.sh; exit 0' TERM INT

# ─── Phase 1: Init display during first boot resize ──────────────────
# fs-resize deletes .please_resize_me BEFORE actual resize, then reboots.
# We create our own marker, show "Init", and sleep forever — reboot kills us.
if [ -f /storage/.please_resize_me ]; then
    touch /storage/.vfd-first-boot
    vfd_text "Init"
    while true; do sleep 60; done
    # Never reached — fs-resize does reboot -f
fi

# ─── Helper functions ─────────────────────────────────────────────────
ANIM_PID=""

start_anim() {
    [ -n "$ANIM_PID" ] && kill -0 "$ANIM_PID" 2>/dev/null && return
    /usr/lib/emuelec/vfd-boot-anim.sh &
    ANIM_PID=$!
}

stop_anim() {
    if [ -n "$ANIM_PID" ]; then
        kill "$ANIM_PID" 2>/dev/null
        wait "$ANIM_PID" 2>/dev/null
        ANIM_PID=""
    fi
}

is_anim_running() {
    [ -n "$ANIM_PID" ] && kill -0 "$ANIM_PID" 2>/dev/null
}

# ─── Phase 2: Post-resize → "Init" stays until ES appears ────────────
# First boot after resize: show "Init" the entire time until ES starts,
# then brief "boot" text, then animation until ES is fully loaded
if [ -f /storage/.vfd-first-boot ]; then
    vfd_text "Init"
    while ! pgrep -x emulationstation >/dev/null 2>&1; do
        sleep 1
    done
    rm -f /storage/.vfd-first-boot
    # ES process appeared → brief "boot" text then animation
    vfd_text "boot"
    sleep 1
fi

# ─── Pre-warm timezone cache in background ────────────────────────────
# Generates alphabetically sorted timezone list for instant System Settings access.
if [ ! -f /tmp/.tz_sorted ]; then
(
    grep -v "^#" /usr/share/zoneinfo/zone1970.tab 2>/dev/null | awk 'NF>=3{print $3}' | sort -u | tr '\n' ',' > "/tmp/.tz_sorted.tmp" \
        && mv "/tmp/.tz_sorted.tmp" "/tmp/.tz_sorted"
) &
fi

# ─── Boot Animation: show "boot" on cold boot, then animate until ES ready ─
# On cold boot: show "boot" briefly, then animation
# On daemon restart while ES running: just brief animation
if ! pgrep -x emulationstation >/dev/null 2>&1; then
    vfd_text "boot"
    sleep 1
fi

start_anim

# Wait for ES to appear (up to 90 seconds)
WAIT=0
while ! pgrep -x emulationstation >/dev/null 2>&1 && [ "$WAIT" -lt 90 ]; do
    sleep 1
    WAIT=$((WAIT + 1))
done

# Let ES fully initialize its display
sleep 3
stop_anim

# ─── Main Loop: clock, icons, state tracking ─────────────────────────
VFD_CMD_FILE="/tmp/vfd-icon-cmd"
TICK=0
ICON_WIFI=1
ICON_USB=0
ICON_CARD=0
ICON_DATA=0
ICON_APPS=0
ICON_SETUP=0
ICON_COLON=0

FIRST_BOOT=1
[ -f /storage/.cache/.time_synced ] && FIRST_BOOT=0

TZ_DETECT_DONE=0
[ -f /storage/.cache/.timezone_autodetected ] && TZ_DETECT_DONE=1

rm -f "$VFD_CMD_FILE"

# State tracking for animation triggers
ES_PREV=1        # ES was just running (we waited for it above)
GAME_PREV=0
GAME_LOAD_TICK=0

# If a game is already running (e.g. daemon restarted mid-game), track it
for proc in retroarch duckstation-nogui advmame fbneo; do
    pgrep -x "$proc" >/dev/null 2>&1 && GAME_PREV=1 && break
done

# Polling every 1 second for responsive state detection
# Display updates every 5 seconds (clock accuracy ±5s)
# Icon auto-detection every 30 seconds
while true; do

    # ─── State Detection (every second) ───────────────────────
    ES_NOW=$(pgrep -x emulationstation >/dev/null 2>&1 && echo 1 || echo 0)

    GAME_NOW=0
    for proc in retroarch duckstation-nogui advmame fbneo; do
        pgrep -x "$proc" >/dev/null 2>&1 && GAME_NOW=1 && break
    done

    # ES just died (restart or shutdown) → animation (no "boot" text)
    if [ "$ES_NOW" = 0 ] && [ "$ES_PREV" = 1 ] && [ "$GAME_NOW" = 0 ]; then
        start_anim
    fi

    # ES just came back → let it settle, then stop animation
    if [ "$ES_NOW" = 1 ] && [ "$ES_PREV" = 0 ]; then
        sleep 2
        stop_anim
    fi

    # Game just launched → loading animation
    if [ "$GAME_NOW" = 1 ] && [ "$GAME_PREV" = 0 ]; then
        start_anim
        GAME_LOAD_TICK=0
    fi

    # Game loaded (~8 seconds) → stop loading animation, show clock
    if [ "$GAME_NOW" = 1 ] && is_anim_running; then
        GAME_LOAD_TICK=$((GAME_LOAD_TICK + 1))
        if [ "$GAME_LOAD_TICK" -ge 8 ]; then
            stop_anim
        fi
    fi

    # Game just exited → animate if ES not running yet (ES restarting)
    if [ "$GAME_NOW" = 0 ] && [ "$GAME_PREV" = 1 ]; then
        [ "$ES_NOW" = 0 ] && start_anim
    fi

    ES_PREV=$ES_NOW
    GAME_PREV=$GAME_NOW

    # ─── Display Update (every 5s, skip while animation runs) ─
    if ! is_anim_running && [ $((TICK % 5)) -eq 0 ]; then

        # Process external icon commands
        if [ -f "$VFD_CMD_FILE" ]; then
            while IFS=' ' read -r icon state; do
                case "$icon" in
                    apps|app)   [ "$state" = "on" ] && ICON_APPS=1 || ICON_APPS=0 ;;
                    setup)      [ "$state" = "on" ] && ICON_SETUP=1 || ICON_SETUP=0 ;;
                    usb)        [ "$state" = "on" ] && ICON_USB=1 || ICON_USB=0 ;;
                    card)       [ "$state" = "on" ] && ICON_CARD=1 || ICON_CARD=0 ;;
                    colon)      [ "$state" = "on" ] && ICON_COLON=1 || ICON_COLON=0 ;;
                    wifi)       [ "$state" = "on" ] && ICON_WIFI=1 || ICON_WIFI=0 ;;
                    data)       [ "$state" = "on" ] && ICON_DATA=1 || ICON_DATA=0 ;;
                esac
            done < "$VFD_CMD_FILE"
            rm -f "$VFD_CMD_FILE"
        fi

        # Auto-detect icons (every 30 seconds)
        if [ $((TICK % 30)) -eq 0 ]; then
            if [ -d /sys/class/net/wlan0 ]; then
                WLAN_STATE=$(cat /sys/class/net/wlan0/operstate 2>/dev/null)
                [ "$WLAN_STATE" = "up" ] && ICON_WIFI=1 || { [ $TICK -gt 30 ] && ICON_WIFI=0; }
            fi
            ICON_USB=0
            for p in /sys/bus/usb/devices/[0-9]*-[0-9]*/product; do
                [ -f "$p" ] && ICON_USB=1 && break
            done
            ICON_CARD=0
            for mmc in /sys/class/block/mmcblk[0-9]; do
                [ -d "$mmc" ] && [ "$(cat ${mmc}/removable 2>/dev/null)" = "1" ] && ICON_CARD=1 && break
            done
        fi

        # Clock display
        if [ "$FIRST_BOOT" = 1 ]; then
            year=$(date +%Y 2>/dev/null || echo 1970)
            if [ "$year" -ge 2026 ]; then
                FIRST_BOOT=0
                touch /storage/.cache/.time_synced
                vfd_clock
            else
                ICON_COLON=1
                vfd_text "----"
            fi
        else
            vfd_clock
        fi
    fi

    # ─── Timezone auto-detect (every 60s, background) ─────────
    if [ "$TZ_DETECT_DONE" = 0 ] && [ $((TICK % 60)) -eq 0 ]; then
        if ip route 2>/dev/null | grep -q '^default'; then
            /usr/lib/emuelec/vfd-timezone-setup.sh &
            TZ_DETECT_DONE=1
        fi
    fi

    TICK=$((TICK + 1))
    sleep 1
done
