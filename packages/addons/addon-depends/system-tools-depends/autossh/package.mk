# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="autossh"
PKG_VERSION="1.4g"
PKG_SHA256="5fc3cee3361ca1615af862364c480593171d0c54ec156de79fc421e31ae21277"
PKG_LICENSE="GPL"
PKG_SITE="http://www.harding.motd.ca/"
PKG_URL="http://www.harding.motd.ca/autossh/autossh-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Automatically restart SSH sessions and tunnels."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes"

pre_configure_target() {
  export CFLAGS="${CFLAGS} -I."
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -p autossh ${INSTALL}/usr/bin
}
