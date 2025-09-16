# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libvorbisidec"
PKG_VERSION="$(get_pkg_version libvorbisidec)"
PKG_NEED_UNPACK="$(get_pkg_directory libvorbisidec)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/sezero/tremor"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libogg lib32-freetype"
PKG_PATCH_DIRS+=" $(get_pkg_directory libvorbisidec)/patches"
PKG_LONGDESC="libvorbisidec"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get libvorbisidec
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libvorbisidec/libvorbisidec-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

configure_target() {
  cd ${PKG_BUILD}
  ./autogen.sh HAVE_OGG=no --disable-mmx --prefix=/usr --datadir=/usr/share --datarootdir=/usr/share --host=${TARGET_NAME} --enable-fb --enable-freetype --with-freetype-prefix=${SYSROOT_PREFIX}/usr --enable-slang
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
