#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Helper script to activate/desactivate WLAN from command line

# Usage :
# wifi connect <ssid> <passphrase>
# wifi disconnect <ssid> 
# wifi scan
# wifi status

#####################################################

# downloaded from : https://jira.automotivelinux.org/secure/attachment/10300/wifi

### global vars ###

CONNMAN=/usr/bin/connmanctl

script=$(basename "${0}")
configpath=/storage/.cache/connman # connman config directory
ssid="" 	# ssid of wifi network to reach
passphrase="" 	# passphrase of wifi network to reach
service=""	# service identifier of the network service to reach
fullservice=""	# <ssid><service>

function error() {
	echo ERROR: "$@" >&2
	cat << EOF >&2
Usage:
	${script} connect <ssid> [passphrase]
	${script} disconnect [ssid]
	${script} scan
	${script} status
EOF
	exit 1
}

function wifi_enable() {
	command=$(${CONNMAN} technologies | grep -A 4 wifi | sed -n '4p')

	if [[ ${command} == *True ]]; then
		echo ">>> Wifi is already enabled ... Ok"
	else
		echo ">>> Enabling wifi ..."
		command=$(${CONNMAN} enable wifi)
		if [[ ${command} == Enabled* ]]; then
			echo ${command}
		else
			echo ">>> Cannot enable wifi !"
			exit 1
		fi
	fi
}

function wifi_disable() {
	${CONNMAN} disable wifi
}

function wifi_scan() {
	echo -e "\n>>> Scanning for available wifi networks..."
	${CONNMAN} scan wifi
}

function wifi_connected() {
	command=$(${CONNMAN} technologies | grep -A 4 wifi | sed -n '5p')

	if [[ ${command} == *True ]];then
		echo -e "\n>>> Already connected to a wifi network"
		return 0
	fi
	return 1
}

function wifi_status() {
	echo -e "\n>>> Wifi status:"
	${CONNMAN} technologies | grep -A 4 wifi
	echo -e "\n>>> Available SSIDs:"
	${CONNMAN} services | grep wifi_
}

function wifi_config() {
	echo -e "\n>>> Setting up wifi connection..."

	retries=5

	while [ 1 ]; do
		${CONNMAN} scan wifi
		echo -e "\n>>> Available SSIDs:"
		${CONNMAN} services | grep wifi_

		fullservice=$(${CONNMAN} services | cut -c 5- | sed 's/ \+ /:/g' | grep "${ssid}:")
		if [[ -n ${fullservice} ]]; then
			break
		fi

		retries=$(( retries - 1 ))
		if [[ ${retries} -gt 0 ]]; then
			echo "waiting for ${ssid} to appear..."
			sleep 5
			continue
		fi
		echo "Target ssid not found !"
		exit 1
	done

	ssid=$(echo "${fullservice}" | awk -F: '{print ${1}}')
	service=$(echo "${fullservice}" | awk -F: '{print ${2}}')

	echo "Target ssid found - config is :"
	echo "SSID       : ${ssid}"
	echo "Service Id : ${service}"
	echo "Passphrase : ${passphrase}"

	cat <<EOF >"${configpath}/${ssid}.config"
[service_${service}]
Name = ${ssid}
Type = wifi
Passphrase = ${passphrase}
EOF
	echo "Configuration written"
}

function wifi_connect() {
	echo -e "\n>>> Performing connection ..."
	output=$(${CONNMAN} connect ${service})

	if [[ ${output} == Connected* ]];then
		echo "...Ok."
		echo ${output}
	else
		echo "...connection failed !"
		echo ${output}

		wifi_disconnect 
		echo "Check your SSID or your passphrase"
		#read -n 1 -s -r -p "Press any key to continue"
		exit 1
	fi
}

function wifi_disconnect() {

	if [[ -z "${ssid}" ]]; then
		${CONNMAN} services | cut -c5- | sed 's/ \+ /:/g' | ( while read line; do
			ssid=$(cut -f1 -d':' <<<${line})
			serv=$(cut -f2 -d':' <<<${line})
			if [[ "${serv}" =~ ^wifi_  && -f "${configpath}/${ssid}.config" ]]; then
				echo "Disconnecting ${serv}"
				${CONNMAN} disconnect ${serv}
				echo "Cleaning config ${ssid}.config"
				rm -rf "${configpath}/${ssid}.config"
			fi
		done )
		return 0
	fi

	service=$(${CONNMAN} services | cut -c 5- | sed 's/ \+ /:/g' | grep "^${ssid}:" | awk -F: '{print ${2}}')
	if [[ -z "${service}" ]]; then
		echo "... unknown service"
		rm -rf "${configpath}/${ssid}.config" # clear config in all cases
		return 1
	fi

	output=$(${CONNMAN} disconnect ${service})
	rm -rf "${configpath}/${ssid}.config" # clear config in all cases
	if [[ ${output} == Disconnected* ]];then
		echo "...Ok."
		echo ${output}
	else
		echo "...disconnection failed !"
		echo ${output}
		return 1
	fi
}


# changes made by emuELEC 

COPTION=${1}
CSSID=${2}
CPASS=${3}

if [ -z "${CSSID}" ]; then
# check for a file named wifi.txt on /storage/.config or /flash
# read the content ssid:password and pass it as parameters to the script

	if [ -f "/storage/.config/wifi.txt" ]; then
		str=$(cat /storage/.config/wifi.txt)
	elif [ -f "/flash/wifi.txt" ]; then
		str=$(cat /flash/wifi.txt)
	else
		echo "no wifi.txt found. Make sure you create one in /storage/.config/wifi.txt and add your ssid:password inside"
		#read -n 1 -s -r -p "Press any key to continue"
	fi

	IFS=':' # space is set as delimiter
	read -ra WIFI <<< "${str}" # str is read into an array as tokens separated by IFS

fi

[ -z "${COPTION}" ] && COPTION="connect"
[ -z "${CSSID}" ] && CSSID=${WIFI[0]}
[ -z "${CPASS}" ] && CPASS=${WIFI[1]}

if wifi_connected; then
    ssid=${CSSID}
	wifi_disconnect
	echo "WiFi disconnected"
	#read -n 1 -s -r -p "Press any key to continue"
	exit 0
fi 

case ${COPTION} in
	connect)
		ssid=${CSSID}
		passphrase=${CPASS}
		[ -z "${ssid}" ] && error "No ssid defined !"
	    wifi_disconnect
		wifi_enable
		wifi_connected && exit 0
		wifi_config
		wifi_connect
		;;
	disconnect)
		ssid=${CSSID}
		wifi_disconnect
		wifi_disable
		;;
	scan)
		wifi_enable
		wifi_scan
		wifi_status
		;;
	status)
		wifi_status
		;;
	connected)
		wifi_connected && exit 0
		exit 1
		;;
	*)
		error "Command line doesn't have any option !"
esac


#read -n 1 -s -r -p "Press any key to continue"
