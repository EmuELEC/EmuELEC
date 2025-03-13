# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="u-boot-Khadas_VIM4"
PKG_VERSION="be24ec376835d55d8897161c69ad21dbab50ca30"
PKG_SHA256="36e02b0c607dcfd11949b3c85fa9d629f1d184e7d2835cb3668e4cc0e793a894"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/CoreELEC/u-boot/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gcc7-linaro-aarch64-elf:host gcc-riscv-none-embed:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

make_target() {
  unset CFLAGS LDFLAGS
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0

  export PATH=${TOOLCHAIN}/lib/gcc7-linaro-aarch64-elf/bin:${TOOLCHAIN}/lib/gcc-riscv-none-embed/bin:${PATH}

  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- ARCH=arm make kvim4_defconfig
  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- ARCH=arm make HOSTCC="${HOST_CC}" HOSTSTRIP="true"

  source fip/mk_script.sh kvim4 ${PKG_BUILD}
}

makeinstall_target() {
  : # nothing
}
