# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mpd-mpc"
PKG_VERSION="0.34"
PKG_SHA256="691e3f3654bc10d022bb0310234d0bc2d8c075a698f09924d9ebed8f506fda20"
PKG_LICENSE="GPL"
PKG_SITE="https://www.musicpd.org"
PKG_URL="https://www.musicpd.org/download/mpc/0/mpc-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libiconv libmpdclient"
PKG_LONGDESC="Command-line client for MPD."
PKG_BUILD_FLAGS="-sysroot"
