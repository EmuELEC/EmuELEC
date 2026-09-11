# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/EmuELEC/EmuELEC)

PKG_NAME="native32emu"
PKG_VERSION="50a900f9e440cdc90a9dedb091a03513d6785366"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/jiangxincode/Native32Emu"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain rust cargo"
PKG_LONGDESC="Native32 game emulator (libretro core) for Sunplus DVD-player games"
PKG_TOOLCHAIN="manual"
PKG_SECTION="emuelec/libretro"

make_target() {
  cargo build --lib --release --target ${TARGET_NAME}
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"

  cp "${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/libnative32emu.so" \
     "${INSTALL}/usr/lib/libretro/native32emu_libretro.so"
}

