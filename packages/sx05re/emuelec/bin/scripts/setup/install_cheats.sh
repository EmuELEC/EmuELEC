#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later

# Source predefined functions and variables
. /etc/profile

function cheats_confirm() {
    text_viewer -y -w -t "Install Cheats" -f 24 -m "This will install Retroarch Cheats\n\nNOTE: You need to have an active internet connection and you will need to restart ES after this script ends, continue?"
        if [[ $? == 21 ]]; then
            if cheats; then
                text_viewer -w -t "Install Retroarch Cheats Complete!" -f 24 -m "Retroarch Cheats installation is done!"
            else
                text_viewer -e -w -t "Install Cheats FAILED!" -f 24 -m "Retroarch Cheats installation was not completed!, Are you sure you are connected to the internet?"
            fi
      fi
    ee_console disable
 }

function cheats() {
ee_console enable


LINK="http://buildbot.libretro.com/assets/frontend/cheats.zip"

LINKDEST="/tmp/database/cht/cheats.zip"

wget -O ${LINKDEST} ${LINK}

[[ ! -f ${LINKDEST} ]] && return 1
unzip -o "${LINKDEST}" -d "/tmp/database/cht"  
rm -rf ${LINKDEST}

echo "Done, restart ES"
ee_console disable
rm /tmp/display > /dev/null 2>&1
return 0
}
cheats_confirm