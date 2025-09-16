# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="zvbi"
PKG_VERSION="0.2.35"
PKG_SHA256="fc883c34111a487c4a783f91b1b2bb5610d8d8e58dcba80c7ab31e67e4765318"
PKG_LICENSE="GPL2"
PKG_SITE="http://zapping.sourceforge.net/ZVBI"
PKG_URL="https://downloads.sourceforge.net/sourceforge/zapping/zvbi-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libpng zlib"
PKG_LONGDESC="Library to provide functions to capture and decode VBI data."

PKG_CONFIGURE_OPTS_TARGET="--disable-dvb \
                           --disable-bktr \
                           --disable-nls \
                           --disable-proxy \
                           --without-doxygen \
                           --without-x"
