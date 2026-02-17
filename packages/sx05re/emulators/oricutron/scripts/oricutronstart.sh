#!/bin/bash
. /etc/profile

ROM="$1"

CONFIG_DIR="/storage/.config/emuelec/configs/oricutron"
DEFAULT_DIR="/usr/config/emuelec/configs/oricutron"

# Default GPTK
GPTK_DEFAULT="/storage/.config/emuelec/configs/gptokeyb/oricutron.gptk"
# Per-ROM GPTK directory (optional)
GPTK_PERROM_DIR="/storage/.config/emuelec/configs/gptokeyb/oric"

mkdir -p "${CONFIG_DIR}"
mkdir -p "${GPTK_PERROM_DIR}"

if [ ! -f "${CONFIG_DIR}/oricutron.cfg" ]; then
  cp -f "${DEFAULT_DIR}/oricutron.cfg" "${CONFIG_DIR}/oricutron.cfg" 2>/dev/null || :
fi

[ -d "${CONFIG_DIR}/roms" ]   || cp -r "${DEFAULT_DIR}/roms"   "${CONFIG_DIR}/" 2>/dev/null || :
[ -d "${CONFIG_DIR}/images" ] || cp -r "${DEFAULT_DIR}/images" "${CONFIG_DIR}/" 2>/dev/null || :
mkdir -p "${CONFIG_DIR}"/{disks,tapes}

if [[ -n "${ROM}" && "${ROM}" != /* ]]; then
  ROM="$(pwd)/${ROM}"
fi

# Pick GPTK config: per-ROM if present, otherwise default
GPTK_CFG=""
if [ -n "${ROM}" ] && [ -e "${ROM}" ]; then
  ROM_BASENAME="$(basename -- "${ROM}")"
  ROM_STEM="${ROM_BASENAME%.*}"
  # Prefer exact stem match
  if [ -f "${GPTK_PERROM_DIR}/${ROM_STEM}.gptk" ]; then
    GPTK_CFG="${GPTK_PERROM_DIR}/${ROM_STEM}.gptk"
  # Fallback: sanitize to avoid problems with weird chars in filenames
  else
    ROM_SAFE="$(printf '%s' "${ROM_STEM}" | sed 's/[^A-Za-z0-9._-]/_/g')"
    if [ -f "${GPTK_PERROM_DIR}/${ROM_SAFE}.gptk" ]; then
      GPTK_CFG="${GPTK_PERROM_DIR}/${ROM_SAFE}.gptk"
    fi
  fi
fi

# If no per-ROM cfg found, use default
if [ -z "${GPTK_CFG}" ] && [ -f "${GPTK_DEFAULT}" ]; then
  GPTK_CFG="${GPTK_DEFAULT}"
fi

TMP_DIR="/tmp/oricutron_$$"
mkdir -p "${TMP_DIR}"

cp -f /usr/bin/oricutron "${TMP_DIR}/oricutron" || exit 1
chmod +x "${TMP_DIR}/oricutron"

ln -sf "${CONFIG_DIR}/roms"   "${TMP_DIR}/roms"
ln -sf "${CONFIG_DIR}/images" "${TMP_DIR}/images"
ln -sf "${CONFIG_DIR}/disks"  "${TMP_DIR}/disks"
ln -sf "${CONFIG_DIR}/tapes"  "${TMP_DIR}/tapes"

cp -f "${CONFIG_DIR}/oricutron.cfg" "${TMP_DIR}/oricutron.cfg" 2>/dev/null || :

cd "${TMP_DIR}" || exit 1

GPTK_PID=""
if [ -n "${GPTK_CFG}" ] && [ -f "${GPTK_CFG}" ]; then
  gptokeyb "./oricutron" -c "${GPTK_CFG}" &
  GPTK_PID=$!
fi

if [ -n "${ROM}" ]; then
  ./oricutron "${ROM}"
else
  ./oricutron
fi

[ -n "${GPTK_PID}" ] && kill "${GPTK_PID}" 2>/dev/null

cp -f "${TMP_DIR}/oricutron.cfg" "${CONFIG_DIR}/oricutron.cfg" 2>/dev/null || :
sync

cd /
rm -rf "${TMP_DIR}"
exit 0
