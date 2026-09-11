# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present

PKG_NAME="exa-rs"
PKG_VERSION="b1d69b78d2ac2073df1c2ccfe7254e720a4b278e"
PKG_ARCH="any"
PKG_LICENSE="MIT"

PKG_SITE="https://github.com/thieman/exa-rs"
PKG_URL="${PKG_SITE}.git"

PKG_DEPENDS_TARGET="toolchain cargo:host" 
PKG_SECTION="emuelec/libretro"
PKG_SHORTDESC="exa-rs libretro core (TEC Redshift / EXAPUNKS)"
PKG_LONGDESC="Libretro core for the TEC Redshift, the fictional handheld from Zachtronics' EXAPUNKS."
PKG_TOOLCHAIN="manual"

make_target() {
  export RUSTC_LINKER=${CC}
  cargo build --lib --release --target ${TARGET_NAME}
 }

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/lib/libretro"
  
  cp "${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/libexa.so" \
     "${INSTALL}/usr/lib/libretro/exa_libretro.so"
}
