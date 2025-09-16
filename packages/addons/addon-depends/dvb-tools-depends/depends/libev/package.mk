# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libev"
PKG_VERSION="4.33"
PKG_SHA256="507eb7b8d1015fbec5b935f34ebed15bf346bed04a11ab82b8eee848c4205aea"
PKG_LICENSE="GPL"
PKG_SITE="http://software.schmorp.de/pkg/libev.html"
PKG_URL="http://dist.schmorp.de/libev/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A full-featured and high-performance event loop."

PKG_CONFIGURE_OPTS_TARGET="--disable-shared \
                           --enable-static"
