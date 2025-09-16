# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="game.libretro"
PKG_VERSION="20.2.6-Nexus"
PKG_SHA256="32b24c0d67046e41d703c70a432ba8209163bafc8ca88afc8181be4d6693efb4"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kodi-game/game.libretro"
PKG_URL="https://github.com/kodi-game/game.libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain tinyxml kodi-platform libretro-common rcheevos"
PKG_SECTION=""
PKG_LONGDESC="game.libretro is a thin wrapper for libretro"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="kodi.gameclient"
