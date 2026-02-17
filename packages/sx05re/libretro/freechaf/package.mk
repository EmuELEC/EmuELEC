# SPDX-License-Identifier: GPL-2.0
# EmuELEC / LibreELEC style package for libretro FreeChaF core

PKG_NAME="freechaf"
PKG_VERSION="cdb8ad6fcecb276761b193650f5ce9ae8b878067"
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/FreeChaF"
PKG_URL="${PKG_SITE}.git"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="FreeChaF libretro core (Fairchild Channel F)"
PKG_LONGDESC="FreeChaF is a libretro emulation core for the Fairchild Channel F / Video Entertainment System."

PKG_TOOLCHAIN="make"
PKG_GIT_CLONE_SINGLE="yes"
PKG_MAKE_OPTS_TARGET="platform=unix"

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/freechaf_libretro.so" "${INSTALL}/usr/lib/libretro/"
}
