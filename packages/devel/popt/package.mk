# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="popt"
PKG_VERSION="1.19"
PKG_SHA256="c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/rpm-software-management/popt"
PKG_URL="http://ftp.rpm.org/popt/releases/popt-1.x/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The popt library exists essentially for parsing command-line options."

pre_configure_target() {
 cd ${PKG_BUILD}
 rm -rf .${TARGET_NAME}
}

pre_configure_host() {
 cd ${PKG_BUILD}
 rm -rf .${HOST_NAME}
}
