#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

. /etc/profile

# Paths / defaults
EKA_EXE="/usr/bin/eka2l1/eka2l1_sdl2"
EKA_CONFIG_DIR="/storage/.config/eka2l1"
EKA_DATA_DIR="${EKA_CONFIG_DIR}/data"
EKA_DRIVES_DIR="${EKA_DATA_DIR}/drives"
EKA_E_DIR="${EKA_DRIVES_DIR}/e"
EKA_GPTK="/storage/.config/emuelec/configs/eka2l1/gptk/eka.gptk"
EKA_LOG="/emuelec/logs/eka2l1.log"
EKA_DEVICE_CACHE="/storage/.config/emuelec/configs/eka2l1/device_cache"
DIALOG_GPTK="/storage/.config/emuelec/configs/eka2l1/gptk/dialog.gptk"
SELECTED_DEVICE_FILE="/tmp/eka_selected_device"

EKA_DEVICE_NGAGE1="${EKA_DEVICE_NGAGE1:-NEM-4}"
EKA_DEVICE_NGAGE1_ALT="${EKA_DEVICE_NGAGE1_ALT:-RH-29}"
EKA_DEVICE_NGAGE2="${EKA_DEVICE_NGAGE2:-RM-409}"

ROMFILE="$1"
LAUNCH_MODE="games"
APP_RUN=""
DEVICE_CODE=""
UID_DEVICE=""
CLASSIC_NGAGE=0
CLEANUP_DONE=0

mkdir -p "$(dirname "${EKA_LOG}")"
mkdir -p "$(dirname "${EKA_DEVICE_CACHE}")"
echo "EmuELEC eka2l1 Log" > "${EKA_LOG}"

log() { echo "$*" >> "${EKA_LOG}"; }

# create dialog.gptk if missing
if [ ! -f "${DIALOG_GPTK}" ]; then
  mkdir -p "$(dirname "${DIALOG_GPTK}")"
  cat > "${DIALOG_GPTK}" << 'EOF'
up = up
down = down
left = left
right = right
a = enter
b = escape
back = escape
left_analog_up = up
left_analog_down = down
left_analog_left = left
left_analog_right = right
EOF
fi

# Device cache helpers
cache_key() {
  local raw
  if [ -n "${ROMFILE}" ]; then
    raw="$(basename "${ROMFILE}")"
  else
    raw="__ngage2__"
  fi
  echo "${raw}" | tr ' .()[]{}' '_'
}

cache_get_device() {
  local key="$1"
  [ ! -f "${EKA_DEVICE_CACHE}" ] && return
  local val
  val="$(grep -m1 "^${key}=" "${EKA_DEVICE_CACHE}" | cut -d= -f2-)"
  echo "${val%%:*}"
}

cache_set() {
  local key="$1"
  local val="$2"
  val="$(echo "${val}" | head -1)"
  touch "${EKA_DEVICE_CACHE}"
  local tmpf
  tmpf=$(mktemp)
  grep -v "^${key}=" "${EKA_DEVICE_CACHE}" > "${tmpf}" 2>/dev/null
  printf "%s=%s\n" "${key}" "${val}" >> "${tmpf}"
  mv "${tmpf}" "${EKA_DEVICE_CACHE}"
}

cache_delete() {
  local key="$1"
  [ ! -f "${EKA_DEVICE_CACHE}" ] && return
  local tmpf
  tmpf=$(mktemp)
  grep -v "^${key}=" "${EKA_DEVICE_CACHE}" > "${tmpf}" 2>/dev/null
  mv "${tmpf}" "${EKA_DEVICE_CACHE}"
}

# Device helpers
device_installed() {
  local dev="$1"
  [ -z "${dev}" ] && return 1
  grep -qi "^${dev}:" "${EKA_CONFIG_DIR}/data/devices.yml" 2>/dev/null
}

set_active_device() {
  local dev="$1"
  local config="${EKA_CONFIG_DIR}/config.yml"
  local devices="${EKA_CONFIG_DIR}/data/devices.yml"
  local idx

  idx="$(awk -v dev="${dev}" '
    BEGIN { IGNORECASE=1 }
    /^[^ \t]/ {
      key = $0; gsub(/:.*/, "", key)
      if (key == dev) { print count+0; found=1; exit }
      count++
    }
    END { if (!found) exit 1 }
  ' "${devices}")"

  [ -z "${idx}" ] && { log "ERROR: Device ${dev} not found in devices.yml"; return 1; }

  sed -i "s/^device: .*/device: ${idx}/" "${config}"
  log "Device set: ${dev} -> index ${idx}"
}

