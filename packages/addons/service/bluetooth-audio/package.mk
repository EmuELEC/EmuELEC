# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bluetooth-audio"
PKG_VERSION="0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="bluetooth-audio: Add-on removed"
PKG_LONGDESC="bluetooth-audio: Add-on removed"
PKG_TOOLCHAIN="manual"

PKG_ADDON_BROKEN="Add-on removed as the bluetooth audio auto connect is handled by CoreELEC settings."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Bluetooth Audio Device Changer"
PKG_ADDON_TYPE="xbmc.broken"

addon() {
  :
}
