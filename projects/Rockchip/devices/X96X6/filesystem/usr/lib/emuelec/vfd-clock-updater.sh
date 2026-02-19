#!/bin/sh
# VFD Clock Updater for X96X6
# Sends clock updates to VFD service via FIFO at minute boundaries.
#
# Behavior:
# - Before NTP sync: do not send anything (service keeps ----)
# - On first sync: send clock_start HH MM (forces clock mode)
# - After sync: send clock HH MM every minute

FIFO="/tmp/vfd.fifo"

# Wait for FIFO
while [ ! -p "$FIFO" ]; do
    sleep 0.5
done

SYNCED=0
FAST_TICKS=0
LAST_MIN=""

while true; do
    # Check sync state once per second until synced
    if [ "$SYNCED" = 0 ]; then
        YEAR=$(date +%Y 2>/dev/null || echo 1970)
        if ip route 2>/dev/null | grep -q '^default' && [ "$YEAR" -ge 2025 ]; then
            SYNCED=1
            FAST_TICKS=24
            echo "clock_start $(date +%H) $(date +%M)" > "$FIFO"
            continue
        fi
        sleep 1
        continue
    fi

    # First ~2 minutes after sync: refresh every 5s to quickly converge
    if [ "$FAST_TICKS" -gt 0 ]; then
        echo "clock_start $(date +%H) $(date +%M)" > "$FIFO"
        FAST_TICKS=$((FAST_TICKS - 1))
        sleep 5
        continue
    fi

    # Synced: update exactly when minute changes
    CUR_MIN=$(date +%M)
    if [ "$CUR_MIN" != "$LAST_MIN" ]; then
        echo "clock_start $(date +%H) $CUR_MIN" > "$FIFO"
        LAST_MIN="$CUR_MIN"
    fi

    # Poll faster around second 58-01 for near-instant minute rollover update,
    # otherwise keep low CPU usage.
    CUR_SEC=$(date +%S)
    CUR_SEC=${CUR_SEC#0}
    [ -z "$CUR_SEC" ] && CUR_SEC=0
    if [ "$CUR_SEC" -ge 58 ] || [ "$CUR_SEC" -le 1 ]; then
        sleep 0.2
    else
        sleep 1
    fi
done