# fbterm dialog helper
run_dialog_script() {
  local tmpscript="$1"

  killall -9 gptokeyb 2>/dev/null
  gptokeyb 1 fbterm -c "${DIALOG_GPTK}" &
  sleep 0.5
  kill -STOP $(pidof emulationstation) 2>/dev/null
  sleep 0.5
  dd if=/dev/zero of=/dev/fb0 bs=1M 2>/dev/null || true
  ee_console enable
  fbterm "${tmpscript}" -s 24 < /dev/tty1
  ee_console disable
  kill -CONT $(pidof emulationstation) 2>/dev/null
  killall -9 gptokeyb 2>/dev/null
  gptokeyb 1 eka2l1_sdl2 -c "${EKA_GPTK}" &
  sleep 1
}

# Device selection dialog
select_device_dialog() {
  local default_dev="$1"
  local devices="${EKA_CONFIG_DIR}/data/devices.yml"
  local roms_dir="${EKA_CONFIG_DIR}/data/roms"
  local menu_items=()
  local code="" model=""

  rm -f "${SELECTED_DEVICE_FILE}"

  while IFS= read -r line; do
    case "${line}" in
      *:\ *)
        local key="${line%%:*}"
        local val="${line#*: }"
        case "${key}" in
          "  firmcode") code="${val}" ;;
          "  model")    model="${val}" ;;
        esac
        ;;
      *:)
        if [ -n "${code}" ] && [ -n "${model}" ]; then
          local code_lower
          code_lower="$(echo "${code}" | tr '[:upper:]' '[:lower:]')"
          if [ -d "${roms_dir}/${code_lower}" ] || [ -d "${roms_dir}/${code}" ]; then
            menu_items+=("${code}" "${model}")
          fi
        fi
        code=""
        model=""
        ;;
    esac
  done < "${devices}"
  if [ -n "${code}" ] && [ -n "${model}" ]; then
    local code_lower
    code_lower="$(echo "${code}" | tr '[:upper:]' '[:lower:]')"
    if [ -d "${roms_dir}/${code_lower}" ] || [ -d "${roms_dir}/${code}" ]; then
      menu_items+=("${code}" "${model}")
    fi
  fi

  # Fallback: if no roms are being found, show all devices
  if [ ${#menu_items[@]} -eq 0 ]; then
    while IFS= read -r line; do
      case "${line}" in
        *:\ *)
          local key="${line%%:*}"
          local val="${line#*: }"
          case "${key}" in
            "  firmcode") code="${val}" ;;
            "  model")    model="${val}" ;;
          esac
          ;;
        *:)
          [ -n "${code}" ] && [ -n "${model}" ] && menu_items+=("${code}" "${model}")
          code=""
          model=""
          ;;
      esac
    done < "${devices}"
    [ -n "${code}" ] && [ -n "${model}" ] && menu_items+=("${code}" "${model}")
  fi

  local tmpout tmpscript
  tmpout=$(mktemp /tmp/eka_dialog_XXXXXX)
  tmpscript=$(mktemp /tmp/eka_script_XXXXXX)

  cat > "${tmpscript}" << SCRIPTEOF
#!/bin/bash
export TERM=linux
exec 2>"${tmpout}"
set --
SCRIPTEOF

  local item
  for item in "${menu_items[@]}"; do
    item="${item//\\/\\\\}"
    item="${item//\"/\\\"}"
    echo "set -- \"\$@\" \"${item}\"" >> "${tmpscript}"
  done

  if [ -n "${default_dev}" ]; then
    echo "dialog --no-shadow --ascii-lines --clear --default-item \"${default_dev}\" --title \"eka2l1 - Select Device\" --menu \"Choose a Symbian device:\" 20 60 15 \"\$@\"" >> "${tmpscript}"
  else
    echo "dialog --no-shadow --ascii-lines --clear --title \"eka2l1 - Select Device\" --menu \"Choose a Symbian device:\" 20 60 15 \"\$@\"" >> "${tmpscript}"
  fi
  echo "exit \$?" >> "${tmpscript}"
  chmod +x "${tmpscript}"

  run_dialog_script "${tmpscript}"
  rm -f "${tmpscript}"

  local chosen=""
  [ -f "${tmpout}" ] && chosen="$(head -1 "${tmpout}")"
  rm -f "${tmpout}"
  log "Dialog returned: '${chosen}'"

  if [ -z "${chosen}" ] || ! grep -qi "^${chosen}:" "${EKA_CONFIG_DIR}/data/devices.yml" 2>/dev/null; then
    log "Device selection invalid or cancelled (got: ${chosen})"
    exit 0
  fi

  echo "${chosen}" > "${SELECTED_DEVICE_FILE}"
}


