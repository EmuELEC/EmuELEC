PKG_NAME="flycast"
PKG_VERSION="bf2bd7efed41e9f3367a764c2d90fcaa9c38a1f9"
PKG_SHA256="c0e6d86e99e59071f5eb2d42f1e727d4e862a4e79d919fe62c5b0c3cbcff8d11"
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
  # Удаляем bundled зависимости
  sed -i '/add_subdirectory("core\/deps\/libchdr\/deps\/zlib-1.3.1"/d' CMakeLists.txt
  sed -i '/add_subdirectory("core\/deps\/libchdr\/deps\/zstd-1.5.2"/d' CMakeLists.txt
  sed -i '/add_subdirectory(zlib-ng)/d' CMakeLists.txt
  # Удаляем попытки установить свойства удаленным target'ам
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
  cp flycast_libretro.so ${INSTALL}/usr/lib/libretro/flycast_libretro.so
}
