# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-2022 5schatten (https://github.com/5schatten)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-SDL2_image"
PKG_VERSION="$(get_pkg_version SDL2_image)"
PKG_NEED_UNPACK="$(get_pkg_directory SDL2_image)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libsdl.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-SDL2"
PKG_PATCH_DIRS+=" $(get_pkg_directory SDL2_image)/patches"
PKG_LONGDESC="SDL_image is an image file loading library. "
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get SDL2_image
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/SDL2_image/SDL2_image-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
