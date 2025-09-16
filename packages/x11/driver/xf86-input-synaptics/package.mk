# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xf86-input-synaptics"
PKG_VERSION="1.9.2"
PKG_SHA256="b8fa4aab913fc63754bbd6439e020658c412743a055201ddf212760593962c38"
PKG_LICENSE="GPL"
PKG_SITE="https://lists.freedesktop.org/mailman/listinfo/xorg"
PKG_URL="https://xorg.freedesktop.org/archive/individual/driver/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain xorg-server libXi libXext libevdev"
PKG_LONGDESC="Synaptics touchpad driver for X.Org."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--with-xorg-module-dir=${XORG_PATH_MODULES}"

post_configure_target() {
  libtool_remove_rpath libtool
}
