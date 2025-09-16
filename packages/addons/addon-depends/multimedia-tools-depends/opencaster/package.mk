# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="opencaster"
PKG_VERSION="3.2.2"
PKG_SHA256="c9d77f98b31d53f521e3179003a9cb66b0586704717e9d401f3bc0dafa243865"
PKG_LICENSE="GPL"
PKG_SITE="http://www.avalpa.com/the-key-values/15-free-software/33-opencaster"
PKG_URL="http://ftp.de.debian.org/debian/pool/main/o/opencaster/opencaster_${PKG_VERSION}+dfsg.orig.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="A free and open source MPEG2 transport stream data generator and packet manipulator."
PKG_BUILD_FLAGS="-sysroot"

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="CC=${CC}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  make install DESTDIR=${INSTALL}/usr/bin
}
