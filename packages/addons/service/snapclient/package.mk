# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="snapclient"
PKG_VERSION="0.27.0"
PKG_REV="2"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain alsa-plugins snapcast"
PKG_SECTION="service"
PKG_SHORTDESC="Snapclient: Synchronous multi-room audio client"
PKG_LONGDESC="Snapclient (${PKG_VERSION}) is a Snapcast client. Snapcast is a multi-room client-server audio system, where all clients are time synchronized with the server to play perfectly synced audioplays."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Snapclient"
PKG_ADDON_TYPE="xbmc.service.library"
PKG_MAINTAINER="Anton Voyl (awiouy)"

addon() {
  mkdir -p "${ADDON_BUILD}/${PKG_ADDON_ID}/bin"
  cp "$(get_install_dir snapcast)/usr/bin/snapclient" \
     "${ADDON_BUILD}/${PKG_ADDON_ID}/bin"

  mkdir -p "${ADDON_BUILD}/${PKG_ADDON_ID}/lib"
  cp "$(get_install_dir alsa-plugins)/usr/lib/alsa"/*.so \
     "${ADDON_BUILD}/${PKG_ADDON_ID}/lib"
}
