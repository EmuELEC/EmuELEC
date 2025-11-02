# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="homatics-leds"
PKG_VERSION="0.1"
PKG_SHA256=""
PKG_REV="2"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="Homatics LED Kit mode"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Homatics LEDs"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/resources

  cp ${PKG_DIR}/LICENSE.txt ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp ${PKG_DIR}/addon.xml ${ADDON_BUILD}/${PKG_ADDON_ID}

  # set only version (revision will be added by buildsystem)
  sed -e "s|@ADDON_VERSION@|${ADDON_VERSION}|g" \
      -i ${ADDON_BUILD}/${PKG_ADDON_ID}/addon.xml
}
