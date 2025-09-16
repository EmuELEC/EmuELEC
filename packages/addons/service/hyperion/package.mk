# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Lukas Rusak (lrusak@libreelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="hyperion"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="Hyperion: Add-on removed"
PKG_LONGDESC="Hyperion: Add-on removed"
PKG_TOOLCHAIN="manual"

PKG_ADDON_BROKEN="Hyperion Classic has been discontinued. Please go to Hyperion.NG (Next Generation)"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Hyperion"
PKG_ADDON_TYPE="xbmc.broken"

addon() {
  :
}
