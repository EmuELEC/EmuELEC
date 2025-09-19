#!/bin/bash
# Bluetooth connect: ES overlays, audio devices only
set -euo pipefail
. /etc/profile

LOG="/tmp/btconnect.log"
RESTART=1
[ "${NO_ES_RESTART:-}" = "1" ] && RESTART=0
if [ "${1:-}" = "--no-restart" ]; then RESTART=0; shift; fi

overlay_yes() {
  ee_console disable
  text_viewer -y -w -t "$1" -f 24 -m "$2"
  rc=$?; rm -f /tmp/display
  [ "$rc" -eq 21 ] || [ "$rc" -eq 0 ]
}
overlay_msg() { ee_console disable; text_viewer -w -t "$1" -f 24 -m "$2"; rm -f /tmp/display; }
overlay_err() { ee_console disable; text_viewer -e -w -t "$1" -f 24 -m "$2"; rm -f /tmp/display; }

is_audio_mac() {
  local mac="$1" info
  info="$(bluetoothctl info "$mac" 2>/dev/null || true)"
  echo "$info" | grep -qiE 'Icon:\s*audio-' && return 0
  echo "$info" | grep -qiE 'UUID.*(A2DP|Audio Sink|Headset|Handsfree)' && return 0
  return 1
}

run_connect() {
  local MAC_IN="${1:-}"
  [ -z "$MAC_IN" ] && [ -f /storage/.config/btaudio.last ] && MAC_IN="$(cat /storage/.config/btaudio.last)"
  [ -z "$MAC_IN" ] && { overlay_err "MISSING" "Usage: btconnect.sh [--no-restart] AA:BB:CC:DD:EE:FF"; exit 1; }

  local BTMAC BTID CARD SINK
  BTMAC="$(echo "$MAC_IN" | tr '[:lower:]' '[:upper:]')"
  is_audio_mac "$BTMAC" || { overlay_err "CANCEL" "Not an audio device."; exit 2; }
  BTID="${BTMAC//:/_}"
  CARD="bluez_card.$BTID"

  pgrep -f "pulseaudio.*--system" >/dev/null || {
    pulseaudio --system --disallow-exit --disable-shm --log-level=error &>>"$LOG" &
    sleep 2
  }

  if ! bluetoothctl info "$BTMAC" 2>/dev/null | grep -q "Paired: yes"; then
    bluetoothctl power on >>"$LOG" 2>&1 || true
    bluetoothctl pairable on >>"$LOG" 2>&1 || true
    bluetoothctl pair  "$BTMAC" >>"$LOG" 2>&1 || true
    bluetoothctl trust "$BTMAC" >>"$LOG" 2>&1 || true
  else
    bluetoothctl trust "$BTMAC" >>"$LOG" 2>&1 || true
  fi

  local connected=0
  for i in {1..6}; do
    bluetoothctl connect "$BTMAC" >>"$LOG" 2>&1 || true
    bluetoothctl info "$BTMAC" 2>/dev/null | grep -q "Connected: yes" && { connected=1; break; }
    sleep 2
  done
  [ "$connected" -eq 1 ] || { overlay_err "ERROR" "Connect failed. See $LOG"; exit 1; }

  for _ in {1..12}; do pactl list cards short | grep -q "$CARD" && break; sleep 1; done
  pactl set-card-profile "$CARD" a2dp_sink >/dev/null 2>&1 || true

  SINK=""
  for _ in {1..12}; do
    SINK=$(pactl list short sinks | awk '{print $2}' | grep -E "bluez_sink\.${BTID}(\.a2dp_sink)?") || true
    [ -n "$SINK" ] && break; sleep 1
  done
  [ -n "$SINK" ] || { overlay_err "ERROR" "No A2DP sink found."; exit 1; }

  pactl set-default-sink "$SINK" >/dev/null 2>&1 || true
  pactl set-sink-mute   "$SINK" 0   >/dev/null 2>&1 || true
  pactl set-sink-volume "$SINK" 100% >/dev/null 2>&1 || true
  for id in $(pactl list short sink-inputs | awk '{print $1}'); do pactl move-sink-input "$id" "$SINK" >/dev/null 2>&1 || true; done
  pactl list modules short | grep -q module-switch-on-connect || pactl load-module module-switch-on-connect >/dev/null 2>&1 || true

  echo "$BTMAC" > /storage/.config/btaudio.last
  overlay_msg "STATUS" "Active sink: $SINK\n"

  [ "$RESTART" -eq 1 ] && systemctl restart emustation
}

if overlay_yes "CONNECT LAST BLUETOOTH AUDIO DEVICE" "Audio devices only. A2DP enforced.\n\n\n[YES]=Continue and exit to Emulationstation\n\n\n[No]=Cancel"; then
  run_connect "${1:-}"
fi
