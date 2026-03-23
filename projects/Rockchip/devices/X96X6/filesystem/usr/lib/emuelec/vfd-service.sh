#!/bin/sh
# VFD Display Service for X96X6
# FIFO-based command processor — the ONLY process that writes to GPIO.

. /usr/lib/emuelec/vfd-fd628.sh

vfd_init
vfd_brightness 7

FIFO="/tmp/vfd.fifo"
ANIM_PID=""
CLOCK_PID=""
MONITOR_PID=""
TEXT_LOCK=0

cleanup() {
    trap - TERM INT

    # Close FIFO fd first so /tmp can unmount cleanly
    exec 3>&- 2>/dev/null

    [ -n "$ANIM_PID" ] && kill "$ANIM_PID" 2>/dev/null
    [ -n "$CLOCK_PID" ] && kill "$CLOCK_PID" 2>/dev/null
    [ -n "$MONITOR_PID" ] && kill "$MONITOR_PID" 2>/dev/null
    sleep 0.2
    wait 2>/dev/null

    echo 1 > "/sys/class/gpio/gpio${VFD_STB}/value" 2>/dev/null
    echo 1 > "/sys/class/gpio/gpio${VFD_CLK}/value" 2>/dev/null

    /usr/lib/emuelec/vfd-bye.sh

    rm -f "$FIFO" /tmp/.tz_sorted /tmp/.tz_sorted.tmp 2>/dev/null
    rmdir /tmp/.tz_detect.lock 2>/dev/null

    exit 0
}
trap cleanup TERM INT

# Phase 1: fs resize first boot
if [ -f /storage/.please_resize_me ]; then
    touch /storage/.vfd-first-boot
    vfd_text "Init"
    while true; do sleep 60; done
fi

# Phase 2: after resize reboot (non-blocking)
if [ -f /storage/.vfd-first-boot ]; then
    vfd_text "Init"
    TEXT_LOCK=1
    # Marker is only for this boot phase; remove now to avoid repeats
    rm -f /storage/.vfd-first-boot
else
    vfd_text "boot"
    TEXT_LOCK=1
fi

# Pre-warm timezone list
if [ ! -f /tmp/.tz_sorted ]; then
    (
        grep -v "^#" /usr/share/zoneinfo/zone1970.tab 2>/dev/null \
            | awk 'NF>=3{print $3}' | sort -u | tr '\n' ',' \
            > /tmp/.tz_sorted.tmp && mv /tmp/.tz_sorted.tmp /tmp/.tz_sorted
    ) &
fi

rm -f "$FIFO"
mkfifo "$FIFO"
chmod 666 "$FIFO"
exec 3<>"$FIFO"

/usr/lib/emuelec/vfd-clock-updater.sh &
CLOCK_PID=$!
/usr/lib/emuelec/vfd-state-monitor.sh &
MONITOR_PID=$!

# Timeout read loop allows TERM handling during shutdown
while true; do
    if ! IFS=' ' read -r -t 1 cmd arg1 arg2 <&3 2>/dev/null; then
        continue
    fi
    [ -z "$cmd" ] && continue

    if [ -n "$ANIM_PID" ] && ! kill -0 "$ANIM_PID" 2>/dev/null; then
        wait "$ANIM_PID" 2>/dev/null
        ANIM_PID=""
    fi

    case "$cmd" in
        text)
            [ -n "$ANIM_PID" ] && continue
            TEXT_LOCK=1
            ICON_COLON=0
            vfd_text "$arg1"
            ;;

        clock)
            [ -n "$ANIM_PID" ] && continue
            [ "$TEXT_LOCK" = 1 ] && continue
            ICON_COLON=1
            if [ -n "$arg1" ] && [ -n "$arg2" ]; then
                vfd_clock "$arg1" "$arg2"
            else
                vfd_clock
            fi
            ;;

        clock_start)
            [ -n "$ANIM_PID" ] && continue
            TEXT_LOCK=0
            ICON_COLON=1
            if [ -n "$arg1" ] && [ -n "$arg2" ]; then
                vfd_clock "$arg1" "$arg2"
            else
                vfd_clock
            fi
            ;;

        icon)
            case "$arg1" in
                apps|app) [ "$arg2" = "on" ] && ICON_APPS=1 || ICON_APPS=0 ;;
                setup)    [ "$arg2" = "on" ] && ICON_SETUP=1 || ICON_SETUP=0 ;;
                usb)      [ "$arg2" = "on" ] && ICON_USB=1 || ICON_USB=0 ;;
                card)     [ "$arg2" = "on" ] && ICON_CARD=1 || ICON_CARD=0 ;;
                colon)    [ "$arg2" = "on" ] && ICON_COLON=1 || ICON_COLON=0 ;;
                wifi)     [ "$arg2" = "on" ] && ICON_WIFI=1 || ICON_WIFI=0 ;;
                data)     [ "$arg2" = "on" ] && ICON_DATA=1 || ICON_DATA=0 ;;
            esac
            [ -n "$ANIM_PID" ] && continue
            vfd_display_segments $LAST_SEG_A $LAST_SEG_B $LAST_SEG_C $LAST_SEG_D \
                                 $LAST_SEG_E $LAST_SEG_F $LAST_SEG_G
            ;;

        anim)
            case "$arg1" in
                start)
                    if [ -z "$ANIM_PID" ] || ! kill -0 "$ANIM_PID" 2>/dev/null; then
                        /usr/lib/emuelec/vfd-boot-anim.sh &
                        ANIM_PID=$!
                    fi
                    ;;
                stop)
                    if [ -n "$ANIM_PID" ]; then
                        kill "$ANIM_PID" 2>/dev/null
                        ANIM_PID=""
                        echo 1 > "/sys/class/gpio/gpio${VFD_STB}/value" 2>/dev/null
                        echo 1 > "/sys/class/gpio/gpio${VFD_CLK}/value" 2>/dev/null
                    fi
                    # Do not re-lock clock mode here.
                    # If still locked from boot phase, keep placeholder;
                    # otherwise immediately restore clock display.
                    ICON_COLON=1
                    if [ "$TEXT_LOCK" = 1 ]; then
                        vfd_text "----"
                    else
                        vfd_clock
                    fi
                    ;;
            esac
            ;;

        brightness)
            vfd_brightness "${arg1:-7}"
            ;;

        clear)
            if [ -n "$ANIM_PID" ]; then
                kill "$ANIM_PID" 2>/dev/null
                wait "$ANIM_PID" 2>/dev/null
                ANIM_PID=""
            fi
            TEXT_LOCK=0
            vfd_clear
            ;;

        bye)
            cleanup
            ;;
    esac
done
