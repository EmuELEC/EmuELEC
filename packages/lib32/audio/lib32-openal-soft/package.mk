# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-2022 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-openal-soft"
PKG_VERSION="$(get_pkg_version openal-soft)"
PKG_NEED_UNPACK="$(get_pkg_directory openal-soft)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://www.openal.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib"
PKG_PATCH_DIRS+=" $(get_pkg_directory openal-soft)/patches"
PKG_LONGDESC="OpenAL Soft is a software implementation of the OpenAL 3D audio API."
PKG_BUILD_FLAGS="lib32"

PKG_CMAKE_OPTS_TARGET="-DALSOFT_BACKEND_OSS=off \
                       -DALSOFT_BACKEND_PULSEAUDIO=off \
                       -DALSOFT_BACKEND_WAVE=off \
                       -DALSOFT_EXAMPLES=off \
                       -DALSOFT_UTILS=off"

unpack() {
  ${SCRIPTS}/get openal-soft
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/openal-soft/openal-soft-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
