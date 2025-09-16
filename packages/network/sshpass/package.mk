# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="sshpass"
PKG_VERSION="1.09"
PKG_SHA256="71746e5e057ffe9b00b44ac40453bf47091930cba96bbea8dc48717dedc49fb7"
PKG_LICENSE="GPLv2"
PKG_SITE="https://sourceforge.net/p/sshpass"
PKG_URL="https://downloads.sourceforge.net/sshpass/sshpass-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="sshpass: a tool for non-interactive ssh password auth"

pre_configure_target(){
  export ac_cv_func_malloc_0_nonnull=yes
  export ac_cv_func_realloc_0_nonnull=yes
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp sshpass ${INSTALL}/usr/bin
}
