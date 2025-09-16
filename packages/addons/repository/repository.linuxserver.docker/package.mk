# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="repository.linuxserver.docker"
PKG_VERSION="9.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://linuxserver.io"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION=""
PKG_SHORTDESC="LinuxServer.io docker add-on repository"
PKG_LONGDESC="LinuxServer.io docker add-on repository"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="LinuxServer.io Repository"
PKG_ADDON_TYPE="xbmc.addon.repository"

make_target() {
  sed -e "s|@PKG_VERSION@|${PKG_VERSION}|g" \
      -e "s|@PKG_REV@|${PKG_REV}|g" \
      -i addon.xml
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -R ${PKG_BUILD}/* ${ADDON_BUILD}/${PKG_ADDON_ID}
}
