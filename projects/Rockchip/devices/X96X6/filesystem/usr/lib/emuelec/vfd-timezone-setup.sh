#!/bin/sh
# Auto-detect and set timezone based on IP geolocation.
# Called in background by state monitor. Must be fast and non-blocking.

MARKER="/storage/.cache/.timezone_autodetected"
LOCKDIR="/tmp/.tz_detect.lock"

[ -f "$MARKER" ] && exit 0

if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi

TZ=$(timeout 1 curl -s --connect-timeout 1 --max-time 1 "http://ip-api.com/line/?fields=timezone" 2>/dev/null)
TZ=$(echo "$TZ" | tr -d '\r\n ')

rmdir "$LOCKDIR" 2>/dev/null

[ -z "$TZ" ] && exit 1
[ ! -f "/usr/share/zoneinfo/$TZ" ] && exit 1

ln -sf "/usr/share/zoneinfo/$TZ" /var/run/localtime 2>/dev/null

echo "TIMEZONE=$TZ" > /storage/.cache/timezone 2>/dev/null
systemctl restart tz-data.service >/dev/null 2>&1

EE_CONF="/storage/.config/emuelec/configs/emuelec.conf"
if [ -f "$EE_CONF" ]; then
    if grep -q '^system.timezone=' "$EE_CONF"; then
        sed -i "s|^system.timezone=.*|system.timezone=$TZ|" "$EE_CONF" 2>/dev/null
    else
        echo "system.timezone=$TZ" >> "$EE_CONF"
    fi
fi

touch "$MARKER" 2>/dev/null
