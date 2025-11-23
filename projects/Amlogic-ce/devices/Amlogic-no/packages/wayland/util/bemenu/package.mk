# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bemenu"
PKG_VERSION="0.6.23"
PKG_SHA256="0e7878c3bf57e0e362efe89c59deddd33819cd62b980be7e0b7bb4da45478e44"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/Cloudef/bemenu"
PKG_URL="https://github.com/Cloudef/bemenu/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib wayland wayland-protocols cairo pango libxkbcommon"
PKG_LONGDESC="Dynamic menu library and client program inspired by dmenu"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET="PREFIX=/usr clients wayland"

makeinstall_target() {
  make DESTDIR=${INSTALL} PREFIX=/usr install-libs install-bins install-wayland install-pkgconfig
}

post_makeinstall_target() {
  ln -sf libbemenu.so.${PKG_VERSION} ${INSTALL}/usr/lib/libbemenu.so.0
}
