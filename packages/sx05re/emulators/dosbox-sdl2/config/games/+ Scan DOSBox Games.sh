#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2020-present Sylvia van Os (https://github.com/TheLastProject)

EE_DEVICE=$(cat /ee_arch)

source /usr/bin/env.sh
rp_registerAllModules

joy2keyStart

function restart_confirm() {
    if dialog --ascii-lines --yesno "DOSBox scan completed, any found games will appear next time you restart Emulationstation, do you want to restart it now?"  22 76 >/dev/tty; then
        systemctl restart emustation
    fi

    if [ "${EE_DEVICE}" == "OdroidGoAdvance" ]; then
        killall kmscon
    fi
}

function create_launcher() {
    launcher_name="${1} (${2})"

    dos_dirname="${1:0:6}~1"

    mkdir -p "/storage/roms/pc/${launcher_name}"
    cp /storage/.config/dosbox/dosbox-SDL2.conf "/storage/roms/pc/${launcher_name}"
    echo "mount c /storage/roms/pcdata" >> "/storage/roms/pc/${launcher_name}/dosbox-SDL2.conf"
    echo "c:" >> "/storage/roms/pc/${launcher_name}/dosbox-SDL2.conf"
    echo "cd ${dos_dirname}" >> "/storage/roms/pc/${launcher_name}/dosbox-SDL2.conf"
    echo "${2}" >> "/storage/roms/pc/${launcher_name}/dosbox-SDL2.conf"
    echo "exit" >> "/storage/roms/pc/${launcher_name}/dosbox-SDL2.conf"

    touch "/storage/roms/pc/${launcher_name}/${launcher_name}.bat"
}

for data_dir in /storage/roms/pcdata/*; do
    if [ -d "${data_dir}" ]; then
        for executable in $(find "${data_dir}" -iname "*.exe"); do
            executable_case="$(basename ${executable} | tr '[:lower:]' '[:upper:]')"
            case "${executable_case}" in
                "SETUP.EXE" | "INSTALL.EXE" | "INSTALLER.EXE")
                    ;;
                *)
                    create_launcher "$(basename ${data_dir})" "$(basename ${executable})"
                    ;;
            esac
        done
    fi
done
restart_confirm
