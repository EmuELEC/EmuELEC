# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="tee_preload_fw"
PKG_VERSION="0.1"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC"
PKG_URL=""
PKG_DEPENDS_TARGET="opentee_linuxdriver"
PKG_LONGDESC="SECPU FW Loader"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    ln -sf /var/lib/teetz ${INSTALL}/usr/lib/teetz
    cp -rP $(get_pkg_directory ${PKG_NAME})/filesystem/. ${INSTALL}
    cp ${PKG_DIR}/scripts/trusted-application-setup ${INSTALL}/usr/sbin
}

post_install() {
  enable_service video-firmware-preload.service
}