# N-Gage 1 app name lookup table
get_run_name() {
  local key
  key="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "${key}" in
    "ashen")                                    echo "Ashen" ;;
    "asphalt: urban gt 2"|"asphalt urban gt 2") echo "Asphalt 2" ;;
    "asphalt: urban gt"|"asphalt urban gt")     echo "Asphalt" ;;
    "atari masterpieces vol. 1"|"atari masterpieces vol 1") echo "Atari MP Vol I" ;;
    "atari masterpieces vol. ii"|"atari masterpieces vol ii") echo "Atari MP Vol II" ;;
    "bomberman")                                echo "Bomberman" ;;
    "call of duty")                             echo "CallofDuty" ;;
    "catan")                                    echo "Catan" ;;
    "civilization")                             echo "Civilization" ;;
    "colin mcrae rally 2005")                   echo "colin mcrae rally 2005" ;;
    "crash nitro kart")                         echo "CrashNitroKart" ;;
    "fifa football 2005"|"fifa 2005")           echo "FIFA 2005" ;;
    "fifa soccer 2004"|"fifa 2004")             echo "FIFA 2004" ;;
    "glimmerati")                               echo "Glimmerati" ;;
    "high seize")                               echo "High Seize" ;;
    "mlb slam!"|"mlb slam")                     echo "MLB Slam!" ;;
    "marcel desailly pro soccer")               echo "MarcelDesaillyProSoccer" ;;
    "mile high pinball")                        echo "Mile High" ;;
    "motogp")                                   echo "MotoGP" ;;
    "ncaa football 2004")                       echo "NCAA®" ;;
    "one")                                      echo "ONE" ;;
    "operation shadow")                         echo "Operation Shadow" ;;
    "pandemonium!")                             echo "Pandemonium" ;;
    "pathway to glory")                         echo "Pathway to Glory" ;;
    "pathway to glory: ikusa islands"|"ikusa islands") echo "Ikusa Islands" ;;
    "payload")                                  echo "Payload" ;;
    "pocket kingdom: own the world"|"pocket kingdom") echo "PKingdom" ;;
    "puyo pop")                                 echo "Puyo Pop" ;;
    "puzzle bobble vs")                         echo "PuzzleBobbleVS" ;;
    "rayman 3")                                 echo "Rayman 3" ;;
    "red faction")                              echo "RedFaction" ;;
    "requiem of hell")                          echo "Requiem of Hell" ;;
    "rifts: promise of power"|"rifts")          echo "RIFTS" ;;
    "ssx: out of bounds"|"ssx out of bounds"|"ssx") echo "SSX" ;;
    "sega rally championship")                  echo "SegaRally" ;;
    "snakes")                                   echo "Snakes" ;;
    "sonicn")                                   echo "SonicN" ;;
    "spider-man 2"|"spiderman 2")               echo "SM 2" ;;
    "super monkey ball")                        echo "supermonkeyball" ;;
    "system rush")                              echo "System Rush" ;;
    "the elder scrolls travels: shadowkey"|"shadowkey") echo "Elder Scrolls" ;;
    "the king of fighters: extreme"|"kof extreme") echo "KOF EXTREME" ;;
    "the roots: gates of chaos"|"the roots")    echo "The Roots" ;;
    "the roots: gates of chaos"|"the roots")    echo "The Roots" ;;
    "the sims: bustin' out"|"the sims bustin out") echo "The Sims Bustin' Out" ;;
    "tiger woods pga tour 2004")                echo "TW 2004" ;;
    "tom clancy's ghost recon: jungle storm"|"ghost recon") echo "GhostRecon" ;;
    "tom clancy's splinter cell: chaos theory") echo "SplinterCell" ;;
    "tom clancy's splinter cell: team stealth action"|"splinter cell") echo "Splinter Cell" ;;
    "tomb raider: starring lara croft"|"tomb raider") echo "Tomb Raider" ;;
    "tony hawk's pro skater")                   echo "Tony Hawk's Pro Skater" ;;
    "virtua cop")                               echo "Virtua Cop" ;;
    "virtua tennis")                            echo "virtuatennis" ;;
    "wwe: aftershock"|"wwe aftershock"|"wwe")   echo "WWE" ;;
    "warhammer 40,000: glory in death"|"warhammer 40000") echo "WH40K" ;;
    "worms: world party"|"worms world party")   echo "WWP" ;;
    "x-men legends ii: rise of apocalypse"|"x-men legends ii") echo "XMLII" ;;
    "x-men legends")                            echo "XMen™" ;;
    "xanadu next"|"xanadu")                     echo "XanaduNext" ;;
    *) echo "" ;;
  esac
}

