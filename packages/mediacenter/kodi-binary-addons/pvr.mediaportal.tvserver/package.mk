# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pvr.mediaportal.tvserver"
PKG_VERSION="20.3.0-Nexus"
PKG_SHA256="a61efdadb56c65e081f8b2e99f2d5b32b3c932ca1954243548710be57c8b70b8"
PKG_REV="5"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kodi-pvr/pvr.mediaportal.tvserver"
PKG_URL="https://github.com/kodi-pvr/pvr.mediaportal.tvserver/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_SECTION=""
PKG_SHORTDESC="pvr.mediaportal.tvserver"
PKG_LONGDESC="pvr.mediaportal.tvserver"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="xbmc.pvrclient"

pre_configure_target() {
  CXXFLAGS+=" -Wno-narrowing -DXLOCALE_NOT_USED"
}
