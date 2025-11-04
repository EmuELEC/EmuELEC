# /emuelec/bin/connectbtwii.sh
#!/bin/sh
# Wiimote connect for EmuELEC (bluetoothctl-only, multi-scan with re-arm prompts)
# Copyright (C) 2025 worstcase_scenario (https://github.com/worstcase-scenario)

. /etc/profile
BTCTL="$(command -v bluetoothctl || echo /usr/bin/bluetoothctl)"

# Tunables
SCAN_TIMEOUT="${SCAN_TIMEOUT:-25}"     # seconds per scan round
SCAN_ROUNDS="${SCAN_ROUNDS:-4}"        # how many scan rounds
REARM_PROMPT="${REARM_PROMPT:-1}"      # prompt to press 1+2 before next round
REARM_PAUSE="${REARM_PAUSE:-3}"        # seconds to wait after prompt
CONNECT_TRIES="${CONNECT_TRIES:-30}"   # connect attempts while scan is ON
SLEEP_STEP=1

log(){ printf '%s\n' "$*" >&2; }

# Prep
/usr/bin/systemctl stop eventlircd 2>/dev/null || true
modprobe uhid 2>/dev/null || true
modprobe hid-wiimote 2>/dev/null || true
modprobe hid-nintendo 2>/dev/null || true
$BTCTL power on       >/dev/null 2>&1 || true
$BTCTL pairable on    >/dev/null 2>&1 || true
$BTCTL agent NoInputNoOutput >/dev/null 2>&1 || $BTCTL agent on >/dev/null 2>&1 || true
$BTCTL default-agent  >/dev/null 2>&1 || true

TMP="/tmp/btscan_$$.log"; rm -f "$TMP"

pick_mac_round() {
  # one scan round, append raw output to $TMP, return MAC or empty
  $BTCTL --timeout "$SCAN_TIMEOUT" scan on 2>&1 | tee -a "$TMP" >/dev/null
  awk 'BEGIN{IGNORECASE=1}
    /Device/ && /(nintendo|wiimote|rvl-cnt)/ {
      for (i=1;i<=NF;i++)
        if ($i ~ /^[0-9A-F]{2}(:[0-9A-F]{2}){5}$/) { print $i; exit }
    }' "$TMP" | head -n1
}

# Multi-scan with re-arm hints
MAC=""
round=1
while [ $round -le "$SCAN_ROUNDS" ] && [ -z "$MAC" ]; do
  if [ $round -eq 1 ]; then
    log "Scanning… hold 1+2 on the Wiimote (round $round/$SCAN_ROUNDS)"
  else
    [ "$REARM_PROMPT" = "1" ] && log "Press 1+2 again now… (round $round/$SCAN_ROUNDS)" && sleep "$REARM_PAUSE"
  fi
  MAC="$(pick_mac_round)"
  round=$((round+1))
done

[ -n "$MAC" ] || { log "No Wiimote seen by BlueZ."; rm -f "$TMP"; exit 1; }
log "Target: $MAC"

# Keep scan ON during connect attempts
$BTCTL scan on >/dev/null 2>&1 || true

# Clean stale state but keep object if BlueZ just learned it
$BTCTL disconnect "$MAC" >/dev/null 2>&1 || true

# Ensure BlueZ keeps the device object
for i in $(seq 1 10); do
  $BTCTL info "$MAC" >/dev/null 2>&1 || true
  $BTCTL devices | grep -qi "$MAC" && break
  sleep "$SLEEP_STEP"
done

# Connect loop
$BTCTL trust "$MAC" >/dev/null 2>&1 || true
ok=1
for i in $(seq 1 "$CONNECT_TRIES"); do
  $BTCTL connect "$MAC" >/dev/null 2>&1 || true
  sleep "$SLEEP_STEP"
  if $BTCTL info "$MAC" | grep -q "Connected: yes"; then ok=0; break; fi
done

$BTCTL scan off >/dev/null 2>&1 || true

if [ $ok -ne 0 ]; then
  log "Connect failed."
  [ -s "$TMP" ] && { log "Scan summary:"; grep -E 'Device|(\[NEW\])' "$TMP" | tail -n 20 >&2; }
  rm -f "$TMP"
  exit 1
fi

# Finalize
$BTCTL pair  "$MAC" >/dev/null 2>&1 || true
$BTCTL trust "$MAC" >/dev/null 2>&1 || true
$BTCTL info "$MAC" | sed -n '1,60p'
rm -f "$TMP"
log "Wiimote connected."
exit 0
