# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Arthur Liberman (arthur_liberman@hotmail.com)

PKG_NAME="openvfd"
PKG_VERSION="1.0.6"
PKG_SHA256="e531781921dbea3bed52304ccbf8722d85fc2141abeda11a0a2f405ecf7ff8b9"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/arthur-liberman/service.openvfd"
PKG_URL="https://github.com/arthur-liberman/service.openvfd/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="OpenVFD: Service for controlling VFD displays"
PKG_LONGDESC="OpenVFD: Service for controlling VFD displays, e.g. Display icons (Ethernet/WiFi connection status) Time, Date, Playback time"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="xbmc.service"

addon() {
  mkdir -p $ADDON_BUILD/$PKG_ADDON_ID
    cp -PR $PKG_BUILD/* $ADDON_BUILD/$PKG_ADDON_ID
}
