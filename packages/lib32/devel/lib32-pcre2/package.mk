# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-pcre2"
PKG_VERSION="$(get_pkg_version pcre2)"
PKG_NEED_UNPACK="$(get_pkg_directory pcre2)"
PKG_ARCH="aarch64"
PKG_LICENSE="OSS"
PKG_SITE="http://www.pcre.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain pcre2:host"
PKG_PATCH_DIRS+=" $(get_pkg_directory pcre2)/patches"
PKG_LONGDESC="A set of functions that implement regular expression pattern matching."
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="lib32 +pic"

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=OFF \
                       -DPCRE2_BUILD_PCRE2_16=ON \
                       -DPCRE2_SUPPORT_LIBREADLINE=OFF \
                       -DPCRE2_STATIC_PIC=ON"
unpack() {
  ${SCRIPTS}/get pcre2
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/pcre2/pcre2-${PKG_VERSION}.tar.bz2 -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
  # rm -rf ${INSTALL}/usr/bin
  # cp ${PKG_NAME}-config ${TOOLCHAIN}/bin
  # sed -e "s:\(['= ]\)/usr:\\1${PKG_ORIG_SYSROOT_PREFIX}/usr:g" -i ${TOOLCHAIN}/bin/${PKG_NAME}-config
  # chmod +x ${TOOLCHAIN}/bin/${PKG_NAME}-config
}
