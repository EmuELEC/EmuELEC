# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libvncserver"
PKG_VERSION="0.9.14"
PKG_SHA256="83104e4f7e28b02f8bf6b010d69b626fae591f887e949816305daebae527c9a5"
PKG_LICENSE="GPL"
PKG_SITE="https://libvnc.github.io/"
PKG_URL="https://github.com/LibVNC/libvncserver/archive/LibVNCServer-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libjpeg-turbo libpng openssl systemd"
PKG_LONGDESC="A C library that allow you to easily implement VNC server or client functionality."

PKG_CMAKE_OPTS_TARGET="-DWITH_GCRYPT=OFF \
                       -DWITH_GNUTLS=OFF \
                       -DWITH_GTK=OFF \
                       -DWITH_SDL=OFF \
                       -DWITH_TIGHTVNC_FILETRANSFER=OFF \
                       -DWITH_TESTS=OFF \
                       -DWITH_EXAMPLES=OFF \
                       -DBUILD_SHARED_LIBS=ON"

pre_configure_target() {
  # hide openssl >=3.0.0 warnings
  export CFLAGS+=" -Wno-deprecated-declarations"
}
