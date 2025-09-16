# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="exfat-linux"
PKG_VERSION="29fdcd25f82439e49d03ed2d5c7d0fd0906f3cb8"
PKG_SHA256="15d5bff755733442546aec119d7a05e2166af2d034ff0698677e914efe35e1d6"
PKG_SITE="https://github.com/arter97/exfat-linux"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="exFAT filesystem module for Linux kernel, for extraction in linux package only, DO NOT BUILD"
PKG_TOOLCHAIN="manual"

unpack() {
  # This package should not be built, and should not be unpacked to the build dir
  :
}
