# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

PKG_NAME="openmsx-ld"
PKG_VERSION="e78b9ff6b4fc61c87489a7c1fa65214a37ab24dd"
PKG_SHA256="8dbd47491cd2a8e92e4125013d12d9e9903df81e5e67bdb01bc2bb5bb06d4b9f"
PKG_REV="0"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/worstcase-scenario/openMSX"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf libpng zlib tcl alsa-lib glew libogg libvorbis libtheora"
PKG_SHORTDESC="openMSX Laserdisc: Pioneer PX-7 emulation for Palcom LaserDisc games"
PKG_TOOLCHAIN="manual"

PKG_MAKE_OPTS_TARGET="OPENMSX_TARGET_CPU=${TARGET_ARCH} \
                      OPENMSX_TARGET_OS=linux \
                      OPENMSX_FLAVOUR=opt \
                      INSTALL_BASE=/usr \
                      INSTALL_SHARE_DIR=/usr/share/openmsx-ld \
                      INSTALL_DOC_DIR=/usr/share/doc/openmsx-ld"

make_target() {
  LIBTOOL_SYSROOT_PATH="${SYSROOT_PREFIX}" \
    make -C ${PKG_BUILD} ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  LIBTOOL_SYSROOT_PATH="${SYSROOT_PREFIX}" \
    make -C ${PKG_BUILD} ${PKG_MAKE_OPTS_TARGET} DESTDIR=${INSTALL} install

  mv ${INSTALL}/usr/bin/openmsx ${INSTALL}/usr/bin/openmsx-ld
  install -m 0755 ${PKG_DIR}/scripts/startopenmsx-ld.sh ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/openmsx/gptk
  cp ${PKG_DIR}/config/openmsx-ld.gptk \
    ${INSTALL}/usr/config/emuelec/configs/openmsx/gptk/
}