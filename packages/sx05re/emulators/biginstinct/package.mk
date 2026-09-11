# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC Team (https://github.com/EmuELEC/EmuELEC)

PKG_NAME="biginstinct"
PKG_VERSION="101"
PKG_SHA256="5154200ce36c2984224a20e19913246533f08004100430a5abe7a0b1e3a1921a"
PKG_ARCH="aarch64"
PKG_LICENSE="Proprietary"
PKG_SITE="https://www.richwhitehouse.com/ki"
PKG_URL="https://www.richwhitehouse.com/ki/builds/BigInstinct_LinuxARM64_v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="BigInstinct - Killer Instinct Arcade Emulator"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin/biginstinct
  cp -rv ${PKG_BUILD}/* ${INSTALL}/usr/bin/biginstinct/
  chmod +x ${INSTALL}/usr/bin/biginstinct/biginstinct

  cp -f ${PKG_DIR}/scripts/biginstinctstart.sh ${INSTALL}/usr/bin/biginstinctstart.sh
  chmod +x ${INSTALL}/usr/bin/biginstinctstart.sh
}