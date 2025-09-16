# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lua52"
PKG_VERSION="5.2.4"
PKG_SHA256="b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b"
PKG_LICENSE="MIT"
PKG_SITE="https://www.lua.org"
PKG_URL="http://www.lua.org/ftp/lua-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Lua is a powerful, efficient, lightweight, embeddable scripting language."

make_target() {
  make CC=${CC} AR="${AR} rcu" posix
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include/lua$(get_pkg_version_maj_min)
  cp src/lua.h src/luaconf.h src/lualib.h src/lauxlib.h ${SYSROOT_PREFIX}/usr/include/lua$(get_pkg_version_maj_min)

  mkdir -p ${SYSROOT_PREFIX}/usr/lib
  cp src/liblua.a ${SYSROOT_PREFIX}/usr/lib/liblua$(get_pkg_version_maj_min).a

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
  cp ${PKG_DIR}/config/lua52.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
  sed -e "s/@@VERSION@@/${PKG_VERSION}/g" \
      -e "s/@@VERSION_MM@@/$(get_pkg_version_maj_min)/g" \
      -i ${SYSROOT_PREFIX}/usr/lib/pkgconfig/lua52.pc
}
