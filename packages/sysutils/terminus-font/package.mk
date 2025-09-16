# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Matthias Reichl <hias@horus.com>

PKG_NAME="terminus-font"
PKG_VERSION="4.49.1"
PKG_SHA256="d961c1b781627bf417f9b340693d64fc219e0113ad3a3af1a3424c7aa373ef79"
PKG_LICENSE="OFL1_1"
PKG_SITE="http://terminus-font.sourceforge.net"
PKG_URL="https://downloads.sourceforge.net/project/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION:0:4}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_INIT="toolchain Python3:host"
PKG_LONGDESC="This package contains the Terminus Font"
PKG_TOOLCHAIN="manual"

pre_configure_init() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}-${TARGET}
}

configure_init() {
  ./configure INT=${TOOLCHAIN}/bin/python3
}

make_init() {
  make ter-v32b.psf
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/share/consolefonts
    cp ter-v32b.psf ${INSTALL}/usr/share/consolefonts
}
