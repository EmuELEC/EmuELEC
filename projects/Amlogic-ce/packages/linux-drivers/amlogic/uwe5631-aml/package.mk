# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="uwe5631-aml"
PKG_VERSION="c9621e32c743ed37bdb54a60f8aa8b329b4bb56f"
PKG_SHA256="19764d9bf428fa480708a767c6bfc9ab755d2559f58e17fed0c3659aa8608b74"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/uwe5631-aml"
PKG_URL="https://github.com/CoreELEC/uwe5631-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="uwe5631-aml: Unisoc UWE5621 WIFI/BT driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  echo "making WIFI"
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KERNEL_SRC=$(kernel_path) \
    EXTRA_CFLAGS="-fno-pic -Wno-sizeof-pointer-memaccess -Wno-declaration-after-statement -I${PKG_BUILD}/BSP/include -DCUSTOMIZE_WIFI_CFG_PATH=\\\"/lib/firmware/unisoc\\\"" \
    modules

  echo "making BT"
  kernel_make -C ${PKG_BUILD}/BT/tty-sdio \
    M=${PKG_BUILD}/BT/tty-sdio \
    KERNEL_SRC=$(kernel_path) \
    CURFOLDER=${PKG_BUILD}/BSP \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' \
    -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/unisoc

  cp -av ${PKG_DIR}/firmware/*.ini \
         ${PKG_BUILD}/BT/libbt/conf/sprd/runtime/*.ini \
         ${PKG_BUILD}/BSP/fw/wcnmodem.bin \
    ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/unisoc
}
