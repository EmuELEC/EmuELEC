# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="hdhomerun"
PKG_VERSION="7.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.silicondust.com/products/hdhomerun/dvbt/"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="driver/dvb"
PKG_SHORTDESC="HDHomeRun: a Linux driver to add support for HDHomeRun from silicondust.com"
PKG_LONGDESC="Install this to add support for HDHomeRun devices."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="HDHomeRun"
PKG_ADDON_TYPE="xbmc.python.script"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/config/
  cp -P ${PKG_DIR}/config/* ${ADDON_BUILD}/${PKG_ADDON_ID}/config/
  cp -P ${PKG_DIR}/settings-default.xml ${ADDON_BUILD}/${PKG_ADDON_ID}/
}
