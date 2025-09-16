#!/bin/sh
#      Copyright (C) 2008-2013 Team XBMC
#      http://xbmc.org
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.

. /etc/profile

trap cleanup TERM

KODI_ROOT=${HOME}/.kodi

SAVED_ARGS="${@}"
CRASHLOG_DIR=${KODI_ROOT}/temp

BOOT_STATUS=${HOME}/.config/boot.status
NOSAFE_MODE=${HOME}/.config/safemode.disable
CRASH_HIST=/run/libreelec/crashes.dat
KODI_MAX_RESTARTS=@KODI_MAX_RESTARTS@
KODI_MAX_SECONDS=@KODI_MAX_SECONDS@

cleanup() {
  # make systemd happy by not exiting immediately but
  # wait for kodi to exit
  while killall -0 kodi.bin &>/dev/null; do
    sleep 0.5
  done
}

command_exists()
{
  command -v ${1} &>/dev/null
}

single_stacktrace()
{
  # core filename is "core.*kodi.bin.*"
  find "${1}" -name 'core.*kodi.bin.*' | while read core; do
    echo "=====>  Core file: "${core}"" >> ${FILE}
    echo "        =========================================" >> ${FILE}
    if [ -f /storage/.config/debug.enhanced ]; then
      gdb /usr/lib/kodi/kodi.bin --core="${core}" --batch -ex "thread apply all bt full" -ex "info registers" -ex "set print asm-demangle on" -ex "disassemble" 2>/dev/null >> ${FILE}
    else
      gdb /usr/lib/kodi/kodi.bin --core="${core}" --batch -ex "thread apply all bt" 2>/dev/null >> ${FILE}
    fi
    rm -f "${core}"
  done
}

detect_crash_loop()
{
  # use monotonic time (in case date/time changes after booting)
  NOW_TIME=$(awk '/^now/ {print int(${3} / 1000000000)}' /proc/timer_list)
  echo "${NOW_TIME}" >> ${CRASH_HIST}

  NUM_RESTARTS=$(wc -l ${CRASH_HIST} | cut -d' ' -f1)
  FIRST_RESTART_TIME=$(tail -n ${KODI_MAX_RESTARTS} ${CRASH_HIST} | head -n 1)

  # kodi restart loop detected? fail this kodi install
  if [ ${NUM_RESTARTS} -ge ${KODI_MAX_RESTARTS} -a ${KODI_MAX_SECONDS} -ge $((NOW_TIME - FIRST_RESTART_TIME)) ]; then
    return 0
  else
    return 1
  fi
}

activate_safe_mode()
{
  [ -f ${NOSAFE_MODE} ] && return 0

  BOOT_STATE="$(cat ${BOOT_STATUS} 2>/dev/null)"

  if [ "${BOOT_STATE:-OK}" = "OK" ]; then
    # generate logfiles zip for the failed kodi
    /usr/bin/createlog
    lastlog=$(ls -1 /storage/logfiles/*.zip | tail -n 1)
    mv ${lastlog} /storage/logfiles/log-$(date -u +%Y-%m-%d-%H.%M.%S)-FAILED.zip

    echo "SAFE" > ${BOOT_STATUS}
  fi

  return 0
}

print_crash_report()
{
  mkdir -p ${CRASHLOG_DIR}

  DATE=`date +%Y%m%d%H%M%S`
  FILE="${CRASHLOG_DIR}/.kodi_crashlog.log"
  echo "############## kodi CRASH LOG ###############" > ${FILE}
  echo >> ${FILE}
  echo "################ SYSTEM INFO ################" >> ${FILE}
  echo -n " Date: " >> ${FILE}
  date >> ${FILE}
  echo " kodi Options: ${SAVED_ARGS}" >> ${FILE}
  echo -n " Arch: " >> ${FILE}
  uname -m >> ${FILE}
  echo -n " Kernel: " >> ${FILE}
  uname -rvs >> ${FILE}
  echo -n " Release: " >> ${FILE}
  . /etc/os-release
  echo ${NAME} ${VERSION} >> ${FILE}
  echo "############## END SYSTEM INFO ##############" >> ${FILE}
  echo >> ${FILE}
  echo "############### STACK TRACE #################" >> ${FILE}
  if command_exists gdb; then
    single_stacktrace /storage/.cache/cores
  else
    echo "gdb not installed, can't get stack trace." >> ${FILE}
  fi
  echo "############# END STACK TRACE ###############" >> ${FILE}
  echo >> ${FILE}
  echo "################# LOG FILE ##################" >> ${FILE}
  echo >> ${FILE}
  cat ${KODI_ROOT}/temp/kodi.log >> ${FILE}
  echo >> ${FILE}
  echo "############### END LOG FILE ################" >> ${FILE}
  echo >> ${FILE}
  echo "############ END kodi CRASH LOG #############" >> ${FILE}
  OFILE="${FILE}"
  FILE="${CRASHLOG_DIR}/kodi_crashlog_${DATE}.log"
  mv "${OFILE}" "${FILE}"
  ln -sf "$(basename ${FILE})" "${CRASHLOG_DIR}/kodi_crash.log"
  echo "Crash report available at ${FILE}"
}

if command_exists gdb; then
  ulimit -c unlimited
fi

# clean up any stale cores. just in case
find /storage/.cache/cores -type f -delete

# clean zero-byte database files that prevent migration/startup
for file in ${KODI_ROOT}/userdata/Database/*.db; do
  if [ -e "${file}" ]; then
    [ -s ${file} ] || rm -f ${file}
  fi
done

if [ -n "${KODI_AE_SINK}" ]; then

  echo "KODI_AE_SINK env variable is deprecated and will be removed in the future."
  echo "Use the --audio-backend command line switch instead."

  if [ "${KODI_AE_SINK}" = "PIPEWIRE" ]; then
    ENV_ARGS="--audio-backend=pipewire"
  elif [ "${KODI_AE_SINK}" = "PULSE" ]; then
    ENV_ARGS="--audio-backend=pulseaudio"
  elif [ "${KODI_AE_SINK}" = "ALSA" ]; then
    ENV_ARGS="--audio-backend=alsa"
  elif [ "${KODI_AE_SINK}" = "SNDIO" ]; then
    ENV_ARGS="--audio-backend=sndio"
  elif [ "${KODI_AE_SINK}" = "ALSA+PULSE" ]; then
    ENV_ARGS="--audio-backend=alsa+pulseaudio"
  fi
fi

/usr/lib/kodi/kodi.bin ${ENV_ARGS} ${SAVED_ARGS}
RET=$?

if [ $(( (${RET} >= 131 && ${RET} <= 136) || ${RET} == 139 )) = "1" ] ; then
  # Crashed with core dump
  print_crash_report

  # Cleanup. Keep only youngest 10 reports but current in any case
  rm -f $(ls -1t ${CRASHLOG_DIR}/kodi_crashlog_*.log | grep -v "${FILE}" | tail -n +10)

  # Enable safe mode if a crash loop is detected
  detect_crash_loop && activate_safe_mode
fi

# Filter Kodi powerdown/restartapp/reboot codes to satisfy systemd
[ "${RET}" -ge 64 -a "${RET}" -le 66 ] && RET=0

exit ${RET}
