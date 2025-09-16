# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2011 Gregor Fuis (gujs@openelec.tv)
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pcscd"
PKG_VERSION="1.0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain pcsc-lite libusb ccid"
PKG_SECTION="service"
PKG_SHORTDESC="Middleware to access a smart card using SCard API (PC/SC)"
PKG_LONGDESC="Middleware to access a smart card using SCard API (PC/SC)"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="PC/SC Smart Card Daemon"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/
    cp -Pa $(get_install_dir pcsc-lite)/usr/sbin/pcscd ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/pcscd.bin

  cp -a $(get_install_dir ccid)/storage/.kodi/addons/${PKG_ADDON_ID}/drivers ${ADDON_BUILD}/${PKG_ADDON_ID}

  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/config
    cp -Pa ${PKG_DIR}/config/* ${ADDON_BUILD}/${PKG_ADDON_ID}/config/
}
