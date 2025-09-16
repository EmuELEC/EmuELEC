# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-pixman"
PKG_VERSION="$(get_pkg_version pixman)"
PKG_NEED_UNPACK="$(get_pkg_directory pixman)"
PKG_ARCH="aarch64"
PKG_LICENSE="OSS"
PKG_SITE="http://www.x.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-util-macros"
PKG_PATCH_DIRS+=" $(get_pkg_directory pixman)/patches"
PKG_LONGDESC="Pixman is a generic library for manipulating pixel regions, contains low-level pixel manipulation routines."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-openmp \
                           --disable-loongson-mmi \
                           --disable-mmx \
                           --disable-sse2 \
                           --disable-vmx \
                           --enable-arm-simd \
                           --enable-arm-neon \
                           --disable-arm-iwmmxt \
                           --disable-mips-dspr2 \
                           --enable-gcc-inline-asm \
                           --disable-timers \
                           --disable-gtk \
                           --disable-libpng \
                           --with-gnu-ld"

unpack() {
  ${SCRIPTS}/get pixman
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/pixman/pixman-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  cp -f ${SYSROOT_PREFIX}/usr/lib/pkgconfig/pixman-1.pc \
     ${SYSROOT_PREFIX}/usr/lib/pkgconfig/pixman.pc
  cp -rf ${SYSROOT_PREFIX}/usr/include/pixman-1 \
     ${SYSROOT_PREFIX}/usr/include/pixman
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
