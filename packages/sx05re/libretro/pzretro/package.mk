# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present

PKG_NAME="pzretro"
PKG_VERSION="6d859b47092f585a7ec05804c1d51a1676a06531"
PKG_ARCH="any"
PKG_LICENSE="see LICENSE"

PKG_SITE="https://github.com/nwhitehead/pzretro"
PKG_URL="${PKG_SITE}.git"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="pzretro libretro core (PuzzleScript)"
PKG_LONGDESC="Libretro core for playing PuzzleScript games using QuickJS."
PKG_TOOLCHAIN="manual"

make_target() {
  make -C "${PKG_BUILD}" platform=unix
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/puzzlescript_libretro.so" \
     "${INSTALL}/usr/lib/libretro/puzzlescript_libretro.so"
}