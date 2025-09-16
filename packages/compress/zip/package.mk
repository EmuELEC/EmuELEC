# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="zip"
PKG_VERSION="3.0"
PKG_SHA256="f0e8bb1f9b7eb0b01285495a2699df3a4b766784c1765a8f1aeedf63c0806369"
PKG_LICENSE="Info-ZIP"
PKG_SITE="http://www.info-zip.org/pub/infozip/"
PKG_URL="${SOURCEFORGE_SRC}/infozip/Zip%203.x%20%28latest%29/3.0/${PKG_NAME}${PKG_VERSION/./}.tar.gz"
PKG_DEPENDS_TARGET="toolchain bzip2"
PKG_LONGDESC="A compression and file packaging utility."
PKG_TOOLCHAIN="manual"

make_target() {
  make CC=${CC} CPP=${CPP} RANLIB=${RANLIB} AR=${AR} STRIP=${STRIP} LOCAL_ZIP="${CFLAGS}" \
       -f unix/Makefile generic
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp zip ${INSTALL}/usr/bin
    ${STRIP} ${INSTALL}/usr/bin/zip
}
