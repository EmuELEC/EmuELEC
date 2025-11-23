# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="homatics-leds"
PKG_VERSION="cddb9500cc4085c4aefd56b704f75ebe515d43bf"
PKG_SHA256=""
PKG_REV="3"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/service.homatics-leds"
PKG_URL="https://github.com/CoreELEC/service.homatics-leds/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_SECTION="service"
PKG_SHORTDESC="Homatics LED Kit mode"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Homatics LEDs"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}

  cp ${PKG_BUILD}/LICENSE.txt ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp ${PKG_BUILD}/addon.xml ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp ${PKG_BUILD}/settings-default.xml ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -P ${PKG_BUILD}/README.md ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -P ${PKG_BUILD}/*.py ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -PR ${PKG_BUILD}/resources ${ADDON_BUILD}/${PKG_ADDON_ID}

  # set only version (revision will be added by buildsystem)
  sed -e "s|@ADDON_VERSION@|${ADDON_VERSION}|g" \
      -i ${ADDON_BUILD}/${PKG_ADDON_ID}/addon.xml
}
