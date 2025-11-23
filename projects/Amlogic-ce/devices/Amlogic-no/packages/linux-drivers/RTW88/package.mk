# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTW88"
PKG_VERSION="52072d874840f28c247b27f5d799f2c5c88a7e61"
PKG_SHA256="079fc2630d01d8d922c9a83c3d162bfda041e71e799c4b573b01cf4f4428ce06"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lwfinger/rtw88"
PKG_URL="https://github.com/lwfinger/rtw88/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Latest Realtek WiFi 5 Codes on Linux"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {

  find ${PKG_BUILD} -name "*.cmd" -delete 2>/dev/null || true
  find ${PKG_BUILD} -name ".*.cmd" -delete 2>/dev/null || true
}


make_target() {
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KSRC=$(kernel_path)
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
