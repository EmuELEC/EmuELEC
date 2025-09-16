# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="tinyxml"
PKG_VERSION="2.6.2"
PKG_SHA256="8164c9ad48b9028667768a584d62f7760cfbfb90d0dd6214ad174403058da10c"
PKG_LICENSE="OSS"
PKG_SITE="http://www.grinninglizard.com/tinyxml/"
PKG_URL="http://mirrors.xbmc.org/build-deps/sources/${PKG_NAME}-${PKG_VERSION}_2.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="TinyXML is a simple, small, C++ XML parser."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared --with-pic"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr
}
