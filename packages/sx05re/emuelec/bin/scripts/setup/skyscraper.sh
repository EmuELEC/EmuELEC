#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

if [ ! -L "/storage/.skyscraper" ]; then
ln -sTf /storage/.config/skyscraper /storage/.skyscraper
fi

function scrape_confirm() {
    text_viewer -y -w -t "Skyscraper Launcher" -f 24 -m "This will Kill Emulationstation and will start Skyscraper, do you want to continue?\n\nYou will need a keyboard to be able to use the scraping menu"
    [[ $? == 21 ]] && start_skyscraper || exit 0;
 }

function start_skyscraper() {
ee_console enable
systemd-run bash /usr/bin/scripts/setup/Skyscraper.start
systemctl stop emustation
}

ee_console disable
scrape_confirm

