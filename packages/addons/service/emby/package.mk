# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="emby"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="Add-on removed"
PKG_LONGDESC="Add-on removed"
PKG_TOOLCHAIN="manual"

PKG_ADDON_BROKEN="Emby Server is no longer maintained and has been superseded by Emby Server 4"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Emby Server"
PKG_ADDON_TYPE="xbmc.broken"

addon() {
  :
}
