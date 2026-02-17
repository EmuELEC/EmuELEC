#!/bin/bash
# XRoar Wrapper for EmuELEC - Direct emulator start

. /etc/profile

ASSETDIR="/usr/config/emuelec/configs/xroar"
ROM="${1}"

export LD_LIBRARY_PATH="${ASSETDIR}/libs.aarch64:${LD_LIBRARY_PATH}"

if [ -z "${MACHINE}" ]; then
  case "${ROM}" in
    */dragon32/*) MACHINE="dragon32" ;;
    */dragon64/*) MACHINE="dragon64" ;;
    */coco/*)     MACHINE="coco" ;;
    */coco3/*)    MACHINE="coco3" ;;
    */mc10/*)     MACHINE="mc10" ;;
    *)            MACHINE="dragon64" ;;
  esac
fi

exec -a xroar /usr/bin/xroar.aarch64 \
  -fs \
  -rompath "/storage/roms/bios" \
  -default-machine "${MACHINE}" \
  -run "${ROM}"
