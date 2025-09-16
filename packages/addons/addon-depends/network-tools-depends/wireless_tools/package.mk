# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wireless_tools"
PKG_VERSION="30.pre9"
PKG_SHA256="abd9c5c98abf1fdd11892ac2f8a56737544fe101e1be27c6241a564948f34c63"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/HewlettPackard/wireless-tools"
PKG_URL="https://hewlettpackard.github.io/wireless-tools/${PKG_NAME}.${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The Wireless Tools (WT) is a set of tools allowing to manipulate the Wireless Extensions."
PKG_BUILD_FLAGS="-sysroot"

make_target() {
  make PREFIX=/usr CC="${CC}" AR="${AR}" \
    CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" iwmulticall
}

makeinstall_target() {
  make PREFIX=${INSTALL}/usr install-iwmulticall
}
