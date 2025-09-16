# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-tre"
PKG_VERSION="$(get_pkg_version tre)"
PKG_NEED_UNPACK="$(get_pkg_directory tre)"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/laurikari/tre"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory tre)/patches" 
PKG_SHORTDESC="The approximate regex matching library and agrep command line tool."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get tre
  mkdir -p ${PKG_BUILD}
  tar cf - -C ${SOURCES}/tre/tre-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
}

pre_configure_target() {
  sed -i "s|AM_GNU_GETTEXT_VERSION(0.17)|AM_GNU_GETTEXT_REQUIRE_VERSION(0.17)|" ${PKG_BUILD}/configure.ac
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