CLASSIC_APP_DST=""
CLASSIC_APP_SRC=""

save_classic_state() {
  [ -z "${CLASSIC_APP_DST}" ] && return
  [ ! -d "${CLASSIC_APP_DST}" ] && return
  [ -z "${CLASSIC_APP_SRC}" ] && return

  log "Syncing saves back to: ${CLASSIC_APP_SRC}"

  find "${CLASSIC_APP_DST}" -type f | while read -r DST_FILE; do
    REL="${DST_FILE#${CLASSIC_APP_DST}/}"
    SRC_FILE="${CLASSIC_APP_SRC}/${REL}"
    if [ ! -f "${SRC_FILE}" ] || [ "${DST_FILE}" -nt "${SRC_FILE}" ]; then
      mkdir -p "$(dirname "${SRC_FILE}")"
      cp -a "${DST_FILE}" "${SRC_FILE}"
      log "  Saved: ${REL}"
    fi
  done
}

cleanup() {
  [ "${CLEANUP_DONE}" = "1" ] && return
  CLEANUP_DONE=1

  save_classic_state

  if [ -n "${CLASSIC_APP_DST}" ] && [ -d "${CLASSIC_APP_DST}" ]; then
    log "Removing ${CLASSIC_APP_DST} from e:/system/apps/"
    rm -rf "${CLASSIC_APP_DST}"
  fi

  killall -9 gptokeyb 2>/dev/null
}
trap cleanup EXIT INT TERM HUP

# Sanity check
if [ ! -d "${EKA_DATA_DIR}" ]; then
  log "ERROR: eka2l1 not set up. Please run EKA_INSTALL first."
  exit 1
fi

mkdir -p "${EKA_DRIVES_DIR}" "${EKA_E_DIR}"

# Detect launch mode
if [ -n "${ROMFILE}" ]; then
  # Special identification for generic Games App
  if [[ "$(basename "${ROMFILE}")" == "games.symbian" ]]; then
     LAUNCH_MODE="games_app"
     log "Mode: N-Gage 2.0 Games Application"
  elif [ -f "${ROMFILE}" ]; then
    case "${ROMFILE##*.}" in
      uid|UID)
        APP_UID="$(sed -n '1p' "${ROMFILE}" | tr -d '\r\n[:space:]')"
        UID_DEVICE="$(sed -n '2p' "${ROMFILE}" | tr -d '\r\n[:space:]' | tr '[:lower:]' '[:upper:]')"
        if [ -n "${APP_UID}" ]; then
          case "${APP_UID}" in 0x*|0X*) ;; *) APP_UID="0x${APP_UID}" ;; esac
          LAUNCH_MODE="uid"
          log "UID launcher: ${APP_UID}"
          [ -n "${UID_DEVICE}" ] && log "UID device hint: ${UID_DEVICE}"
        fi
        ;;
    esac
  elif [ -d "${ROMFILE}" ]; then
    case "${ROMFILE}" in
      *.ngage|*.NGAGE)
        CLASSIC_NGAGE=1
        LAUNCH_MODE="classic"

        GAME_FOLDER="$(basename "${ROMFILE}")"
        GAME_ID="${GAME_FOLDER%.ngage}"
        GAME_ID="${GAME_ID%.NGAGE}"

        SIDECAR="${ROMFILE%/}.name"
        if [ -f "${SIDECAR}" ]; then
          APP_RUN="$(tr -d '\r\n' < "${SIDECAR}")"
          log "App name from sidecar: ${APP_RUN}"
        else
          APP_RUN="$(get_run_name "${GAME_ID}")"
          if [ -z "${APP_RUN}" ]; then
            APP_RUN="$(echo "${GAME_ID}" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')"
            log "App name from folder (fallback): ${APP_RUN}"
          else
            log "App name from lookup table: ${APP_RUN}"
          fi
        fi

        APP_FOLDER="$(ls "${ROMFILE}/system/apps/" 2>/dev/null | head -1)"
        if [ -n "${APP_FOLDER}" ]; then
          SRC="${ROMFILE}/system/apps/${APP_FOLDER}"
          DST="${EKA_E_DIR}/system/apps/${APP_FOLDER}"
          log "Installing ${APP_FOLDER} into e:/system/apps/"
          mkdir -p "${EKA_E_DIR}/system/apps"
          rm -rf "${DST}"
          cp -a "${SRC}" "${DST}"
          CLASSIC_APP_DST="${DST}"
          CLASSIC_APP_SRC="${SRC}"
        else
          log "ERROR: No app folder found in ${ROMFILE}/system/apps/"
          exit 1
        fi
        ;;
    esac
  fi
