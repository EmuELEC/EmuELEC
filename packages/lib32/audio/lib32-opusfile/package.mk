# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-opusfile"
PKG_VERSION="$(get_pkg_version opusfile)"
PKG_NEED_UNPACK="$(get_pkg_directory opusfile)"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/xiph/opusfile"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-openssl lib32-opus lib32-libogg"
PKG_PATCH_DIRS+=" $(get_pkg_directory opusfile)/patches"
PKG_SHORTDESC="Stand-alone decoder library for .opus streams"
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get opusfile
  mkdir -p ${PKG_BUILD}
  tar cf - -C ${SOURCES}/opusfile/opusfile-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
}

pre_configure_target() {
  ${PKG_BUILD}/autogen.sh
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
