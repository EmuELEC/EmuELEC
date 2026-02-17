#!/bin/sh
# VFD State Monitor for X96X6
# Monitors ES/game state and icon status, sends commands to FIFO.

FIFO="/tmp/vfd.fifo"

while [ ! -p "$FIFO" ]; do
    sleep 0.5
done

ES_PREV=0
GAME_PREV=0
GAME_LOAD_TICK=""
TICK=0

pgrep -x emulationstation >/dev/null 2>&1 && ES_PREV=1
for proc in retroarch duckstation-nogui advmame fbneo; do
    pgrep -x "$proc" >/dev/null 2>&1 && GAME_PREV=1 && break
done

TZ_DETECT_DONE=0
[ -f /storage/.cache/.timezone_autodetected ] && TZ_DETECT_DONE=1

NET_PREV=0

while true; do
    ES_NOW=0
    pgrep -x emulationstation >/dev/null 2>&1 && ES_NOW=1

    GAME_NOW=0
    for proc in retroarch duckstation-nogui advmame fbneo; do
        pgrep -x "$proc" >/dev/null 2>&1 && GAME_NOW=1 && break
    done

    # ES restart/shutdown transition
    if [ "$ES_NOW" = 0 ] && [ "$ES_PREV" = 1 ] && [ "$GAME_NOW" = 0 ]; then
        echo "anim start" > "$FIFO"
    fi

    # ES started
    if [ "$ES_NOW" = 1 ] && [ "$ES_PREV" = 0 ]; then
        ( sleep 2; echo "anim stop" > "$FIFO" ) &
    fi

    # Game launched
    if [ "$GAME_NOW" = 1 ] && [ "$GAME_PREV" = 0 ]; then
        echo "anim start" > "$FIFO"
        GAME_LOAD_TICK=0
    fi

    # Game loading timeout
    if [ "$GAME_NOW" = 1 ] && [ -n "$GAME_LOAD_TICK" ]; then
        GAME_LOAD_TICK=$((GAME_LOAD_TICK + 1))
        if [ "$GAME_LOAD_TICK" -ge 4 ]; then
            echo "anim stop" > "$FIFO"
            GAME_LOAD_TICK=""
        fi
    fi

    # Game exited, ES still absent
    if [ "$GAME_NOW" = 0 ] && [ "$GAME_PREV" = 1 ]; then
        [ "$ES_NOW" = 0 ] && echo "anim start" > "$FIFO"
        GAME_LOAD_TICK=""
    fi

    ES_PREV=$ES_NOW
    GAME_PREV=$GAME_NOW

    # Icon detection each 30s
    if [ $((TICK % 15)) -eq 0 ]; then
        # WiFi icon ON only with active wifi connection:
        # 1) interface exists
        # 2) operstate up
        # 3) carrier present
        # 4) has IPv4 address
        WIFI_ON=0
        if [ -d /sys/class/net/wlan0 ]; then
            WSTATE=$(cat /sys/class/net/wlan0/operstate 2>/dev/null)
            WCARRIER=$(cat /sys/class/net/wlan0/carrier 2>/dev/null)
            if [ "$WSTATE" = "up" ] && [ "$WCARRIER" = "1" ]; then
                ip -4 addr show dev wlan0 2>/dev/null | grep -q "inet " && WIFI_ON=1
            fi
        fi
        [ "$WIFI_ON" = 1 ] && echo "icon wifi on" > "$FIFO" || echo "icon wifi off" > "$FIFO"

        USB_FOUND=0
        for p in /sys/bus/usb/devices/[0-9]*-[0-9]*/product; do
            [ -f "$p" ] && USB_FOUND=1 && break
        done
        [ "$USB_FOUND" = 1 ] && echo "icon usb on" > "$FIFO" || echo "icon usb off" > "$FIFO"

        CARD_FOUND=0
        for mmc in /sys/class/block/mmcblk[0-9]; do
            [ -d "$mmc" ] && [ "$(cat "${mmc}/removable" 2>/dev/null)" = "1" ] && CARD_FOUND=1 && break
        done
        [ "$CARD_FOUND" = 1 ] && echo "icon card on" > "$FIFO" || echo "icon card off" > "$FIFO"
    fi

    # Data icon every 2s: traffic > 1KB/2s
    NET_NOW=0
    for stats in /sys/class/net/*/statistics; do
        IFACE=$(basename "$(dirname "$stats")")
        [ "$IFACE" = "lo" ] && continue
        RX=$(cat "$stats/rx_bytes" 2>/dev/null || echo 0)
        TX=$(cat "$stats/tx_bytes" 2>/dev/null || echo 0)
        NET_NOW=$((NET_NOW + RX + TX))
    done

    if [ "$NET_PREV" -gt 0 ]; then
        NET_DIFF=$((NET_NOW - NET_PREV))
        [ "$NET_DIFF" -lt 0 ] && NET_DIFF=0
        if [ "$NET_DIFF" -gt 1024 ]; then
            echo "icon data on" > "$FIFO"
        else
            echo "icon data off" > "$FIFO"
        fi
    fi
    NET_PREV=$NET_NOW

    # Timezone auto-detect once, when default route exists
    if [ "$TZ_DETECT_DONE" = 0 ] && [ $((TICK % 30)) -eq 0 ]; then
        if ip route 2>/dev/null | grep -q '^default'; then
            /usr/lib/emuelec/vfd-timezone-setup.sh >/dev/null 2>&1 &
            TZ_DETECT_DONE=1
        fi
    fi

    TICK=$((TICK + 1))
    sleep 2
done
