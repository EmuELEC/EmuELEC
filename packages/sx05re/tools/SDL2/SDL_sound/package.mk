# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL_sound"
PKG_VERSION="4a8ecd77446d8653c99a673e7896f70a4489b1bb"
PKG_SHA256="aac0b9a1058fa99e7886c2639bd115c6cd40b3828a438abdfd4744af9d88cdb5"
PKG_LICENSE="GPLv3"
PKG_SITE="https://www.icculus.org/SDL_sound/"
PKG_URL="https://github.com/icculus/SDL_sound/archive/${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain alsa-lib SDL2"
PKG_LONGDESC="SDL_sound library"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --disable-speex \
                           --disable-physfs \
                           ac_cv_path_SDL2_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"

post_unpack() {
  touch ${PKG_BUILD}/README
}

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -lm"
}

post_makeinstall_target() {
  ln -sf ${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/usr/include/SDL/SDL_sound.h ${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/usr/include/SDL2/SDL_sound.h
}
