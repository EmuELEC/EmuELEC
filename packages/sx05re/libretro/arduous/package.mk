# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present

PKG_NAME="arduous"
PKG_VERSION="798e3950f1de7c69455bc988d55eafeebac5a1eb"
PKG_ARCH="any"
PKG_LICENSE="GPL-3.0-or-later"

PKG_SITE="https://github.com/libretro/arduous"
PKG_URL="${PKG_SITE}.git"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="Arduous libretro core (Arduboy)"
PKG_LONGDESC="Arduous is a libretro emulator core for the Arduboy."
PKG_TOOLCHAIN="cmake"

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"

  if [ -f "${PKG_BUILD}/.${TARGET_NAME}/arduous_libretro.so" ]; then
    cp "${PKG_BUILD}/.${TARGET_NAME}/arduous_libretro.so" "${INSTALL}/usr/lib/libretro/"
  else
    cp "${PKG_BUILD}/arduous_libretro.so" "${INSTALL}/usr/lib/libretro/"
  fi
}
