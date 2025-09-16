# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="jellyfin"
PKG_VERSION="1.0"
PKG_VERSION_NUMBER="10.8.10"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://jellyfin.org/"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="Jellyfin: The Free Software Media System"
PKG_LONGDESC="Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media. Stream to any device from your own server."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Jellyfin"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_REQUIRES="tools.ffmpeg-tools:0.0.0 tools.dotnet-runtime:0.0.0"
PKG_ADDON_PROVIDES="executable"

make_target() {
  :
}

addon() {
  :
}

post_install_addon() {
  sed -e "s/@JELLYFIN_VERSION@/${PKG_VERSION_NUMBER}/g" -i "${INSTALL}/bin/jellyfin-downloader"
}
