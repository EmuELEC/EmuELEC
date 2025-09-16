# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tvh-dtv-scan-tables"
PKG_VERSION="e3138a506a064f6dfd0639d69f383e8e576609da"
PKG_SHA256="b055e1f91dec43ba268b0feafac1dd23c1ca37613cc429c4be74c0c2606ad253"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/tvheadend"
PKG_URL="https://github.com/tvheadend/dtv-scan-tables/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Digital TV scan tables, a fork from Tvh to support more recent tables."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
  make install DATADIR=${INSTALL}/usr/share
}
