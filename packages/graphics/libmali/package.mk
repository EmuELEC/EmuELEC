# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libmali"
PKG_VERSION="d4000def121b818ae0f583d8372d57643f723fdc"
PKG_SHA256="4f2103fc927cc006ee5c9b647e899f50b0dcaeee127fec713387d06a333eb404"
PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/LibreELEC/libmali"
PKG_URL="https://github.com/LibreELEC/libmali/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="OpenGL ES user-space binary for the ARM Mali GPU family"
PKG_STAMP="${MALI_FAMILY}"

PKG_DEPENDS_TARGET="libdrm"

if listcontains "${MALI_FAMILY}" "(t620|t720)"; then
  PKG_DEPENDS_TARGET+=" wayland"
fi

listcontains "${MALI_FAMILY}" "4[0-9]+" && PKG_DEPENDS_TARGET+=" mali-utgard"
listcontains "${MALI_FAMILY}" "t[0-9]+" && PKG_DEPENDS_TARGET+=" mali-midgard"
listcontains "${MALI_FAMILY}" "g[0-9]+" && PKG_DEPENDS_TARGET+=" mali-bifrost"

PKG_CMAKE_OPTS_TARGET="-DMALI_VARIANT=${MALI_FAMILY// /;}"

if [ "${TARGET_ARCH}" = "aarch64" ]; then
  PKG_CMAKE_OPTS_TARGET+=" -DMALI_ARCH=aarch64-linux-gnu"
fi

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -v ${PKG_DIR}/scripts/libmali-setup ${INSTALL}/usr/bin

  if [ $(ls -1q ${INSTALL}/usr/lib/libmali-*.so | wc -l) -gt 1 ]; then
    ln -sfv /var/lib/libmali/libmali.so ${INSTALL}/usr/lib/libmali.so
  fi
}

post_install() {
  enable_service libmali-setup.service
}
