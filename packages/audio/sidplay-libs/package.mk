# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="sidplay-libs"
PKG_VERSION="2.1.1"
PKG_SHA256="e9a24ada48215a46d2c232a70c5601bc9505e997f120e8f2ba3713e09e28d1f9"
PKG_LICENSE="GPL"
PKG_SITE="http://sidplay2.sourceforge.net/"
PKG_URL="http://mirrors.xbmc.org/build-deps/sources/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="sidplay-libs"
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared --enable-static"

pre_configure_target() {
  # fails to build in subdirs
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}

  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing"
}
