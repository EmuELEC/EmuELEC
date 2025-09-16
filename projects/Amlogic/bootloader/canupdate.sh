#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

# detect legacy kernel installs and abort to prevent upgrades
case $(uname -r) in
  3.14*|4.9*)
    echo "Updates from Amlogic vendor kernels are not supported!"
    sleep 10
    exit 1
    ;;
esac

# allow upgrades between aarch64 and arm images
PROJECT=$("$1" | cut -d. -f1)
if [ "$1" = "${PROJECT}.aarch64" -o "$1" = "${PROJECT}.arm" ]; then
  exit 0
else
  exit 1
fi
