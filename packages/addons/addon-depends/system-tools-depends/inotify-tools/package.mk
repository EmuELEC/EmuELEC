# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="inotify-tools"
PKG_VERSION="3.22.6.0"
PKG_SHA256="c6b7e70f1df09e386217102a1fe041cfc15fa4f3d683d2970140b6814cf2ed12"
PKG_LICENSE="GPLv2"
PKG_SITE="http://wiki.github.com/inotify-tools/inotify-tools/"
PKG_URL="https://github.com/inotify-tools/inotify-tools/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A C library and a set of command-line programs for Linux providing a simple interface to inotify."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared --disable-doxygen"

pre_configure_target() {
  CFLAGS+=" -Wno-error=misleading-indentation -Wno-error=unused-parameter"

  # fails to build in subdir for CoreELEC
  cd ..
  rm -rf .${TARGET_NAME}
}
