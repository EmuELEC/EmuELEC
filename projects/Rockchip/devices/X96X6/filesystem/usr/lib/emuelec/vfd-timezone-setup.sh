#!/bin/sh
# Auto-detect and set timezone based on IP geolocation (runs once ever)

MARKER="/storage/.cache/.timezone_autodetected"
[ -f "$MARKER" ] && exit 0

# Detect timezone via ip-api.com (plain text = no JSON parsing needed)
# Short timeout to avoid blocking boot
TZ=$(curl -s --connect-timeout 3 --max-time 5 "http://ip-api.com/line/?fields=timezone" 2>/dev/null)

# Trim whitespace
TZ=$(echo "$TZ" | tr -d '\r\n ')

[ -z "$TZ" ] && exit 1
[ ! -f "/usr/share/zoneinfo/$TZ" ] && exit 1

# Apply immediately (fast — just a symlink)
ln -sf "/usr/share/zoneinfo/$TZ" /var/run/localtime

# Persist in emuelec.conf
EE_CONF="/storage/.config/emuelec/configs/emuelec.conf"
if [ -f "$EE_CONF" ]; then
    sed -i "s|^system.timezone=.*|system.timezone=$TZ|" "$EE_CONF"
fi

# Also write for tz-data.service
echo "TIMEZONE=$TZ" > /storage/.cache/timezone

# Mark as done
touch "$MARKER"
