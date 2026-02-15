# SPDX-License-Identifier: Zlib
# LowRes NX (libretro core) for EmuELEC
# Source: https://github.com/timoinutilis/lowres-nx

PKG_NAME="lowresnx"
PKG_VERSION="12aeb16"
PKG_SHA256="c59b1e64e845658aa3baa262e2231a4b28bc98b3be29e9e1f030c31d358e351e"
PKG_LICENSE="Zlib"
PKG_SITE="https://github.com/timoinutilis/lowres-nx"
PKG_URL="https://github.com/timoinutilis/lowres-nx/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="LowRes NX (libretro core)"
PKG_LONGDESC="LowRes NX fantasy console (BASIC) - libretro core."
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="platform=unix"

make_target() {
  make -C platform/LibRetro ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v platform/LibRetro/lowresnx_libretro.so ${INSTALL}/usr/lib/libretro/
}
