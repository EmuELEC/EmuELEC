# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opengl-meson"
PKG_VERSION="e8876882426dd283c95bc30e98ccfd13954426db"
PKG_SHA256=""
PKG_LICENSE="nonfree"
PKG_SITE="http://openlinux.amlogic.com:8000/download/ARM/filesystem/"
PKG_URL="https://github.com/CoreELEC/opengl-meson/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm opentee_linuxdriver"
PKG_LONGDESC="OpenGL ES pre-compiled libraries for Mali GPUs found in Amlogic Meson SoCs."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
	# Copy vulkan icd.d
	mkdir -p ${INSTALL}/usr/share/vulkan
	cp -pr lib/arm64/vulkan/r44p0/icd* ${INSTALL}/usr/share/vulkan/


  mkdir -p ${INSTALL}/usr/lib
    cp -p lib/arm64/gondul/r44p0/gbm/libMali.so ${INSTALL}/usr/lib/libMali.gondul.g12b.so
    cp -p lib/arm64/gondul/r44p0/gbm/libMali_r1p0.so ${INSTALL}/usr/lib/libMali.gondul.so
    cp -p lib/arm64/dvalin/r44p0/wayland/drm/libMali_dmaheap.so ${INSTALL}/usr/lib/libMali.dvalin.so
    cp -p lib/arm64/valhall/r44p0/wayland/libMali_g57_dmaheap.so ${INSTALL}/usr/lib/libMali.valhall.g57.so
    cp -p lib/arm64/valhall/r44p0/wayland/libMali_g310_dmaheap.so ${INSTALL}/usr/lib/libMali.valhall.g310.so

	cp -p lib/arm64/valhall/r44p0/wayland/libMali_g310_dmaheap.so ${SYSROOT_PREFIX}/usr/lib/libMali.so

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
    ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libgbm.so	
	ln -sf /usr/lib/libMali.so ${INSTALL}/usr/lib/libgbm.so.1

  mkdir -p ${INSTALL}/usr/sbin
    cp ${PKG_DIR}/scripts/libmali-overlay-setup ${INSTALL}/usr/sbin
  # install needed files for compiling
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_gbm/gbm/* ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/EGL
    cp -pr include/EGL ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_fbdev/* ${SYSROOT_PREFIX}/usr/include/EGL &2>/dev/null
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES2
    cp -pr include/GLES2 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES3
    cp -pr include/GLES3 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/KHR
    cp -pr include/KHR ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -pr lib/pkgconfig/gbm/gbm.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -pr lib/pkgconfig/egl.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -pr lib/pkgconfig/glesv2.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    
    
    ln ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libgbm.so
    ln ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libEGL.so
    ln ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv2.so
    ln ${SYSROOT_PREFIX}/usr/lib/libMali.so ${SYSROOT_PREFIX}/usr/lib/libGLESv3.so
}

post_install() {
  enable_service unbind-console.service
  enable_service libmali.service
}
