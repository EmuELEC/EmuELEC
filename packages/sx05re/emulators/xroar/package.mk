# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="xroar"
PKG_VERSION="2025-07-16"
PKG_SHA256="25731a74cc9d5888b318c7b6be2dcf981b37cc95138e3dcf4c4d91402544faea"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/PortsMaster/PortMaster-New"
PKG_URL="https://github.com/PortsMaster/PortMaster-New/releases/download/2025-07-16_2108/xroar.zip"
PKG_SOURCE_NAME="xroar.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="XRoar - Dragon/CoCo Emulator"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  unzip -q ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} -d ${PKG_BUILD}
  
  if [ -d "${PKG_BUILD}/xroar" ]; then
    mv ${PKG_BUILD}/xroar/* ${PKG_BUILD}/
    rmdir ${PKG_BUILD}/xroar
  fi
}

makeinstall_target() {

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/xroar.aarch64 ${INSTALL}/usr/bin/xroar.aarch64
  chmod +x ${INSTALL}/usr/bin/xroar.aarch64
  
  cp ${PKG_DIR}/scripts/xroar.sh ${INSTALL}/usr/bin/xroar.sh
  chmod +x ${INSTALL}/usr/bin/xroar.sh
  
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/xroar
  cp -r ${PKG_BUILD}/libs.aarch64 ${INSTALL}/usr/config/emuelec/configs/xroar/
  cp -r ${PKG_BUILD}/gptk ${INSTALL}/usr/config/emuelec/configs/xroar/
  cp ${PKG_BUILD}/xroar.conf ${INSTALL}/usr/config/emuelec/configs/xroar/
  cp -r ${PKG_BUILD}/fonts ${INSTALL}/usr/config/emuelec/configs/xroar/
}