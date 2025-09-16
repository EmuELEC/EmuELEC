#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)

. /etc/profile

# see https://wiki.archlinux.org/index.php/Power_Management#Hooks_in_.2Fusr.2Flib.2Fsystemd.2Fsystem-sleep

for script in $HOME/.kodi/addons/*/sleep.d/*.power; do
  if [ -f $script ]; then
    progress "running addon sleep script $script ($@)..."
    sh $script $@
  fi
done

exit 0