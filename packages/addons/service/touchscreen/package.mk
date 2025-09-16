# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="touchscreen"
PKG_VERSION="1.0"
PKG_REV="0"
PKG_ARCH="any"
PKG_ADDON_PROJECTS="Generic RPi ARM"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain tslib evtest"
PKG_SECTION="service"
PKG_SHORTDESC="Touchscreen: support addon for Touchscreens"
PKG_LONGDESC="Touchscreen: addon creates new virtual input device and \
converts data from touchscreen to Kodi. Short tap sends button press event \
and long tap sends only xy coordinates. Also includes calibration program."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Touchscreen"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

  cp ${PKG_DIR}/addon.xml ${ADDON_BUILD}/${PKG_ADDON_ID}

  # set only version (revision will be added by buildsystem)
  sed -e "s|@ADDON_VERSION@|${ADDON_VERSION}|g" \
      -i ${ADDON_BUILD}/${PKG_ADDON_ID}/addon.xml

  cp $(get_install_dir tslib)/usr/bin/* ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  cp $(get_install_dir evtest)/usr/bin/evtest ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
}
