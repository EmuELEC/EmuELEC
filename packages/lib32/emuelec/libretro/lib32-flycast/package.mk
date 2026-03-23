# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-flycast"
PKG_VERSION="$(get_pkg_version flycast)"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/flyinghead/flycast"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain:host ${OPENGLES}:host libzip:host zstd:host"
PKG_SHORTDESC="Flycast is a multiplatform Sega Dreamcast emulator"
PKG_BUILD_FLAGS="-lto"
PKG_TOOLCHAIN="cmake"

post_unpack() {
  cd ${PKG_BUILD}
  git submodule update --init --recursive 2>&1 | grep -v "^fatal:" || true
  sed -i '/add_subdirectory("core\/deps\/libchdr\/deps\/zlib-1.3.1"/d' CMakeLists.txt
  sed -i '/add_subdirectory("core\/deps\/libchdr\/deps\/zstd-1.5.2"/d' CMakeLists.txt
  sed -i '/add_subdirectory(zlib-ng)/d' CMakeLists.txt
  sed -i '/set_target_properties(zlibstatic/,/)/d' CMakeLists.txt
  sed -i '/set_target_properties(zstd/,/)/d' CMakeLists.txt
}

pre_configure_target() {
  rm -f ${PKG_BUILD}/CMakeCache.txt
}

PKG_CMAKE_OPTS_TARGET="-DLIBRETRO=ON \
                        -DUSE_OPENMP=OFF \
                        -DCMAKE_BUILD_TYPE=Release \
                        -DUSE_GLES2=OFF \
                        -DUSE_GLES=ON \
                        -DUSE_VULKAN=OFF \
                        -DZLIB_LIBRARY=${SYSROOT_PREFIX}/usr/lib/libz.so \
                        -DZLIB_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                        -DZstd_LIBRARY=${SYSROOT_PREFIX}/usr/lib/libzstd.so \
                        -DZstd_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp flycast_libretro.so ${INSTALL}/usr/lib/libretro/flycast_32b_libretro.so
}
