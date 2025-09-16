# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libconfuse"
PKG_VERSION="3.3"
PKG_SHA256="cb90c06f2dbec971792af576d5b9a382fb3c4ca2b1deea55ea262b403f4e641e"
PKG_LICENSE="ISC"
PKG_SITE="https://github.com/libconfuse/libconfuse"
PKG_URL="https://github.com/libconfuse/libconfuse/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Small configuration file parser library for C"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
