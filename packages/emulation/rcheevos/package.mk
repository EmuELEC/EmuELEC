# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rcheevos"
PKG_VERSION="9.2.0"
PKG_SHA256="c8ed6ca74f905ea0c256250e46cced579922880001337e7c3d3d68179ad89d4e"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/RetroAchievements/rcheevos"
PKG_URL="https://github.com/RetroAchievements/rcheevos/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Library to parse and evaluate achievements and leaderboards for RetroAchievements"
PKG_BUILD_FLAGS="+pic"

post_unpack() {
  # rcheevos doesn't come with any build files, use a copy of the cmake file in
  # game.libretro (depends/common/rcheevos/CMakeLists.txt)
  cp "${PKG_DIR}/source/CMakeLists.txt" "${PKG_BUILD}"
}
