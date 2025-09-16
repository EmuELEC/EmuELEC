# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-fribidi"
PKG_VERSION="$(get_pkg_version fribidi)"
PKG_NEED_UNPACK="$(get_pkg_directory fribidi)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL"
PKG_SITE="http://fribidi.freedesktop.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory fribidi)/patches"
PKG_LONGDESC="A bidirectional algorithm library."
PKG_TOOLCHAIN="meson"
PKG_BUILD_FLAGS="lib32 +pic"

PKG_MESON_OPTS_TARGET="-Ddeprecated=false \
                       -Ddocs=false \
                       -Ddefault_library=static"

unpack() {
  ${SCRIPTS}/get fribidi
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/fribidi/fribidi-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/bin
    cp -f $(get_pkg_directory fribidi)/scripts/fribidi-config ${SYSROOT_PREFIX}/usr/bin
    chmod +x ${SYSROOT_PREFIX}/usr/bin/fribidi-config

  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
