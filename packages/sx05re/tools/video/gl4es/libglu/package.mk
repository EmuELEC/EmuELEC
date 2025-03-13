# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="libglu"
PKG_VERSION="2fed2bda2b725d2b9e32c435b48d5141cc95827f"
PKG_SHA256="8a016d32fc1fed742f10ba8e4bc32151598f6273a0dbabec15ba47c44151c879"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/ptitSeb/GLU"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gl4es"
PKG_LONGDESC=" GL4ES is a OpenGL 2.1/1.5 to GL ES 2.0/1.1 translation library, with support for Pandora, ODroid, OrangePI, CHIP, Raspberry PI, Android, Emscripten and AmigaOS4. "

PKG_CONFIGURE_OPTS_TARGET="--disable-static --enable-shared"

pre_configure_target() {
cp -rf $(get_build_dir gl4es)/lib/libGL.so.1 ${SYSROOT_PREFIX}/usr/lib/libGL.so
cp -rf $(get_build_dir gl4es)/include/GL/gl.h ${SYSROOT_PREFIX}/usr/include/GL/gl.h
cp -rf ${PKG_DIR}/gl.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
}


post_install_target() {
rm ${SYSROOT_PREFIX}/usr/lib/libGL.so
rm ${SYSROOT_PREFIX}/usr/include/GL/gl.h
rm ${SYSROOT_PREFIX}/usr/lib/pkgconfig/gl.pc
}
