# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Team EmuELEC (https://github.com/EmuELEC)

PKG_NAME="x16"
PKG_VERSION="r49"
PKG_SHA256=""
PKG_LICENSE="BSD-2-Clause"
PKG_SITE="https://github.com/X16Community/x16-emulator"
PKG_URL="https://github.com/X16Community/x16-emulator/releases/download/${PKG_VERSION}/x16emu_linux-aarch64-${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Emulator for the Commander X16 8-bit computer"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  unzip -o ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} -d ${PKG_BUILD}/
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/share/x16-emulator
  
  install -m 0755 ${PKG_BUILD}/x16emu ${INSTALL}/usr/bin/
  
  if [ -f ${PKG_BUILD}/rom.bin ]; then
    install -m 0644 ${PKG_BUILD}/rom.bin ${INSTALL}/usr/share/x16-emulator/
  fi
  
  if [ -f ${PKG_BUILD}/sdcard.img ]; then
    install -m 0644 ${PKG_BUILD}/sdcard.img ${INSTALL}/usr/share/x16-emulator/
  fi
  
  install -m 0755 ${PKG_DIR}/scripts/x16emustart.sh ${INSTALL}/usr/bin/
}