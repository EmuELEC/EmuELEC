#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

UPDINFO="https://raw.githubusercontent.com/EmuELEC/emuelec.github.io/master/settings/EE_update"
UPDURL="https://github.com/EmuELEC/EmuELEC/releases/download/v"
TEST_UPDURL="https://github.com/EmuELEC/EmuELEC-tests/releases/download/v"
BUILDATE=$(cat /usr/buildate)
arguments="$@"

if [[ "${arguments}" == *"forceupdate"* ]]; then
systemctl stop emustation
ee_console enable
clear /dev/tty0
    
while pgrep -f emulationstation; do
    clear /dev/tty0
    echo "Waiting for Emulationstation to quit..." > /dev/tty0
    sleep 1
done

fi

UPDTYPE=$(get_ee_setting updates.type)
[[ -z "${UPDTYPE}" ]] && UPDTYPE="stable"
[[ "${UPDTYPE}" != "stable" ]] && UPDURL="${TEST_UPDURL}"

function do_cleanup() {
	rm -rf /storage/.update/* > /dev/null 2>&1
}

function no_update() {
	echo "no"
	do_cleanup
if [[ "${arguments}" == *"forceupdate"* ]]; then
    ee_console disable
    systemctl start emustation
fi
	exit 1
}

function forced_update() {
ee_console enable
	echo "Downloadinng ${UPDURL} to /storage/.update/${UFILE}" > /dev/tty0
	touch "/storage/.update/${UFILE}"
	wget "${UPDURL}" -O "/storage/.update/${UFILE}" || echo "Exit code: $?" > /dev/tty0

# Try to download an sha256 checksum
	echo "Trying to download sha256 checksum" > /dev/tty0
    wget -q "${UPDURL}.sha256" -O "/storage/.update/${UFILE}.sha256"

if test -e "/storage/.update/${UFILE}.sha256"; then
	echo "Doing checksum..." > /dev/tty0
    DISTMD5=$(cat "/storage/.update/${UFILE}.sha256" | cut -d ' ' -f 1)
    CURRMD5=$(sha256sum "/storage/.update/${UFILE}" | cut -d ' ' -f 1)

    if test "${DISTMD5}" = "${CURRMD5}"; then
        echo "Valid checksum...continuing" > /dev/tty0
    else
        text_viewer -e -w -t "Invalid Checksum!" -f 24 -m "invalid checksum. Got +${DISTMD5}+. Attempted +${CURRMD5}+.\n\n FORCE UPDATE ABORTED!"
        no_update
	exit 1
    fi

else
    echo "No checksum found. Won't check the file." > /dev/tty0
fi
    echo "Aplying update" > /dev/tty0
	sync
	systemctl stop emustation

while pgrep -f emulationstation; do
    clear /dev/tty0
    echo "Waiting for Emulationstation to quit..." > /dev/tty0
    sleep 1
done

	emuelec-utils clearconfig EMUS
	systemctl reboot
	exit 0
}

function check_update() { 
if [[ "${arguments}" == *"canupdate"* ]]; then
	echo "${UPDATEVERP}"
elif [[ "${arguments}" == *"geturl"* ]]; then	
	echo "${UPDURL}"
elif [[ "${arguments}" == *"getsize"* ]]; then
    USIZE=$(wget "${UPDURL}" --spider --server-response -O - 2>&1 | sed -ne '/Content-Length:/{s/.*: //;p}' | tail -1)	
	echo "${USIZE}"
fi
}

#make sure there is no old update
do_cleanup

# To avoid curl error "(23) Failed writing body", we download the full page to /tmp/eeupd and use cat to read it then delete it
curl -s ${UPDINFO} -o /tmp/eeupd

UPDDATA=$(cat /tmp/eeupd | grep "${UPDTYPE}")
rm /tmp/eeupd
[ -z "${UPDDATA}" ] && no_update

OLDIFS=${IFS}
IFS=';' read -r -a updinfo <<< "${UPDDATA}"
IFS=${OLDIFS}

UVER="${updinfo[0]}"
UFILE="EmuELEC-${EE_DEVICE}.aarch64-${UVER}"

if [[ "${EE_DEVICE}" == "OdroidGoAdvance" ]]; then
    UFILE+="-odroidgo2.tar"
elif [[ "${EE_DEVICE}" == "GameForce" ]]; then
    UFILE+="-chi.tar"
elif [[ "${EE_DEVICE}" == "RK356x" ]]; then
    UFILE+="-rk356x.tar"
else
    UFILE+=".tar"
fi

UPDURL+="${UVER}/${UFILE}"

#check if file exists
if ! curl --head --fail --silent "${UPDURL}" >/dev/null; then
if [[ "${arguments}" == *"forceupdate"* ]]; then
text_viewer -e -w -t "ERROR!" -f 24 -m "The update file either does not exists or you are not connected to the internet! FORCE UPDATE ABORTED!\n\nEmulationstation will now restart!"
no_update
fi
    no_update
fi

CVER=$(cat /usr/config/EE_VERSION)
[[ -z "${CVER}" ]] && no_update
if $(echo "${CVER}" | grep -q "TEST"); then
    CVER=$(echo "${CVER}" | sed "s|-TEST-||")
fi

UVER=$(echo "${UVER}" | sed "s|-TEST-||")
[[ -z "${UVER}" ]] && no_update

CURRENTVER="${CVER%%.*}${CVER#*.}"
UPDATEVER="${UVER%%.*}${UVER#*.}"
UPDATEVERP="${UVER}"

CURRENTVER="${CURRENTVER%%-*}"
UPDATEVER="${UPDATEVER%%-*}"

# If current or update version is only 2 digits, then we add 99999999 to allow updating from beta to stable and viceversa
[ ${#CURRENTVER} == 2 ] && CURRENTVER="${CURRENTVER}99999999" 
[ ${#UPDATEVER} == 2 ] && UPDATEVER="${UPDATEVER}99999999"


# if you use forceupdate as an argument you can forcibly download the latest STABLE release and call an update
if [[ "${arguments}" == *"forceupdate"* ]]; then
    text_viewer -y -w -t "Force update!" -f 24 -m "A forced update has been called, this will download the latest release depending on your type settings (stable or test/beta)\n\nThe system will reboot if the update file is downloaded succesfully.\n\nAre you sure you want to continue?"
    if [[ $? == 21 ]]; then
        forced_update
    else
        echo "Force update canceled."
        no_update
	exit 1
    fi
else
    if [ "${UPDATEVER}" -gt "${CURRENTVER}" ] ; then 
        check_update
    else 
        no_update
    fi 
fi
