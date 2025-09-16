# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2010-2011 Roman Weber (roman@openelec.tv)
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libcap"
PKG_VERSION="2.66"
PKG_SHA256="15c40ededb3003d70a283fe587a36b7d19c8b3b554e33f86129c059a4bb466b2"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/log/"
PKG_URL="https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A library for getting and setting POSIX.1e capabilities."
PKG_BUILD_FLAGS="+pic"

post_unpack() {
  mkdir -p ${PKG_BUILD}/.${HOST_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${HOST_NAME}
  mkdir -p ${PKG_BUILD}/.${TARGET_NAME}
  cp -r ${PKG_BUILD}/* ${PKG_BUILD}/.${TARGET_NAME}
}

make_host() {
  cd ${PKG_BUILD}/.${HOST_NAME}
  make CC=${CC} \
       AR=${AR} \
       RANLIB=${RANLIB} \
       CFLAGS="${HOST_CFLAGS}" \
       BUILD_CFLAGS="${HOST_CFLAGS} -I${PKG_BUILD}/libcap/include" \
       PAM_CAP=no \
       lib=/lib \
       USE_GPERF=no \
       -C libcap libcap.pc libcap.a
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

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/lib
    cp libcap/libcap.a ${TOOLCHAIN}/lib

  mkdir -p ${TOOLCHAIN}/lib/pkgconfig
    cp libcap/libcap.pc ${TOOLCHAIN}/lib/pkgconfig

  mkdir -p ${TOOLCHAIN}/include/sys
    cp libcap/include/sys/capability.h ${TOOLCHAIN}/include/sys
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp libcap/libcap.a ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp libcap/libcap.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig

  mkdir -p ${SYSROOT_PREFIX}/usr/include/sys
    cp libcap/include/sys/capability.h ${SYSROOT_PREFIX}/usr/include/sys
}
