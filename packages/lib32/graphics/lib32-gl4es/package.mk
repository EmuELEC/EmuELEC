# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-gl4es"
PKG_VERSION="$(get_pkg_version gl4es)"
PKG_NEED_UNPACK="$(get_pkg_directory gl4es)"
PKG_ARCH="aarch64"
PKG_SITE="https://github.com/JohnnyonFlame/gl4es"
PKG_LICENSE="GPL"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-${OPENGLES}"
PKG_PATCH_DIRS+=" $(get_pkg_directory gl4es)/patches"
PKG_LONGDESC=" GL4ES is a OpenGL 2.1/1.5 to GL ES 2.0/1.1 translation library, with support for Pandora, ODroid, OrangePI, CHIP, Raspberry PI, Android, Emscripten and AmigaOS4. "
PKG_TOOLCHAIN="cmake-make"
PKG_BUILD_FLAGS="lib32"

if [ "${PROJECT}" = "Amlogic-ce" ]; then
  PKG_CMAKE_OPTS_TARGET="-DNOX11=1 -DODROID=1 -DGBM=OFF -DCMAKE_BUILD_TYPE=Release"
else
  PKG_CMAKE_OPTS_TARGET="-DNOX11=1 -DODROID=1 -DGBM=ON -DCMAKE_BUILD_TYPE=Release"
fi

unpack() {
  ${SCRIPTS}/get gl4es
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/gl4es/gl4es-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

makeinstall_target(){
  mkdir -p ${INSTALL}/usr/lib32
    cp ${PKG_BUILD}/lib/libGL.so.1 ${INSTALL}/usr/lib32/
    ln -sf libGL.so.1 ${INSTALL}/usr/lib32/libGL.so
}
