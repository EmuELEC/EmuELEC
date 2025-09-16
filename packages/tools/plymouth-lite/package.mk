# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="plymouth-lite"
PKG_VERSION="0.6.0"
PKG_SHA256="fa7b581bdd38c5751668243ff9d2ebaee7c45753358cbb310fb50cfcd3a8081b"
PKG_LICENSE="GPL"
PKG_SITE="http://www.meego.com"
PKG_URL="${DISTRO_SRC}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_INIT="toolchain gcc:init libpng"
PKG_LONGDESC="Boot splash screen based on Fedora's Plymouth code"

pre_configure_init() {
  # plymouth-lite dont support to build in subdirs
  cd ${PKG_BUILD}
    rm -rf .${TARGET_NAME}-init
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/bin
    cp ply-image ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/splash
    find_file_path splash/splash.conf && cp ${FOUND_PATH} ${INSTALL}/splash
     if [ "${DEVICE}" == "OdroidGoAdvance" ]; then
		find_file_path "splash/splash-odroidgoa.png" && cp ${FOUND_PATH} ${INSTALL}/splash/splash-1080.png
    else
		find_file_path "splash/splash-*.png" && cp ${FOUND_PATH} ${INSTALL}/splash
    fi
}
