# SPDX-License-Identifier: GPL-2.0-or-later

# EmuELEC package for ep128emu libretro core

PKG_NAME="ep128emu"
PKG_VERSION="a9e857e70466f95cfd54b4e5f2b30453b581e822"
PKG_LICENSE="GPL-2.0-only"
PKG_SITE="https://github.com/libretro/ep128emu-core"
PKG_URL="${PKG_SITE}.git"

PKG_ARCH="any"
PKG_SECTION="emuelec/libretro"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Enterprise 64/128 (ep128emu) libretro core"
PKG_LONGDESC="Libretro core version of ep128emu, emulating Enterprise 64/128, Videoton TVC, Amstrad CPC and ZX Spectrum home computers."
PKG_TOOLCHAIN="make"
PKG_GIT_CLONE_BRANCH="core"

pre_make_target() {
  :
}

make_target() {
  make -C "${PKG_BUILD}" \
    CC="${CC}" \
    CXX="${CXX}" \
    AR="${AR}"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/ep128emu_core_libretro.so" \
     "${INSTALL}/usr/lib/libretro/"
}
