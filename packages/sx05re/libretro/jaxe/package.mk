# SPDX-License-Identifier: GPL-2.0-or-later
# EmuELEC / LibreELEC package for JAXE libretro core

PKG_NAME="jaxe"
PKG_VERSION="4825aad24716f67924cd949354aae490a14b4d2d"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/kurtjd/jaxe"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="main"
PKG_GIT_CLONE_DEPTH="1"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="JAXE CHIP-8/S-CHIP/XO-CHIP libretro core"
PKG_LONGDESC="JAXE is a CHIP-8 / S-CHIP / XO-CHIP emulator with a libretro frontend."

PKG_TOOLCHAIN="make"

post_unpack() {
  cd "${PKG_BUILD}"
  git submodule update --init --recursive
}

make_target() {
  cd "${PKG_BUILD}"

  make -f Makefile.libretro \
    CC="${CC}" \
    CXX="${CXX}" \
    AR="${AR}" \
    RANLIB="${RANLIB}" \
    platform=unix
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/jaxe_libretro.so" "${INSTALL}/usr/lib/libretro/"
}
