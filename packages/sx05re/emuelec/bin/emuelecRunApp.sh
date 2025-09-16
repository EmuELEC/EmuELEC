#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2024-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

arguments="$@"

# Extract the platform name from the arguments
PLATFORM="${arguments##*-P}"  # read from -P onwards
PLATFORM="${PLATFORM%% *}"  # until a space is found

ROMNAME="${1}"

init_game
emuelec-utils init_app_video "${PLATFORM}" "${ROMNAME}"

"$@"

emuelec-utils end_app_video
end_game