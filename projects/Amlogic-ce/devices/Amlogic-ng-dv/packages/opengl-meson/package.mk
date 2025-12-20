# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opengl-meson"
PKG_VERSION="7bddce621a0c1e0cc12cfc8b707e93eb37fc0f82"
PKG_SHA256="15400e78b918b15743b815c195be472899d4243143e405a7b50d5be1cd07ffd1"
PKG_LICENSE="nonfree"
PKG_SITE="http://openlinux.amlogic.com:8000/download/ARM/filesystem/"
PKG_URL="https://github.com/CoreELEC/opengl-meson/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain opentee_linuxdriver"
PKG_LONGDESC="OpenGL ES pre-compiled libraries for Mali GPUs found in Amlogic Meson SoCs."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib
    cp -p lib/eabihf/gondul/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.gondul.so

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

  mkdir -p ${INSTALL}/usr/sbin
    cp ${PKG_DIR}/scripts/libmali-overlay-setup ${INSTALL}/usr/sbin
  # install needed files for compiling
  mkdir -p ${SYSROOT_PREFIX}/usr/include/EGL
    cp -pr include/EGL ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_fbdev/* ${SYSROOT_PREFIX}/usr/include/EGL
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES2
    cp -pr include/GLES2 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/KHR
    cp -pr include/KHR ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -pr lib/pkgconfig ${SYSROOT_PREFIX}/usr/lib
    ln ${INSTALL}/usr/lib/libMali.gondul.so ${SYSROOT_PREFIX}/usr/lib/libEGL.so
    ln ${INSTALL}/usr/lib/libMali.gondul.so ${SYSROOT_PREFIX}/usr/lib/libGLESv2.so
}

post_install() {
  enable_service unbind-console.service
  enable_service libmali.service
}
