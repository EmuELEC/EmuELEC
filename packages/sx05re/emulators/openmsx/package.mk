# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

PKG_NAME="openmsx"
PKG_VERSION="b8d562abbe182f1af127bd2a07a8ad451b5c52b8"
PKG_SHA256="7d6b2da6efe675d6fe53b98b288ef2c6769e3b8cee2c502946a1071e4c6160c0"
PKG_REV="0"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/worstcase-scenario/openMSX"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf libpng zlib tcl alsa-lib glew"
PKG_SHORTDESC="openMSX: MSX, MSX2, MSX2+ and MSX turbo R emulator"
PKG_TOOLCHAIN="manual"

PKG_MAKE_OPTS_TARGET="OPENMSX_TARGET_CPU=${TARGET_ARCH} \
                      OPENMSX_TARGET_OS=linux \
                      OPENMSX_FLAVOUR=opt \
                      INSTALL_BASE=/usr \
                      INSTALL_SHARE_DIR=/usr/share/openmsx \
                      INSTALL_DOC_DIR=/usr/share/doc/openmsx"

make_target() {
  LIBTOOL_SYSROOT_PATH="${SYSROOT_PREFIX}" \
    make -C ${PKG_BUILD} ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  LIBTOOL_SYSROOT_PATH="${SYSROOT_PREFIX}" \
    make -C ${PKG_BUILD} ${PKG_MAKE_OPTS_TARGET} DESTDIR=${INSTALL} install

  install -m 0755 ${PKG_DIR}/scripts/startopenmsx.sh ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/openmsx/gptk
  cp ${PKG_DIR}/config/openmsx.gptk \
    ${INSTALL}/usr/config/emuelec/configs/openmsx/gptk/
}