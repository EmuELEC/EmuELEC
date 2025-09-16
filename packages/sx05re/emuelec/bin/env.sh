#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

export TERM="xterm"
export TERMINFO="/usr/share/terminfo"
export TERMINFO_DIRS=${TERMINFO}
export LANG="C.UTF-8"
export HOME="/storage"
export romdir="/storage/roms/"
# export configdir="/usr/bin/scripts"
export scriptdir="/usr/bin/scripts"
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/emuelec/lib
export PATH=${PATH}:/emuelec/bin:/emuelec/scripts

user="root"
rootdir="/emuelec"
home="/storage"
romdir="${home}/roms"
biosdir="${romdir}/BIOS"
datadir="${home}/.config/emuelec/RetroPie"
emudir="${rootdir}/emulators"
configdir="${rootdir}/configs"
__logdir="${scriptdir}/logs"
__tmpdir="/tmp"
__builddir="${__tmpdir}/build"
__swapdir="${__tmpdir}"
__backtitle="EmuELEC - Configuration"

source "${scriptdir}/scriptmodules/system.sh"
source "${scriptdir}/scriptmodules/helpers.sh"
source "${scriptdir}/scriptmodules/inifuncs.sh"
source "${scriptdir}/scriptmodules/packages.sh"

cat /etc/motd
echo "Loading...Please Wait!"
