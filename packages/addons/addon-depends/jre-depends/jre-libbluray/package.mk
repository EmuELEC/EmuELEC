# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

. $(get_pkg_directory libbluray)/package.mk

PKG_NAME="jre-libbluray"
PKG_DEPENDS_TARGET+=" apache-ant:host"
PKG_LONGDESC="libbluray jar for BD-J menus"
PKG_URL=""
PKG_DEPENDS_UNPACK+=" jdk-x86_64-zulu libbluray"
PKG_PATCH_DIRS+=" $(get_pkg_directory libbluray)/patches"
PKG_BUILD_FLAGS="-sysroot"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME:4}/${PKG_NAME:4}-${PKG_VERSION}.tar.bz2 -C ${PKG_BUILD}
}

pre_configure_target() {
  export JAVA_HOME="$(get_build_dir jdk-x86_64-zulu)"

  # build also jar
  PKG_CONFIGURE_OPTS_TARGET="${PKG_CONFIGURE_OPTS_TARGET/disable-bdjava-jar/enable-bdjava-jar}"
}

make_target() {
  make all-local
}
