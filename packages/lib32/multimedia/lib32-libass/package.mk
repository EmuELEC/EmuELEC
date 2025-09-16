# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libass"
PKG_VERSION="$(get_pkg_version libass)"
PKG_NEED_UNPACK="$(get_pkg_directory libass)"
PKG_ARCH="aarch64"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/libass/libass"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-freetype lib32-fontconfig lib32-fribidi lib32-harfbuzz"
PKG_PATCH_DIRS+=" $(get_pkg_directory libass)/patches"
PKG_LONGDESC="A portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha) subtitle format."
PKG_BUILD_FLAGS="lib32"

PKG_CONFIGURE_OPTS_TARGET="--disable-test \
                           --enable-fontconfig \
                           --disable-silent-rules \
                           --with-gnu-ld"

unpack() {
  ${SCRIPTS}/get libass
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libass/libass-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
