# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="hddtemp"
PKG_VERSION="0.4.3"
PKG_SHA256="592322c64f0d5f035132249e3d051b752f5d24867514522a17285d5e72d21075"
PKG_LICENSE="GPL"
PKG_SITE="https://savannah.nongnu.org/projects/hddtemp"
PKG_URL="https://github.com/vitlav/hddtemp/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A utility that gives you the temperature of your hard drive by reading S.M.A.R.T.."
PKG_BUILD_FLAGS="-sysroot"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--with-db-path=/storage/.kodi/addons/virtual.system-tools/data/hddtemp.db"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/misc
  cp ${PKG_DIR}/db/* ${INSTALL}/usr/share/misc
}