fi

# gptokeyb
killall -9 gptokeyb 2>/dev/null
gptokeyb 1 eka2l1_sdl2 -c "${EKA_GPTK}" &
sleep 1

cd "${EKA_CONFIG_DIR}" || exit 1

# Device selection
CKEY="$(cache_key)"
LAST_DEVICE="$(cache_get_device "${CKEY}")"
log "Cache key: ${CKEY}, cached device: ${LAST_DEVICE:-none}"

if [ -n "${UID_DEVICE}" ] && device_installed "${UID_DEVICE}"; then
  DEVICE_CODE="${UID_DEVICE}"
  log "Device from .uid file: ${DEVICE_CODE}"
elif [ -n "${LAST_DEVICE}" ] && device_installed "${LAST_DEVICE}"; then
  DEVICE_CODE="${LAST_DEVICE}"
  log "Device from cache: ${DEVICE_CODE}"
else
  select_device_dialog ""
  DEVICE_CODE="$(cat "${SELECTED_DEVICE_FILE}" 2>/dev/null)"
  rm -f "${SELECTED_DEVICE_FILE}"
  log "Device selected: ${DEVICE_CODE}"
fi

set_active_device "${DEVICE_CODE}" || exit 1

# Launch
EKA_EXIT=0

if [ "${LAUNCH_MODE}" = "uid" ]; then
  log "Launching UID ${APP_UID} on ${DEVICE_CODE}"
  CUBEB_BACKEND=alsa "${EKA_EXE}" --device "${DEVICE_CODE}" --app "${APP_UID}" >> "${EKA_LOG}" 2>&1
  EKA_EXIT=$?

elif [ "${LAUNCH_MODE}" = "classic" ]; then
  log "Launching classic N-Gage: --run \"${APP_RUN}\" on ${DEVICE_CODE}"
  CUBEB_BACKEND=alsa "${EKA_EXE}" --device "${DEVICE_CODE}" --run "${APP_RUN}" >> "${EKA_LOG}" 2>&1
  EKA_EXIT=$?

else
  log "Launching N-Gage 2.0 Games app on ${DEVICE_CODE}"
  CUBEB_BACKEND=alsa "${EKA_EXE}" --device "${DEVICE_CODE}" --app Games >> "${EKA_LOG}" 2>&1
  EKA_EXIT=$?
fi

log "eka2l1 exited with code ${EKA_EXIT}"

# --- Post-Launch Logic ---

# 1. Special Handling for the Games App (Closed via Kill Key)
if [ "${LAUNCH_MODE}" = "games_app" ]; then
  log "Preserving cache for Games App (ignores exit code)."
  cache_set "${CKEY}" "${DEVICE_CODE}"

# 2. Standard Handling for specific Games (Successful exit)
elif [ "${EKA_EXIT}" = "0" ]; then
  if [ "${LAUNCH_MODE}" = "uid" ] && [ -f "${ROMFILE}" ]; then
    if [ "${DEVICE_CODE}" != "${UID_DEVICE}" ]; then
      log "Updating .uid file with working device: ${DEVICE_CODE}"
      FIRST_LINE=$(sed -n '1p' "${ROMFILE}")
      echo "${FIRST_LINE}" > "${ROMFILE}"
      echo "${DEVICE_CODE}" >> "${ROMFILE}"
    fi
  fi
  cache_set "${CKEY}" "${DEVICE_CODE}"
  log "Device cached: ${DEVICE_CODE}"

# 3. Crash / Failure Handling
else
  log "Crash detected (Exit: ${EKA_EXIT}). Clearing cache."
  cache_delete "${CKEY}"
  if [ "${LAUNCH_MODE}" = "uid" ] && [ -f "${ROMFILE}" ]; then
    log "Clearing .uid hint due to crash."
    FIRST_LINE=$(sed -n '1p' "${ROMFILE}")
    echo "${FIRST_LINE}" > "${ROMFILE}"
  fi
fi

cleanup