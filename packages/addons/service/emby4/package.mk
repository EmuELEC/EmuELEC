# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="emby4"
PKG_VERSION="bootstrap"
PKG_REV="0"
PKG_ARCH="any"
PKG_LICENSE="prop."
PKG_SITE="http://emby.media"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="service"
PKG_SHORTDESC="Emby Server: a personal media server"
PKG_LONGDESC="Emby Server brings your home videos, music, and photos together, automatically converting and streaming your media on-the-fly to any device."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Emby Server 4"
PKG_ADDON_TYPE="xbmc.service"
PKG_ADDON_PROJECTS="any !RPi1"
PKG_ADDON_REQUIRES="tools.ffmpeg-tools:0.0.0 tools.dotnet-runtime:0.0.0"
PKG_MAINTAINER="Anton Voyl (awiouy)"

addon() {
  :
}
