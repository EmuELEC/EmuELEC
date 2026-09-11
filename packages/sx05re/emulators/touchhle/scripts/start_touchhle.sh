#!/bin/sh

CONFDIR="/storage/.config/touchhle"

# 4 GiB guest address space reservation needs overcommit on 4 GB devices
echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null

# First-run sync of runtime data to writable storage (sandbox/savegames live here)
if [ ! -d "${CONFDIR}/touchHLE_dylibs" ]; then
  mkdir -p "${CONFDIR}"
  cp -r /usr/config/touchhle/* "${CONFDIR}/"
fi

cd "${CONFDIR}"

killall -STOP emulationstation 2>/dev/null

/usr/bin/touchhle-sa --fullscreen "$@"
RET=$?

killall -CONT emulationstation 2>/dev/null
exit ${RET}