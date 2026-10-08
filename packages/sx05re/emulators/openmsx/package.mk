# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)

PKG_NAME="openmsx"
PKG_VERSION="e33dca17ff3d587cd6870a79c9fb1ac691120860"
PKG_SHA256="18523368214373291bf157ef28533d1b250722730b5e6de9123b4cd1e693b454"
PKG_REV="0"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/worstcase-scenario/openMSX"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_ttf libpng zlib tcl alsa-lib glew gl4es"
PKG_SHORTDESC="openMSX: MSX, MSX2, MSX2+ and MSX turbo R emulator"
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  # gl4es ships libGL only in the image; openMSX's probe only looks at the sysroot.
  cp -f $(get_build_dir gl4es)/lib/libGL.so.1 ${SYSROOT_PREFIX}/usr/lib/libGL.so
  ln -sf libGL.so ${SYSROOT_PREFIX}/usr/lib/libGL.so.1
  cp -rf $(get_build_dir gl4es)/include/GL ${SYSROOT_PREFIX}/usr/include/
}

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

  # remove the staged gl4es files again: a libGL in the sysroot makes VLC build
  # glspectrum, which drags desktop GL into ES and costs ~85% of its framerate
  rm -f ${SYSROOT_PREFIX}/usr/lib/libGL.so*
  for f in $(ls $(get_build_dir gl4es)/include/GL); do
    rm -rf ${SYSROOT_PREFIX}/usr/include/GL/$f
  done
}
