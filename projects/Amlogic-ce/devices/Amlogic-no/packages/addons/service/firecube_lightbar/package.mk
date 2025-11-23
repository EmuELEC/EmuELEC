# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="firecube_lightbar"
PKG_VERSION="72a5d6180e64e686fc21865f0eaf97cc82fc5eb2"
PKG_SHA256="c5155cc5512ee55dbca2ecfe7522d5e8fe0a07610c895f9489741480e23ea94a"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/service.firecube_lightbar"
PKG_URL="https://github.com/CoreELEC/service.firecube_lightbar/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_SECTION="service"
PKG_SHORTDESC="Fire Cube LED lightbar controller"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Fire Cube Lightbar"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}

  cp -P ${PKG_BUILD}/addon.xml ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -P ${PKG_BUILD}/LICENSE.txt ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -P ${PKG_BUILD}/README.md ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -P ${PKG_BUILD}/*.py ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -PR ${PKG_BUILD}/resources ${ADDON_BUILD}/${PKG_ADDON_ID}

  # set only version (revision will be added by buildsystem)
  sed -e "s|@ADDON_VERSION@|${ADDON_VERSION}|g" \
      -i ${ADDON_BUILD}/${PKG_ADDON_ID}/addon.xml
}
