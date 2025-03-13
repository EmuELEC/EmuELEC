# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Team EmuELEC (https://emuelec.org)

PKG_NAME="beetle-saturn"
PKG_VERSION="a3f853a89157a6d562072dac9fc74c86bb3a6e54"
#PKG_SHA256="b8a7a359c490607187f2dd2ca49af3463731d3816a0b4411aab49dbc2abdc71e"
PKG_GIT_CLONE_BRANCH="libchdr-update"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/sonninnos/beetle-saturn-libretro/"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC=" Standalone  hard fork of Mednafen Saturn to the libretro API.  "
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="+speed" 
CXXFLAGS="-O3 -march=armv8-a+crc+fp+simd -mtune=cortex-a73.cortex-a53 -flto"

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp mednafen_saturn_*.so $INSTALL/usr/lib/libretro/
}
