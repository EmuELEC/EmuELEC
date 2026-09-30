# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase-scenario (https://github.com/worstcase-scenario)

PKG_NAME="azahar"
PKG_VERSION="2126.1"
PKG_SHA256="7bea6d8aec905e10ffcf7ceaf558a231a21ce008ad40d193ff9fb247b1ccf9cb"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/azahar-unified-source-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Azahar - Nintendo 3DS emulator (libretro core)"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  export CXXFLAGS="${CXXFLAGS} -DUSING_GLES"

  PKG_CMAKE_OPTS_TARGET="-DENABLE_LIBRETRO=ON \
                         -DENABLE_OPENGL=ON \
                         -DENABLE_VULKAN=OFF \
                         -DENABLE_TESTS=OFF \
                         -DENABLE_LTO=OFF \
                         -DCITRA_WARNINGS_AS_ERRORS=OFF \
                         -DCMAKE_BUILD_TYPE=Release"
}

make_target() {
  cmake --build . --target citra_libretro -j${CONCURRENCY_MAKE_LEVEL}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp $(find . -name azahar_libretro.so | head -1) ${INSTALL}/usr/lib/libretro/
  cp ${PKG_DIR}/azahar_libretro.info ${INSTALL}/usr/lib/libretro/
}