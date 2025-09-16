# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="hd-idle"
PKG_VERSION="1.05"
PKG_SHA256="4efefe79d145b50e055582730d9d685e485da3df3dad90fef030036d52aa3a0c"
PKG_LICENSE="GPL"
PKG_SITE="http://hd-idle.sourceforge.net/"
PKG_URL="http://downloads.sourceforge.net/project/hd-idle/${PKG_NAME}-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A utility for spinning-down external disks after a period of idle time."
PKG_BUILD_FLAGS="-sysroot"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
    cp -a ${PKG_BUILD}/hd-idle ${INSTALL}/usr/sbin
}
