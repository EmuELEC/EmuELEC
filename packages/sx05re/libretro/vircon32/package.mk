# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vircon32"
PKG_VERSION="d8a92430e887286b4e5351916ef0bd35d8cb40e8"
PKG_SHA512="8746ba64b721954adab761dad17071d6c92a48bb35944d6cc1360c25046774ec9cc2f6c144036a3376deb9723e9d106ffc2bf520e4a4595130e8ef864bb5bd2d"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://github.com/vircon32/vircon32-libretro"
PKG_URL="https://github.com/vircon32/vircon32-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES}"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Vircon32 is a 32-bit virtual console"
PKG_LONGDESC="Vircon32 emulator for libretro - a 32-bit virtual game console."
PKG_IS_ADDON="no"
PKG_TOOLCHAIN="cmake"
PKG_AUTORECONF="no"

PKG_LIBNAME="vircon32_libretro.so"
PKG_LIBVAR="VIRCON32_LIB"

PKG_CMAKE_OPTS_TARGET="-DENABLE_OPENGLES3=1 \
                       -DOpenGL_GL_PREFERENCE=GLVND \
                       -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                       -DOPENGL_opengl_LIBRARY=${SYSROOT_PREFIX}/usr/lib/libOpenGL.so \
                       -DOPENGL_glx_LIBRARY=${SYSROOT_PREFIX}/usr/lib/libGLX.so"

pre_configure_target() {
  # Patch CMakeLists.txt to make OpenGL optional/mock it for GLES builds
  sed -i 's/find_package(OpenGL REQUIRED)/find_package(OpenGL)/' ${PKG_BUILD}/CMakeLists.txt
  
  # Set OpenGL as found even if desktop OpenGL isn't available
  echo "set(OPENGL_FOUND TRUE)" >> ${PKG_BUILD}/CMakeLists.txt
  echo "set(OPENGL_LIBRARIES \"\")" >> ${PKG_BUILD}/CMakeLists.txt
  
  # Remove static linking flags that cause issues
  sed -i 's/-static-libgcc -static-libstdc++//' ${PKG_BUILD}/CMakeLists.txt
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/.${TARGET_NAME}/vircon32_libretro.so ${INSTALL}/usr/lib/libretro/
}