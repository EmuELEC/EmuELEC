# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dtc"
PKG_VERSION="1.6.1"
PKG_SHA256="264d355e2e547a4964d55b83b113f89be1aea5e61dbe0547ab798d0fde2be180"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/utils/dtc/dtc.git/"
PKG_URL="https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The Device Tree Compiler"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="dtc fdtput fdtget libfdt"
PKG_MAKE_OPTS_HOST="dtc fdtput fdtget libfdt"

pre_make_host() {
  mkdir -p ${PKG_BUILD}/.${HOST_NAME}
    cp -a ${PKG_BUILD}/* ${PKG_BUILD}/.${HOST_NAME}

  cd ${PKG_BUILD}/.${HOST_NAME}
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -P ${PKG_BUILD}/.${HOST_NAME}/dtc ${TOOLCHAIN}/bin
    cp -P ${PKG_BUILD}/.${HOST_NAME}/fdtput ${TOOLCHAIN}/bin
    cp -P ${PKG_BUILD}/.${HOST_NAME}/fdtget ${TOOLCHAIN}/bin
  mkdir -p ${TOOLCHAIN}/lib
    cp -P ${PKG_BUILD}/.${HOST_NAME}/libfdt/{libfdt.so,libfdt.so.1} ${TOOLCHAIN}/lib
}

pre_make_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
    cp -a ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}

  cd ${PKG_BUILD}/.${TARGET_NAME}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -P ${PKG_BUILD}/.${TARGET_NAME}/dtc ${INSTALL}/usr/bin
    cp -P ${PKG_BUILD}/.${TARGET_NAME}/fdtput ${INSTALL}/usr/bin/
    cp -P ${PKG_BUILD}/.${TARGET_NAME}/fdtget ${INSTALL}/usr/bin/
  mkdir -p ${INSTALL}/usr/lib
    cp -P ${PKG_BUILD}/.${TARGET_NAME}/libfdt/{libfdt.so,libfdt.so.1} ${INSTALL}/usr/lib/
}
