# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opentee_linuxdriver"
PKG_VERSION="3108eb27eb23937c4bc7a0a05e72e2aaf1ae6800"
PKG_SHA256="abafdbe20673635289edbc3c93d903dc7752a52d8a8f78582a738ec09b929ee0"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/opentee_linuxdriver"
PKG_URL="https://github.com/CoreELEC/opentee_linuxdriver/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="OP-TEE Linux Driver and SECPU FW Loader"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/usr/lib/ta
    ln -sf /var/lib/teetz ${INSTALL}/usr/lib/teetz

    for soc in ${TEE_SOC}; do
      cp -rP $(get_pkg_directory ${PKG_NAME})/filesystem/${ARCH}/ta/v3.8/dev/${soc} ${INSTALL}/usr/lib/ta
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
