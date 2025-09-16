#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

CUR_MODE=`get_resolution`;

declare -a RES=( ${CUR_MODE} )
SIZE="${RES[0]},${RES[1]},32"

jzintv -f1 -z${RES} -p /storage/roms/bios/ "${1}" --kbdhackfile /emuelec/configs/jzintv_keyb.hack
exit 0
