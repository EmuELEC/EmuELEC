# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mu"
PKG_VERSION="63f7f08f72d4ee6a0df1573ed68e6a3d46d6335f"
PKG_LICENSE="CC BY-NC 3.0"
PKG_SITE="https://github.com/libretro/Mu"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Palm m515 emulator ported to libretro."
PKG_TOOLCHAIN="make"

make_target() {
  make -C ${PKG_BUILD}/libretroBuildSystem
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/libretroBuildSystem/mu_libretro.so ${INSTALL}/usr/lib/libretro/
}