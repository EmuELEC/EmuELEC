# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-bzip2"
PKG_VERSION="$(get_pkg_version bzip2)"
PKG_NEED_UNPACK="$(get_pkg_directory bzip2)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://sourceware.org/bzip2/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory bzip2)/patches"
PKG_LONGDESC="A high-quality bzip2 data compressor."
PKG_BUILD_FLAGS="lib32 +pic +pic:host"

unpack() {
  ${SCRIPTS}/get bzip2
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/bzip2/bzip2-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

pre_build_target() {
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}

pre_make_target() {
  cd ${PKG_BUILD}/.${TARGET_NAME}
  sed -e "s,ln -s (lib.*),ln -snf \$${1}; ln -snf libbz2.so.${PKG_VERSION} libbz2.so,g" -i Makefile-libbz2_so
}

make_target() {
  make -f Makefile-libbz2_so CC=${CC} CFLAGS="${CFLAGS}"
}

post_make_target() {
  ln -snf libbz2.so.1.0 libbz2.so
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp bzlib.h ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -P libbz2.so* ${SYSROOT_PREFIX}/usr/lib
  mkdir -p ${INSTALL}/usr/lib32
    cp -P libbz2.so* ${INSTALL}/usr/lib32
}
