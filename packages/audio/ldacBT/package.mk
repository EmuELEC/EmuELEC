# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ldacBT"
PKG_VERSION="2.0.2.3"
PKG_SHA256="c02998718f9c4620437d7594b4d121b3ab4c5cfeba8d41fa31dd5c71db09edca"
PKG_LICENSE="Apache"
PKG_SITE="https://github.com/EHfive/ldacBT"
PKG_URL="https://github.com/EHfive/ldacBT/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_DEPENDS_UNPACK="libldac"
PKG_LONGDESC="LDAC Bluetooth encoder library (build tools)"

PKG_CMAKE_OPTS_TARGET="-DLDAC_SOFT_FLOAT=OFF"

post_unpack() {
  rm -rf ${PKG_BUILD}/libldac
  ln -sf $(get_build_dir libldac) ${PKG_BUILD}/libldac
}
