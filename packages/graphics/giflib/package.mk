# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="giflib"
PKG_VERSION="5.2.1"
PKG_SHA256="31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd"
PKG_LICENSE="OSS"
PKG_SITE="http://giflib.sourceforge.net/"
PKG_URL="${SOURCEFORGE_SRC}/giflib/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="zlib:host"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="giflib: giflib service library"
PKG_TOOLCHAIN="manual"

make_host() {
  make libgif.a CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

makeinstall_host() {
  make install-include PREFIX="${TOOLCHAIN}"
  make install-lib PREFIX="${TOOLCHAIN}"
}
