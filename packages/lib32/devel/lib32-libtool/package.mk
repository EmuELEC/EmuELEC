# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libtool"
PKG_VERSION="$(get_pkg_version libtool)"
PKG_NEED_UNPACK="$(get_pkg_directory libtool)"
PKG_SHA256="e3bd4d5d3d025a36c21dd6af7ea818a2afcd4dfc1ea5a17b39d7854bcd0c06e3"
PKG_LICENSE="GPL"
PKG_SITE="http://www.gnu.org/software/libtool/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory libtool)/patches"
PKG_LONGDESC="A generic library support script."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="lib32"


unpack() {
  ${SCRIPTS}/get libtool
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libtool/libtool-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

make_target() {
  : # Does not work!
}

makeinstall_target() {
  : # Does not work!
}

post_makeinstall_target() {
  :
  # rm -rf ${INSTALL}/usr/bin
  # rm -rf ${INSTALL}/usr/share
}
