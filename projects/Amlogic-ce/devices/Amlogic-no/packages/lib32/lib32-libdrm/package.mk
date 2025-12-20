# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libdrm"
PKG_VERSION="$(get_pkg_version libdrm)"
PKG_NEED_UNPACK="$(get_pkg_directory libdrm)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://dri.freedesktop.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libpciaccess"
PKG_PATCH_DIRS+=" $(get_pkg_directory libdrm)/patches"
PKG_LONGDESC="The userspace interface library to kernel DRM services."
PKG_TOOLCHAIN="meson"
PKG_BUILD_FLAGS="lib32"

get_graphicdrivers

PKG_MESON_OPTS_TARGET="-Dnouveau=disabled \
                       -Domap=disabled \
                       -Dexynos=disabled \
                       -Dtegra=disabled \
                       -Dcairo-tests=disabled \
                       -Dman-pages=disabled \
                       -Dvalgrind=disabled \
                       -Dfreedreno-kgsl=false \
                       -Dinstall-test-programs=true \
                       -Dudev=false"

unpack() {
  ${SCRIPTS}/get libdrm
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libdrm/libdrm-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  # We don't need any binary, since we only want lib32
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
