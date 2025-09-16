# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libugpio"
PKG_VERSION="0.0.7"
PKG_SHA256="4f486b36d87da070cb3afbe8d077081b27f670cb4cb67698d1b79740b6e604b3"
PKG_LICENSE="LGPLv2.1"
PKG_SITE="https://github.com/mhei/libugpio"
PKG_URL="https://github.com/mhei/${PKG_NAME}/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux:host"
PKG_LONGDESC="A software library to ease the use of linux kernel's sysfs gpio interface from C programs and/or other libraries."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
