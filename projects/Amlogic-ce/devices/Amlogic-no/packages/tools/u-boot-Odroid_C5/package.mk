# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="u-boot-Odroid_C5"
PKG_VERSION="5f7ac2b1dc4df2f466ed88c3958a8675873f8a1a"
PKG_SHA256="64f28381394bf22d4d0c21a7a58d299ae462af252c4c1e23de6789298b67d608"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/CoreELEC/u-boot/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gcc7-linaro-aarch64-elf:host gcc-riscv-none-embed:host openssl:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

make_target() {
  unset CFLAGS LDFLAGS
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0

  export PATH=${TOOLCHAIN}/lib/gcc7-linaro-aarch64-elf/bin:${TOOLCHAIN}/lib/gcc-riscv-none-embed/bin:${PATH}

  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- HOSTCFLAGS="-I${TOOLCHAIN}/include" \
    HOSTLDFLAGS="${HOST_LDFLAGS}" CROSS_COMPILE_PATH="" \
    source fip/mk_script.sh s7d_odroidc5 --disable-bl33z --build-nogit
}

makeinstall_target() {
  : # nothing
}
