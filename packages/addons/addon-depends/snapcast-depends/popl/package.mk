# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="popl"
PKG_VERSION="1.3.0"
PKG_SHA256="7c59554371da3c6c093bd79c2f403f921c1938bd523f1a48682352e0d92883a6"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/badaix/popl"
PKG_URL="https://github.com/badaix/popl/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Header-only C++ program options parser library."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/include
  cp -p ${PKG_BUILD}/include/popl.hpp ${INSTALL}/usr/include
}
