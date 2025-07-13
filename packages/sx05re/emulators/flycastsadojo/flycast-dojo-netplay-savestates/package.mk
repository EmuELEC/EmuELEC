#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present DiegroSan (https://github.com/Diegrosan)
#
#

PKG_NAME="flycast-dojo-netplay-savestates"
PKG_VERSION="CURRENT"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/blueminder/flycast-dojo"
PKG_URL="https://github.com/blueminder/flycast-netplay-savestates/archive/refs/heads/master.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="flycast-dojo netplay savestates "
PKG_TOOLCHAIN="manual"

makeinstall_target() {

  mkdir -p "${INSTALL}/usr/share/flycast-dojo-data"
  
  cp -r "${PKG_BUILD}"/* "${INSTALL}/usr/share/flycast-dojo-data"
}
