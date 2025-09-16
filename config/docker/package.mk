# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="@NAME@"
PKG_VERSION="@VERSION@" # Update bin/docker.@NAME@ accordingly
PKG_REV="100"
PKG_ARCH="@ARCH@"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="docker"
PKG_SITE=""
PKG_SHORTDESC=""
PKG_LONGDESC=""

PKG_IS_ADDON="yes"
PKG_ADDON_NAME=" (@IMAGE@:$PKG_VERSION)"
PKG_ADDON_PROJECTS="@PROJECTS@"
PKG_ADDON_REQUIRES="service.system.docker:0.0.0"
PKG_ADDON_TYPE="xbmc.service"

make_target() {
  : #
}

makeinstall_target() {
  : #
}

addon() {
  : #
}
