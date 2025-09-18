#!/bin/bash
# ES Bluetooth setup (audio devices only) with Yes/Exit selection
set -euo pipefail
. /etc/profile

LOG="/tmp/btsetup.log"

ee_console enable
cleanup() {
  ee_console disable
  rm -f /tmp/display
  [ -n "${BTCTL_PID:-}" ] && kill "$BTCTL_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ask_yes() {
  text_viewer -y -w -t "$1" -f 24 -m "$2"
  rc=$?
  case "$rc" in
    21)   # A button
      return 0   # Yes
      ;;
    0)    # B button
      return 1   # No/Exit
      ;;
    *)
      return 1   # any other keys treated as No
      ;;
  esac
}

ensure_pa() {
  pgrep -f "pulseaudio.*--system" >/dev/null || {
    pulseaudio --system --disallow-exit --disable-shm --log-level=error &>>"$LOG" &
    sleep 2
  }
}

# Persistent bluetoothctl session for stable pairing
coproc BTCTL { bluetoothctl >>"$LOG" 2>&1; }
BTFD="${BTCTL[1]}"     # write fd

bt() { printf '%s\n' "$*" >&"$BTFD"; }

bt_init() {
  bt "power on"
  bt "pairable on"
  bt "agent NoInputNoOutput"
  bt "default-agent"
}

scan_start() { bt "scan on"; }
scan_stop()  { bt "scan off"; }

is_audio_mac() {
  local mac="$1" info
  info="$(bluetoothctl info "$mac" 2>/dev/null || true)"
  echo "$info" | grep -qiE 'Icon:\s*audio-' && return 0
  echo "$info" | grep -qiE 'UUID.*(A2DP|Audio Sink|Headset|Handsfree)' && return 0
  return 1
}

scan_audio_devices() {
  scan_start; sleep 10
  bluetoothctl devices \
    | awk '/^Device/ { mac=$2; $1=$2=""; sub(/^ /,""); print mac "|" $0 }' \
    | while IFS='|' read -r mac name; do
        [ -z "$mac" ] && continue
        is_audio_mac "$mac" && echo "${mac}|${name}"
      done
  scan_stop
}

pair_trust_connect() {
  local mac="$1"
  bluetoothctl info "$mac" >/dev/null 2>&1 || bt "remove $mac"

  if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
    bt "pair $mac"
    for i in {1..10}; do
      bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes" && break
      sleep 1
    done
  fi

  bt "trust $mac"
  scan_stop

  for i in {1..8}; do
    bt "connect $mac"
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && return 0
    sleep 2
  done

  # Fallback: re-pair
  bt "remove $mac"; sleep 1
  bt "pair $mac"; sleep 2
  bt "trust $mac"
  for i in {1..6}; do
    bt "connect $mac"
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && return 0
    sleep 2
  done

  return 1
}

main() {
  ensure_pa
  bt_init

  ask_yes "BLUETOOTH SETUP" \
    "Put the audio device in pairing mode, then press YES to start scan.\n\nBe patient until the scan is done, it takes some seconds.\n\n\n[Yes]=Scan         [No]=Exit" || return 0

  while true; do
    mapfile -t DEVLIST < <(scan_audio_devices)

    if [ ${#DEVLIST[@]} -eq 0 ]; then
      ask_yes "NO AUDIO DEVICES" \
        "Nothing found.\n\n[Yes]=Scan again   [No]=Exit" \
        && continue || return 1
    fi

    LAST_MAC=""

    for entry in "${DEVLIST[@]}"; do
      mac="${entry%%|*}"
      name="${entry#*|}"

      if ask_yes "AUDIO DEVICE" \
          "Name: ${name}\nMAC: ${mac}\n\n[Yes]=Connect   [No]=Cancel"; then

        if pair_trust_connect "$mac"; then
          echo "$mac" > /storage/.config/btaudio.last
          LAST_MAC="$mac"
          text_viewer -w -t "SUCCESS" -f 24 -m "Connected: ${name}"
        else
          text_viewer -w -t "ERROR" -f 24 -m "Pair/connect failed."
        fi

        break   # stop after first attempt
      else
        break 2 # B button: abort entire scan cycle
      fi
    done

    ask_yes "CONNECTION COMPLETED" \
      "Scan again (YES) or exit to Emulationstation (NO)?\n" \
      && continue || break
  done

  
}

main
