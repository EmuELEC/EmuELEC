# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="bl30"
PKG_VERSION="02fffaea206644f493e8477bf03ce77e49df58b8"
PKG_SHA256="ff1b0139008ef76045014822bfa67699a0150cc2e7583c071bb5057a619c9c80"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/bl30/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gcc-linaro-aarch64-elf:host gcc-linaro-arm-eabi:host gcc-riscv-none-embed"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

make_target() {
  unset CFLAGS LDFLAGS
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0

  export PATH=${TOOLCHAIN}/lib/gcc7-linaro-aarch64-elf/bin:${TOOLCHAIN}/lib/gcc-riscv-none-embed/bin:${PATH}

  for soc_dir in ${PKG_BUILD}/demos/amlogic/n200/*; do
    if [ -d ${soc_dir} ]; then
      soc="$(basename ${soc_dir})"
      for board in ${PKG_BUILD}/demos/amlogic/n200/${soc}/*; do
        if [ -d ${board} -a -e ${board}/config.mk ]; then
          echo "Start building bl30 blob for" `basename "${board}"`", ${soc^^}"
          /bin/bash mk `basename "${board}"` ${soc}
        fi
      done
    fi
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader/bl30

  find ${PKG_BUILD}/ -name \*.bin -not -path '*/\.*' \
    -exec cp {} ${INSTALL}/usr/share/bootloader/bl30 \;
}
