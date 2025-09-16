# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="binutils"
PKG_VERSION="2.39"
PKG_SHA256="645c25f563b8adc0a81dbd6a41cffbf4d37083a382e02d5d3df4f65c09516d00"
PKG_LICENSE="GPL"
PKG_SITE="https://www.gnu.org/software/binutils/"
PKG_URL="https://ftp.gnu.org/gnu/binutils/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host bison:host flex:host linux:host"
PKG_DEPENDS_TARGET="toolchain zlib binutils:host"
PKG_LONGDESC="A GNU collection of binary utilities."

PKG_CONFIGURE_OPTS_HOST="--target=${TARGET_NAME} \
                         --with-sysroot=${SYSROOT_PREFIX} \
                         --with-lib-path=${SYSROOT_PREFIX}/lib:${SYSROOT_PREFIX}/usr/lib \
                         --without-ppl \
                         --enable-static \
                         --without-cloog \
                         --disable-werror \
                         --disable-multilib \
                         --disable-libada \
                         --disable-libssp \
                         --enable-version-specific-runtime-libs \
                         --enable-plugins \
                         --enable-gold \
                         --enable-ld=default \
                         --enable-lto \
                         --disable-nls"

PKG_CONFIGURE_OPTS_TARGET="--target=${TARGET_NAME} \
                         --with-sysroot=${SYSROOT_PREFIX} \
                         --with-lib-path=${SYSROOT_PREFIX}/lib:${SYSROOT_PREFIX}/usr/lib \
                         --with-system-zlib \
                         --without-ppl \
                         --without-cloog \
                         --enable-static \
                         --disable-shared \
                         --disable-werror \
                         --disable-multilib \
                         --disable-libada \
                         --disable-libssp \
                         --disable-plugins \
                         --disable-gold \
                         --disable-ld \
                         --disable-lto \
                         --disable-nls"

pre_configure_host() {
  unset CPPFLAGS
  unset CFLAGS
  unset CXXFLAGS
  unset LDFLAGS
}

make_host() {
  make configure-host
  # override the makeinfo binary with true - this does not build the documentation
  make MAKEINFO=true
}

makeinstall_host() {
  cp -v ../include/libiberty.h ${SYSROOT_PREFIX}/usr/include
  make -C bfd install # fix parallel build with libctf requiring bfd
  # override the makeinfo binary with true - this does not build the documentation
  make HELP2MAN=true MAKEINFO=true install
}

make_target() {
  make configure-host
  make -C libiberty
  make -C bfd
  make -C opcodes
  make -C binutils strings
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp libiberty/libiberty.a ${SYSROOT_PREFIX}/usr/lib
  make DESTDIR="${SYSROOT_PREFIX}" -C bfd install
  make DESTDIR="${SYSROOT_PREFIX}" -C opcodes install

  mkdir -p ${INSTALL}/usr/bin
    cp binutils/strings ${INSTALL}/usr/bin
}
