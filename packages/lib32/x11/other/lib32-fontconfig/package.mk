# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-fontconfig"
PKG_VERSION="$(get_pkg_version fontconfig)"
PKG_NEED_UNPACK="$(get_pkg_directory fontconfig)"
PKG_ARCH="aarch64"
PKG_LICENSE="OSS"
PKG_SITE="http://www.fontconfig.org"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-util-linux lib32-util-macros lib32-freetype lib32-libxml2 lib32-zlib lib32-expat"
PKG_PATCH_DIRS+=" $(get_pkg_directory fontconfig)/patches"
PKG_LONGDESC="Fontconfig is a library for font customization and configuration."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--with-arch=${LIB32_TARGET_ARCH} \
                           --with-cache-dir=/storage/.cache/fontconfig \
                           --with-default-fonts=/usr/share/fonts \
                           --without-add-fonts \
                           --disable-dependency-tracking \
                           --disable-docs \
                           --disable-rpath"

unpack() {
  ${SCRIPTS}/get fontconfig
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/fontconfig/fontconfig-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

pre_configure_target() {
# ensure we dont use '-O3' optimization.
  CFLAGS=$(echo ${CFLAGS} | sed -e "s|-O3|-O2|")
  CXXFLAGS=$(echo ${CXXFLAGS} | sed -e "s|-O3|-O2|")
  CFLAGS+=" -I${PKG_BUILD}"
  CXXFLAGS+=" -I${PKG_BUILD}"
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/etc
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
