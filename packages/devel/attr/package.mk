# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2010-2011 Roman Weber (roman@openelec.tv)
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="attr"
PKG_VERSION="2.5.1"
PKG_SHA256="bae1c6949b258a0d68001367ce0c741cebdacdd3b62965d17e5eb23cd78adaf8"
PKG_LICENSE="GPL"
PKG_SITE="https://savannah.nongnu.org/projects/attr"
PKG_URL="http://download.savannah.nongnu.org/releases/attr/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Extended Attributes Of Filesystem Objects."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="OPTIMIZER= \
                           CONFIG_SHELL=/bin/bash \
                           INSTALL_USER=root INSTALL_GROUP=root \
                           --disable-shared --enable-static"

if build_with_debug; then
  PKG_CONFIGURE_OPTS_TARGET+=" DEBUG=-DDEBUG"
else
  PKG_CONFIGURE_OPTS_TARGET+=" DEBUG=-DNDEBUG"
fi

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/
    cp .libs/libattr.a ${SYSROOT_PREFIX}/usr/lib/

  mkdir -p ${SYSROOT_PREFIX}/usr/include/attr
    cp include/*.h ${SYSROOT_PREFIX}/usr/include/attr
}
