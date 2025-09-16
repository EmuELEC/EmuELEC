#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

 if pgrep -x "/usr/bin/emulationstation" > /dev/null
  then
    killall -9 emulationstation
  fi

 exit 0
