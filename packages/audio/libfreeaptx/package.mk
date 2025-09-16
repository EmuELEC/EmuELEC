# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libfreeaptx"
PKG_VERSION="0.1.1"
PKG_SHA256="7acf514446cae59585d9bc21e4f98f4a3856f4741c3a7a09d06e8ac5bf2f7315"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/iamthehorker/libfreeaptx"
PKG_URL="https://github.com/iamthehorker/libfreeaptx/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Open Source aptX codec library"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+pic"

make_target() {
  ${CC} ${CFLAGS} -I${PKG_BUILD} -c -o ${PKG_NAME##*lib}.o ${PKG_NAME##*lib}.c
  ${AR} -rcs ${PKG_NAME}.a ${PKG_NAME##*lib}.o
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -a ${PKG_NAME}.a ${SYSROOT_PREFIX}/usr/lib/

  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp -a ${PKG_NAME##*lib}.h ${SYSROOT_PREFIX}/usr/include/

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cat > ${SYSROOT_PREFIX}/usr/lib/pkgconfig/${PKG_NAME}.pc << EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: ${PKG_NAME}
Description: Open Source aptX codec library
Version: ${PKG_VERSION}
Libs: -Wl,-rpath=\${libdir} -L\${libdir} -l${PKG_NAME##*lib}
Cflags: -I\${includedir}
EOF
}
