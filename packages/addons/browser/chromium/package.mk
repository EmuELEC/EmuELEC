# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="chromium"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="browser"
PKG_SHORTDESC="Add-on removed"
PKG_LONGDESC="Add-on removed"
PKG_TOOLCHAIN="manual"

PKG_ADDON_BROKEN="Chromium is no longer maintained and has been superseded by Chrome."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Chromium"
PKG_ADDON_TYPE="xbmc.broken"

addon() {
  :
}
