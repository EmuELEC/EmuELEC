# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-gcc"
PKG_VERSION="$(get_pkg_version gcc)"
PKG_NEED_UNPACK="$(get_pkg_directory gcc)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-2.0-or-later"
PKG_URL=""
PKG_DEPENDS_BOOTSTRAP="ccache:host autoconf:host lib32-binutils:host gmp:host mpfr:host mpc:host zstd:host"
PKG_DEPENDS_HOST="ccache:host autoconf:host lib32-binutils:host gmp:host mpfr:host mpc:host zstd:host lib32-glibc"
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_LONGDESC="This package contains the GNU Compiler Collection for multilib ARM."
PKG_PATCH_DIRS+=" $(get_pkg_directory gcc)/patches"

GCC_COMMON_CONFIGURE_OPTS="--target=${LIB32_TARGET_NAME} \
                           --with-sysroot=${LIB32_SYSROOT_PREFIX} \
                           --with-gmp=${TOOLCHAIN} \
                           --with-mpfr=${TOOLCHAIN} \
                           --with-mpc=${TOOLCHAIN} \
                           --with-zstd=${TOOLCHAIN} \
                           --with-gnu-as \
                           --with-gnu-ld \
                           --enable-plugin \
                           --enable-lto \
                           --enable-gold \
                           --enable-ld=default \
                           --with-linker-hash-style=gnu \
                           --disable-multilib \
                           --disable-nls \
                           --enable-checking=release \
                           --without-ppl \
                           --without-cloog \
                           --disable-libada \
                           --disable-libmudflap \
                           --disable-libitm \
                           --disable-libquadmath \
                           --disable-libmpx \
                           --disable-libssp \
                           --enable-__cxa_atexit"

PKG_CONFIGURE_OPTS_BOOTSTRAP="${GCC_COMMON_CONFIGURE_OPTS} \
                              --enable-cloog-backend=isl \
                              --disable-decimal-float \
                              --disable-gcov \
                              --enable-languages=c \
                              --disable-libatomic \
                              --disable-libgomp \
                              --disable-libsanitizer \
                              --disable-shared \
                              --disable-threads \
                              --without-headers \
                              --with-newlib \
                              ${LIB32_TARGET_ARCH_GCC_OPTS}"

PKG_CONFIGURE_OPTS_HOST="${GCC_COMMON_CONFIGURE_OPTS} \
                         --enable-languages=c,c++ \
                         --enable-libatomic \
                         --enable-decimal-float \
                         --enable-tls \
                         --enable-shared \
                         --disable-static \
                         --enable-long-long \
                         --enable-threads=posix \
                         --disable-libstdcxx-pch \
                         --enable-libstdcxx-time \
                         --enable-clocale=gnu \
                         ${LIB32_TARGET_ARCH_GCC_OPTS}"

unpack() {
  ${SCRIPTS}/get gcc
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/gcc/gcc-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_makeinstall_bootstrap() {
  GCC_VERSION=$(${TOOLCHAIN}/bin/${LIB32_TARGET_NAME}-gcc -dumpversion)
  DATE="0401$(echo ${GCC_VERSION} | sed 's/\./0/g')"
  CROSS_CC=${LIB32_TARGET_PREFIX}gcc-${GCC_VERSION}

  rm -f ${LIB32_TARGET_PREFIX}gcc

cat > ${LIB32_TARGET_PREFIX}gcc <<EOF
#!/bin/sh
${TOOLCHAIN}/bin/ccache ${CROSS_CC} "\$@"
EOF

  chmod +x ${LIB32_TARGET_PREFIX}gcc

  # To avoid cache trashing
  touch -c -t ${DATE} ${CROSS_CC}

  # install lto plugin for binutils
  mkdir -p ${TOOLCHAIN}/lib/bfd-plugins
    ln -sf ../gcc/${LIB32_TARGET_NAME}/${GCC_VERSION}/liblto_plugin.so ${TOOLCHAIN}/lib/bfd-plugins
}

pre_configure_host() {
  unset CPP
}

post_make_host() {
  # fix wrong link
  ln -sf libgcc_s.so.1 ${LIB32_TARGET_NAME}/libgcc/libgcc_s.so
  if [ ! "${BUILD_WITH_DEBUG}" = "yes" ]; then
    ${LIB32_TARGET_PREFIX}strip ${LIB32_TARGET_NAME}/libgcc/libgcc_s.so*
    ${LIB32_TARGET_PREFIX}strip ${LIB32_TARGET_NAME}/libgomp/.libs/libgomp.so*
    ${LIB32_TARGET_PREFIX}strip ${LIB32_TARGET_NAME}/libstdc++-v3/src/.libs/libstdc++.so*
    ${LIB32_TARGET_PREFIX}strip ${LIB32_TARGET_NAME}/libatomic/.libs/libatomic.so*
  fi
}


post_makeinstall_host() {
  GCC_VERSION=$(${LIB32_TARGET_PREFIX}gcc -dumpversion)
  DATE="0501$(echo ${GCC_VERSION} | sed 's/\./0/g')"
  CROSS_CC=${LIB32_TARGET_PREFIX}gcc-${GCC_VERSION}
  CROSS_CXX=${LIB32_TARGET_PREFIX}g++-${GCC_VERSION}

  rm -f ${LIB32_TARGET_PREFIX}gcc

cat > ${LIB32_TARGET_PREFIX}gcc <<EOF
#!/bin/sh
${TOOLCHAIN}/bin/ccache ${CROSS_CC} "\$@"
EOF

  chmod +x ${LIB32_TARGET_PREFIX}gcc

  # To avoid cache trashing
  touch -c -t ${DATE} ${CROSS_CC}

  [ ! -f "${CROSS_CXX}" ] && mv ${LIB32_TARGET_PREFIX}g++ ${CROSS_CXX}

cat > ${LIB32_TARGET_PREFIX}g++ <<EOF
#!/bin/sh
${TOOLCHAIN}/bin/ccache ${CROSS_CXX} "\$@"
EOF

  chmod +x ${LIB32_TARGET_PREFIX}g++

  # To avoid cache trashing
  touch -c -t ${DATE} ${CROSS_CXX}

  # install lto plugin for binutils
  mkdir -p ${TOOLCHAIN}/lib32/bfd-plugins
    ln -sf ../gcc/${LIB32_TARGET_NAME}/${GCC_VERSION}/liblto_plugin.so ${TOOLCHAIN}/lib/bfd-plugins
}

configure_target() {
 : # reuse configure_host()
}

make_target() {
 : # reuse make_host()
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib32
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${LIB32_TARGET_NAME}/libgcc/libgcc_s.so* ${INSTALL}/usr/lib32
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${LIB32_TARGET_NAME}/libgomp/.libs/libgomp.so* ${INSTALL}/usr/lib32
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${LIB32_TARGET_NAME}/libstdc++-v3/src/.libs/libstdc++.so* ${INSTALL}/usr/lib32
    cp -P ${PKG_BUILD}/.${HOST_NAME}/${LIB32_TARGET_NAME}/libatomic/.libs/libatomic.so* ${INSTALL}/usr/lib32
}
