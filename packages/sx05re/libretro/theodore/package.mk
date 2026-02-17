# SPDX-License-Identifier: GPL-3.0-only

# EmuELEC package for Theodore libretro core (Thomson MO/TO)

PKG_NAME="theodore"
PKG_VERSION="3.1"
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="GPL-3.0-only"
PKG_SITE="https://github.com/Zlika/theodore"
PKG_URL="https://github.com/Zlika/theodore/archive/v3.1/theodore-3.1.tar.gz"
PKG_SOURCE_DIR="theodore-${PKG_VERSION}"

PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="Theodore Thomson MO/TO libretro core"
PKG_LONGDESC="Theodore is a libretro core for emulation of Thomson MO/TO computers (TO7, TO8, MO5, MO6, etc.)."
PKG_TOOLCHAIN="make"

configure_target() {
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
  cp "${PKG_BUILD}/theodore_libretro.so" \
     "${INSTALL}/usr/lib/libretro/"
}
