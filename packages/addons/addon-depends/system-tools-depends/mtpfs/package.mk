# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mtpfs"
PKG_VERSION="d228a21b07062170e05fb71a7a7bf4a74ad559e1"
PKG_SHA256="4b89e014201a01634022a6348874361f5ca729e455b8c1f9990fa10647590b52"
PKG_LICENSE="GPL"
PKG_SITE="https://www.adebenham.com/mtpfs/"
PKG_URL="https://github.com/cjd/mtpfs/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain fuse glib libmtp"
PKG_LONGDESC="MTPfs is a FUSE filesystem that supports reading and writing from any MTP device."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--disable-mad"

# TODO: mtpfs runs host utils while building, fix and set
pre_configure_target() {
  export LIBS="-lusb-1.0 -ludev"
}
