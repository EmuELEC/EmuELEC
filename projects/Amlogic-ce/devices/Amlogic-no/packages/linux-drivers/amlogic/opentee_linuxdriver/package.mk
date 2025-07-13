# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opentee_linuxdriver"
PKG_VERSION="0.1"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="OP-TEE SECPU FW Loader"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/ta
    ln -sf /var/lib/optee_armtz ${INSTALL}/usr/lib/optee_armtz

    for soc in ${TEE_SOC}; do
      DIRSOC="$(get_pkg_directory ${PKG_NAME})/filesystem/${ARCH}/ta/v3.8/dev/${soc}"
      [ -d ${DIRSOC} ] && cp -rP ${DIRSOC} ${INSTALL}/usr/lib/ta
    done

  mkdir -p ${INSTALL}/usr/lib/coreelec
    install -m 0755 ${PKG_DIR}/scripts/tee-loader.sh ${INSTALL}/usr/lib/coreelec/tee-loader
    install -m 0755 ${PKG_DIR}/scripts/dovi-loader.sh ${INSTALL}/usr/lib/coreelec/dovi-loader

  cp -rP $(get_pkg_directory ${PKG_NAME})/filesystem/${ARCH}/usr ${INSTALL}
}

post_install() {
  enable_service opentee_linuxdriver.service

  # create mount points for Android partitions
  # must be /vendor because .ta file is used by absolute path
  mkdir -p ${INSTALL}/android/odm
  mkdir -p ${INSTALL}/android/oem
  mkdir -p ${INSTALL}/android/system
  mkdir -p ${INSTALL}/android/vendor
  ln -sf /android/system/system ${INSTALL}/system
  ln -sf /android/vendor ${INSTALL}/vendor
}
