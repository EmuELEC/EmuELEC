# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opengl-meson"
PKG_VERSION="8bfb8ebe38f615907852ada7ff375a04f53f3e81"
PKG_SHA256="9468dad254ef7b2486f738f594c5a78fbb1926a6661923ae10054d9960978ec7"
PKG_LICENSE="nonfree"
PKG_SITE="http://openlinux.amlogic.com:8000/download/ARM/filesystem/"
PKG_URL="https://github.com/CoreELEC/opengl-meson/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm opentee_linuxdriver"
PKG_LONGDESC="OpenGL ES pre-compiled libraries for Mali GPUs found in Amlogic Meson SoCs."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -p lib/arm64/gondul/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.gondul.g12b.so
    cp -p lib/arm64/dvalin/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.dvalin.g12a.so
    cp -p lib/arm64/gondul/r37p0/fbdev/libMali_r1p0.so ${INSTALL}/usr/lib/libMali.gondul.so
    cp -p lib/arm64/dvalin/r37p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.dvalin.so
    cp -p lib/arm64/valhall/r41p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.valhall.so
    
    mkdir -p ${SYSROOT_PREFIX}/usr/lib
	cp -p lib/arm64/gondul/r37p0/fbdev/libMali_r1p0.so ${SYSROOT_PREFIX}/usr/lib/libMali.so

   ln -sf /var/lib/libMali.so ${INSTALL}/usr/lib/libMali.so
	
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libmali.so
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libmali.so.0
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libEGL.so
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libEGL.so.1
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libEGL.so.1.0.0
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLES_CM.so.1
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv1_CM.so
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv1_CM.so.1
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv1_CM.so.1.0.1
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv1_CM.so.1.1
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv2.so
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv2.so.2
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv2.so.2.0
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv2.so.2.0.0
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv3.so
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv3.so.3
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv3.so.3.0
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libGLESv3.so.3.0.0

# install headers and libraries to TOOLCHAIN
	cp -rf ${PKG_BUILD}/include/* ${SYSROOT_PREFIX}/usr/include
	cp -rf ${PKG_BUILD}/pkgconfig/* ${SYSROOT_PREFIX}/usr/lib/pkgconfig
	cp ${SYSROOT_PREFIX}/usr/include/EGL_platform/platform_fbdev/* ${SYSROOT_PREFIX}/usr/include/EGL
	rm -rf ${SYSROOT_PREFIX}/usr/include/EGL_platform

    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libmali.so
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libMali.so.0
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libEGL.so
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libEGL.so.1
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libEGL.so.1.0.0
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLES_CM.so.1
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv1_CM.so
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv1_CM.so.1
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv1_CM.so.1.0.1
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv1_CM.so.1.1
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv2.so
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv2.so.2
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv2.so.2.0
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv2.so.2.0.0
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv3.so
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv3.so.3
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv3.so.3.0
    ln -sf ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv3.so.3.0.0

  mkdir -p ${INSTALL}/usr/sbin
    cp ${PKG_DIR}/scripts/libmali-overlay-setup ${INSTALL}/usr/sbin
  # install needed files for compiling
  mkdir -p ${SYSROOT_PREFIX}/usr/include/EGL
    cp -pr include/EGL ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_fbdev/* ${SYSROOT_PREFIX}/usr/include/EGL
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES2
    cp -pr include/GLES2 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES3
    cp -pr include/GLES3 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/KHR
    cp -pr include/KHR ${SYSROOT_PREFIX}/usr/include

}

post_install() {
  enable_service unbind-console.service
  enable_service libmali.service
}

