# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team CoreELEC (https://coreelec.org)

PKG_NAME="RTL8733BS"
PKG_VERSION="4719bf994bc4a80c05cda4cb397ee7a39ecebe15"
PKG_SHA256="9f68fbf73b913ab7bc37750f7076b1cd0793a45f67930875474254d7638e2260"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/newbie-461/RTL8733BS_WiFi_linux_v5.14.1.1-46"
PKG_URL="https://github.com/newbie-461/RTL8733BS_WiFi_linux_v5.14.1.1-46/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Realtek RTL8733BS Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {

  find ${PKG_BUILD} -name "*.cmd" -delete 2>/dev/null || true
  find ${PKG_BUILD} -name ".*.cmd" -delete 2>/dev/null || true
}


make_target() {
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KSRC=$(kernel_path) \
    OUT_DIR= \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}
