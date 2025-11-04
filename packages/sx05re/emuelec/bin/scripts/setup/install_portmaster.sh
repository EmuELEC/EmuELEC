#!/bin/bash

# Source predefined functions and variables
. /etc/profile

function portmaster_confirm() {
    text_viewer -y -w -t "Install Portmaster" -f 24 -m "This will install Portmaster and enable it on Emulationstation\n\nNOTE: You need to have an active internet connection and you will need to restart ES after this script ends, continue?"
        if [[ $? == 21 ]]; then
            if portmaster_install; then
                text_viewer -y -w -t "Install Portmaster Complete!" -f 24 -m "Portmaster installation is done!.\n\n Don't forget to restart Emulationstation! Would you like to restart it now?"
                    if [[ $? == 21 ]]; then
                        systemctl restart emustation
                    fi
            else
                text_viewer -e -w -t "Install Portmaster FAILED!" -f 24 -m "Portmaster installation was not completed!, Are you sure you are connected to the internet?"
            fi
      fi
    ee_console disable
 }

function portmaster_install() {
ee_console enable

LINK="https://github.com/PortsMaster/PortMaster-GUI/releases/latest/download/PortMaster.zip"
LINKTMP=$(mktemp -d);
LINKDEST="${LINKTMP}/PortMaster.zip"

wget -O ${LINKDEST} ${LINK}

[[ ! -f ${LINKDEST} ]] && return 1
unzip -o "${LINKDEST}" -d "/storage/roms/ports"
mkdir -p "/storage/roms/ports_scripts"
cp "/storage/roms/ports/PortMaster/PortMaster.sh" "/storage/roms/ports_scripts"
rm -rf ${LINKTMP}

XML_FILE="/storage/roms/ports_scripts/gamelist.xml"

if xmlstarlet sel -t -v "count(/gameList/game[name='PortMaster'])" "${XML_FILE}" | grep -qv '^0$'; then
	echo "PortMaster already in ${XML_FILE}" #nothing need to be done PortMaster Exists in gamelist
else
	echo "Adding PortMaster to ${XML_FILE}"
	
	# create xml file if it doesn't exist
	if [ ! -f "${XML_FILE}" ]; then
		echo "${XML_FILE} does not exists, creating..."
		echo '<?xml version="1.0" encoding="UTF-8"?>' > "${XML_FILE}"
		echo '<gameList/>' >> "${XML_FILE}"
	else
		# Check if <gameList> exists
		if ! xmlstarlet sel -t -c "/gameList" "${XML_FILE}" >/dev/null 2>&1; then
			echo '<?xml version="1.0" encoding="UTF-8"?>' > "$XML_FILE"
			echo '<gameList/>' >> "${XML_FILE}"
		fi
	fi

	# 3. Add new <game> entry using xmlstarlet
	xmlstarlet ed --inplace \
	-s "/gameList" -t elem -n "gameTMP" -v "" \
	-s "/gameList/gameTMP" -t elem -n "path" -v "./PortMaster.sh" \
	-s "/gameList/gameTMP" -t elem -n "name" -v "PortMaster" \
	-s "/gameList/gameTMP" -t elem -n "image" -v "/usr/bin/scripts/setup/setup_images/LaunchPortMaster.png" \
	-s "/gameList/gameTMP" -t elem -n "rating" -v "10" \
	-r "//gameTMP" -v "game" \
	"${XML_FILE}"
fi


echo "Done, restart ES"
ee_console disable
rm /tmp/display > /dev/null 2>&1
return 0
}
portmaster_confirm
