# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="script.config.vdr"
PKG_VERSION="dbcdf65f88e8ae80c0b76b26ceeeb489134e6379"
PKG_SHA256="96ee087f69301592211a740c5ea58644254b5642cfb0a1f23e5d68131042997e"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_SITE="https://libreelec.tv"
PKG_URL="https://github.com/LibreELEC/script.config.vdr/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="xmlstarlet:host p7zip:host"
PKG_SECTION=""
PKG_SHORTDESC="script.config.vdr"
PKG_LONGDESC="script.config.vdr"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="dummy"

make_target() {
  sed -e "s|@ADDON_VERSION@|${ADDON_VERSION}|g" \
      -i addon.xml
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp -PR ${PKG_BUILD}/* ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp ${PKG_DIR}/changelog.txt ${ADDON_BUILD}/${PKG_ADDON_ID}
  cp ${PKG_DIR}/icon/icon.png ${ADDON_BUILD}/${PKG_ADDON_ID}/resources
}
