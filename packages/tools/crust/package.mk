# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="crust"
PKG_VERSION="2e5f355790b5f9cd941f939280adda6b4b6581c0" # 2021-11-05
PKG_SHA256="6e449dfc870141498082d399d5712fa53bb9e6341856e0a75fd9aaad9e15c38c"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD-3c"
PKG_SITE="https://github.com/crust-firmware/crust"
PKG_URL="https://github.com/crust-firmware/crust/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Crust: Libre SCP firmware for Allwinner sunxi SoCs"
PKG_TOOLCHAIN="manual"
PKG_STAMP="${UBOOT_SYSTEM}"

if [ ! -z "${UBOOT_SYSTEM}" ]; then
  PKG_DEPENDS_TARGET="gcc-or1k:host"
fi

pre_configure_target() {
  export CROSS_COMPILE="or1k-none-elf-"
}

make_target() {
  if [ -z "${UBOOT_SYSTEM}" ]; then
    echo "crust is only built when building an image"
    exit 0
  fi

  CRUST_CONFIG=$(${ROOT}/${SCRIPTS}/uboot_helper ${PROJECT} ${DEVICE} ${UBOOT_SYSTEM} crust_config)
  if [ -z "${CRUST_CONFIG}" ]; then
    echo "crust_config must be set to build crust firmware"
    echo "see './scripts/uboot_helper' for more information"
    exit 0
  fi

  make distclean
  if [ "${BUILD_WITH_DEBUG}" = "yes" ]; then
    echo "CONFIG_DEBUG_LOG=y" >> configs/${CRUST_CONFIG}
  else
    echo "CONFIG_SERIAL=n" >> configs/${CRUST_CONFIG}
  fi
  # Boards with a PMIC need to disable CONFIG_PMIC_SHUTDOWN to get CIR wakeup from suspend
  echo "CONFIG_PMIC_SHUTDOWN=n" >> configs/${CRUST_CONFIG}
  echo "CONFIG_CIR=y" >> configs/${CRUST_CONFIG}
  echo "CONFIG_CEC=y" >> configs/${CRUST_CONFIG}
  make ${CRUST_CONFIG} BUILDCC=host-gcc
  make scp
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
  cp -a build/scp/scp.bin ${INSTALL}/usr/share/bootloader
}
