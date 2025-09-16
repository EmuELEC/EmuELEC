# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-common"
PKG_VERSION="e9a4ccc4a6b05f136ef5358218a5a94ebeccb7cb"
PKG_SHA256="553eb4855300a72ac00b79a69749bafa4bc35e9108f012a799901c6cfcaf17cc"
PKG_LICENSE="Public domain"
PKG_SITE="https://github.com/libretro/libretro-common"
PKG_URL="https://github.com/libretro/libretro-common/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Reusable coding blocks useful for libretro core and frontend development"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p "${SYSROOT_PREFIX}/usr/include/${PKG_NAME}"
  cp -pR ${PKG_BUILD}/include/* "${SYSROOT_PREFIX}/usr/include/${PKG_NAME}/"
}
