# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libsndfile"
PKG_VERSION="$(get_pkg_version libsndfile)"
PKG_NEED_UNPACK="$(get_pkg_directory libsndfile)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://libsndfile.github.io/libsndfile/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib lib32-flac lib32-libogg lib32-libvorbis lib32-opus"
PKG_PATCH_DIRS+=" $(get_pkg_directory libsndfile)/patches"
PKG_LONGDESC="A C library for reading and writing sound files containing sampled audio data."
PKG_BUILD_FLAGS="lib32 +pic"

# As per notes in configure.ac:
#  One or more of the external libraries (ie libflac, libogg, libvorbis and libopus)
#  is either missing ... Unfortunately, for ease of maintenance, the external libs
#  are an all or nothing affair.
# So all of flac, libogg, libvorbis, opus are required.

PKG_CMAKE_OPTS_TARGET="-DBUILD_PROGRAMS=OFF \
                       -DBUILD_EXAMPLES=OFF \
                       -DBUILD_REGTEST=OFF \
                       -DBUILD_TESTING=OFF \
                       -DBUILD_SHARED_LIBS=ON \
                       -DENABLE_EXTERNAL_LIBS=ON \
                       -DINSTALL_MANPAGES=OFF \
                       -DINSTALL_PKGCONFIG_MODULE=ON"

unpack() {
  ${SCRIPTS}/get libsndfile
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libsndfile/libsndfile-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
