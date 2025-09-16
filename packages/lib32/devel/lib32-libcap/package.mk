# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2010-2011 Roman Weber (roman@openelec.tv)
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libcap"
PKG_VERSION="$(get_pkg_version libcap)"
PKG_NEED_UNPACK="$(get_pkg_directory libcap)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/log/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libcap)/patches"
PKG_LONGDESC="A library for getting and setting POSIX.1e capabilities."
PKG_BUILD_FLAGS="+pic lib32"

unpack() {
  ${SCRIPTS}/get libcap
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libcap/libcap-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_unpack() {
  mkdir -p ${PKG_BUILD}/.${LIB32_TARGET_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${LIB32_TARGET_NAME}
}

make_target() {
  cd ${PKG_BUILD}/.${TARGET_NAME}
  make CC=${CC} \
       AR=${AR} \
       RANLIB=${RANLIB} \
       CFLAGS="${TARGET_CFLAGS}" \
       BUILD_CC=${HOST_CC} \
       BUILD_CFLAGS="${HOST_CFLAGS} -I${PKG_BUILD}/libcap/include" \
       PAM_CAP=no \
       lib=/lib \
       USE_GPERF=no \
       -C libcap libcap.pc libcap.a
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp libcap/libcap.a ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp libcap/libcap.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig

  mkdir -p ${SYSROOT_PREFIX}/usr/include/sys
    cp libcap/include/sys/capability.h ${SYSROOT_PREFIX}/usr/include/sys
}
