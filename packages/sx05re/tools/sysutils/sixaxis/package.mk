# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sixaxis"
PKG_VERSION="f53b0ca28c35ebd71b54190f33eadcb8c3267186"
PKG_SHA256="baf7fd22c86c5a32d5043a6bd8487928d2ae216759414632b1d3a998ba61d922"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/RetroPie/sixaxis"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="emuelec/tools"
PKG_LONGDESC="sixaxis helper service "
PKG_TOOLCHAIN="make"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"


makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp sixaxis-helper.sh ${INSTALL}/usr/bin/sixaxis-helper.sh
    cp bins/sixaxis-timeout ${INSTALL}/usr/bin/sixaxis-timeout
}

post_install() {
enable_service sixaxis@.service
}

