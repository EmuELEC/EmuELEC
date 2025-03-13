#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# DO NOT modify this file, if you need to use autostart please use /storage/.config/custom_start.sh 

# It seems some slow SDcards have a problem creating the symlink on time :/
CONFIG_DIR="/storage/.emulationstation"
CONFIG_DIR2="/storage/.config/emulationstation"

if [ ! -L "${CONFIG_DIR}" ]; then
ln -sf ${CONFIG_DIR2} ${CONFIG_DIR}
fi

if [ "${EE_DEVICE}" == "Amlogic" ]; then
  rm /storage/.config/asound.conf > /dev/null 2>&1
  cp /storage/.config/asound.conf-amlogic /storage/.config/asound.conf

    if [ "$(get_es_setting bool StopMusicOnScreenSaver)" != "false" ]; then 
        sed -i "/<bool name=\"StopMusicOnScreenSaver.*/d" "${ES_CONF}"
        sed -i "s|</config>|	<bool name=\"StopMusicOnScreenSaver\" value=\"false\" />\n</config>|g" "${ES_CONF}"
    fi
    
elif [ "${EE_DEVICE}" == "Amlogic-ng" ]; then
  rm /storage/.config/asound.conf > /dev/null 2>&1
  cp /storage/.config/asound.conf-amlogic-ng /storage/.config/asound.conf
elif [ "${EE_DEVICE}" == "Amlogic-ne" ]; then
  rm /storage/.config/asound.conf > /dev/null 2>&1
  cp /storage/.config/asound.conf-amlogic-ne /storage/.config/asound.conf
elif [ "${EE_DEVICE}" == "Amlogic-no" ]; then
  rm /storage/.config/asound.conf > /dev/null 2>&1
  cp /storage/.config/asound.conf-amlogic-no /storage/.config/asound.conf
fi

HOSTNAME=$(get_ee_setting system.hostname)
if [ ! -z "${HOSTNAME}" ];then 
    echo "${HOSTNAME}" > /storage/.cache/hostname
else
    echo "EMUELEC" > /storage/.cache/hostname
fi
cat /storage/.cache/hostname > /proc/sys/kernel/hostname

if [[ "${EE_DEVICE}" == "GameForce" ]]; then
LED=$(get_ee_setting bl_rgb)
[ -z "${LED}" ] && LED="Off"
odroidgoa_utils.sh bl "${LED}"

LED=$(get_ee_setting gf_statusled)
[ -z "${LED}" ] && LED="heartbeat"
odroidgoa_utils.sh pl "${LED}"


rk_wifi_init /dev/ttyS1
fi

if [[ "${EE_DEVICE}" == "GameForce" ]] || [[ "${EE_DEVICE}" == "OdroidGoAdvance" ]]; then
    if [ -e "/flash/no_oc.oga" ]; then 
        set_ee_setting ee_oga_oc disable
        OGAOC=""
    else
        OGAOC=$(get_ee_setting ee_oga_oc)
    fi
[ -z "${OGAOC}" ] && OGAOC="Off"
    odroidgoa_utils.sh oga_oc "${OGAOC}"
fi


# Mounts /storage/roms
MOUNT_HANDLER=$(get_ee_setting ee_mount.handler)
if [ -z "${MOUNT_HANDLER}" ]; then
  MOUNT_HANDLER="eemount"
fi
${MOUNT_HANDLER} &> /emuelec/logs/eemount.log

# copy default bezel to /storage/roms/bezel if it doesn't exists
if [ ! -f "/storage/roms/bezels/default.cfg" ]; then 
mkdir -p /storage/roms/bezels/
cp -rf /usr/share/retroarch-overlays/bezels/* /storage/roms/bezels/ &
fi

# Restore config if backup exists
BACKUPTAR="ee_backup_config.tar.gz"
BACKUPFILE="/storage/roms/backup/${BACKUPTAR}"

[[ ! -f "${BACKUPFILE}" ]] && BACKUPFILE="/var/media/EEROMS/backup/${BACKUPTAR}"

if [ -f "${BACKUPFILE}" ]; then 
	emuelec-utils ee_backup restore no > /emuelec/logs/last-restore.log 2>&1
fi

# Clean cache garbage when boot up.
rm -rf /storage/.cache/cores/* &

# handle SSH
DEFE=$(get_ee_setting ee_ssh.enabled)

case "${DEFE}" in
"0")
	systemctl stop sshd
	rm /storage/.cache/services/sshd.conf
	;;
*)
	mkdir -p /storage/.cache/services/
	touch /storage/.cache/services/sshd.conf
	systemctl start sshd
	;;
esac

# Checks and sets the resolution for starting ES.
check_res.sh

# Show splash creen 
show_splash.sh intro

# run custom_start before FE scripts
/storage/.config/custom_start.sh before &

# Just make sure all the subshells are finished before starting front-end
wait

# Start Scanning for Bluetooth Controllers
BTENABLED=$(get_ee_setting ee_bluetooth.enabled)
BTSCANTIME=$(get_ee_setting ee_bluetooth.scantime)
if [[ "${BTENABLED}" != "1" ]]; then
systemctl stop bluetooth
rm /storage/.cache/services/bluez.conf & 
else
systemctl restart bluetooth
emuelec-bluetooth ${BTSCANTIME} &
fi

# What to start at boot?
DEFE=$(get_ee_setting ee_boot)

case "${DEFE}" in
"Retroarch")
	rm -rf /var/lock/start.retro
	touch /var/lock/start.retro
	systemctl start retroarch
	;;
*)
	rm /var/lock/start.games
	touch /var/lock/start.games
    systemctl start emustation
	;;
esac

# run custom_start ending scripts
/storage/.config/custom_start.sh after
