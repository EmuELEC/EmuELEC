# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rar2fs"
PKG_VERSION="1.29.6"
PKG_SHA256="ba3a0b649f2322498d54168f03d2e8bca9b1c96d70d0d97d83ea336a7525d4cb"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/hasse69/rar2fs"
PKG_URL="https://github.com/hasse69/rar2fs/releases/download/v${PKG_VERSION}/rar2fs-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain fuse unrar"
PKG_LONGDESC="FUSE file system for reading RAR archives"
PKG_BUILD_FLAGS="-sysroot"

pre_configure_target() {
  PKG_CONFIGURE_OPTS_TARGET="--with-unrar=${PKG_BUILD}/unrar \
                             --with-unrar-lib=${PKG_BUILD}/unrar \
                             --disable-static-unrar"
  cp -a $(get_install_dir unrar)/usr/include/unrar ${PKG_BUILD}/
  cp -p $(get_install_dir unrar)/usr/lib/libunrar.a ${PKG_BUILD}/unrar/
}
