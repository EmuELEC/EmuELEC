# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-2022 5schatten (https://github.com/5schatten)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-mpg123-compat"
PKG_VERSION="$(get_pkg_version mpg123-compat)"
PKG_NEED_UNPACK="$(get_pkg_directory mpg123-compat)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPLv2"
PKG_SITE="http://www.mpg123.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib lib32-SDL2"
PKG_PATCH_DIRS+=" $(get_pkg_directory mpg123-compat)/patches"
PKG_LONGDESC="A console based real time MPEG Audio Player for Layer 1, 2 and 3."
PKG_BUILD_FLAGS="lib32 -fpic"

if [ "${PULSEAUDIO_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" lib32-libpulse"
  PKG_CONFIGURE_OPTS_TARGET="--with-default-audio=pulse --with-audio=alsa,pulse"
else
  PKG_CONFIGURE_OPTS_TARGET="--with-default-audio=alsa --with-audio=alsa"
fi

unpack() {
  ${SCRIPTS}/get mpg123-compat
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/mpg123-compat/mpg123-compat-${PKG_VERSION}.tar.bz2 -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
