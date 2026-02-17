# SPDX-License-Identifier: GPL-2.0-or-later
# EmuELEC / LibreELEC package for WASM-4 libretro core

PKG_NAME="wasm4"
PKG_VERSION="68cbe429fcbab3e80537282d2c21566f5ea216ea"
PKG_ARCH="any"
PKG_LICENSE="ISC"
PKG_SITE="https://git.libretro.com/libretro/wasm4"
PKG_URL="${PKG_SITE}.git"
PKG_SHA256=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="WASM-4 libretro core"
PKG_LONGDESC="WASM-4 is a fantasy console based on WebAssembly. This package builds the libretro core (lr-wasm4)."
PKG_IS_ADDON="no"
PKG_TOOLCHAIN="cmake"

PKG_GIT_CLONE_SINGLE="yes"

PKG_CMAKE_OPTS_TARGET="-DLIBRETRO=ON \
                       -DWASM3=ON \
                       -DCMAKE_BUILD_TYPE=Release"

pre_configure_target() {
  PKG_CMAKE_SCRIPT="${PKG_BUILD}/runtimes/native/CMakeLists.txt"
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  cp "${PKG_BUILD}/wasm4_libretro.so" "${INSTALL}/usr/lib/libretro/"
}
