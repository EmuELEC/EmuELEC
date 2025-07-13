# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opengl-meson"
PKG_VERSION="80d86501568a39f7d521bee204e65c9805af600d"
PKG_SHA256="06e03211fd5766e55e201e6d13b7fd0f4c543c04b803a554eec565ab7649f488"
PKG_LICENSE="nonfree"
PKG_SITE="http://openlinux.amlogic.com:8000/download/ARM/filesystem/"
PKG_URL="https://github.com/CoreELEC/opengl-meson/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm opentee_linuxdriver"
PKG_LONGDESC="OpenGL ES pre-compiled libraries for Mali GPUs found in Amlogic Meson SoCs."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  local _ARCH
  case "${ARCH}" in
    'arm')
      _ARCH=eabihf
      ;;
    'aarch64')
      _ARCH=arm64
      ;;
    *)
      echo "${PKG_NAME} could not be installed for ${ARCH} !!!" >&2
      false
      ;;
  esac
  mkdir -p ${INSTALL}/usr/lib
    cp -p lib/${_ARCH}/gondul/r25p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.gondul.so
    cp -p lib/${_ARCH}/dvalin/r25p0/fbdev/libMali.so ${INSTALL}/usr/lib/libMali.dvalin.so

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
    cp -pr include/* ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_fbdev/* ${SYSROOT_PREFIX}/usr/include/EGL
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp -pr lib/pkgconfig ${SYSROOT_PREFIX}/usr/lib
    cp -p lib/${_ARCH}/gondul/r25p0/fbdev/libMali.so ${SYSROOT_PREFIX}/usr/lib/libMali.so
    local LINK_LIST="libmali.so \
                      libmali.so.0 \
                      libEGL.so \
                      libEGL.so.1 \
                      libEGL.so.1.0.0 \
                      libGLES_CM.so.1 \
                      libGLESv1_CM.so \
                      libGLESv1_CM.so.1 \
                      libGLESv1_CM.so.1.0.1 \
                      libGLESv1_CM.so.1.1 \
                      libGLESv2.so \
                      libGLESv2.so.2 \
                      libGLESv2.so.2.0 \
                      libGLESv2.so.2.0.0 \
                      libGLESv3.so \
                      libGLESv3.so.3 \
                      libGLESv3.so.3.0 \
                      libGLESv3.so.3.0.0"
    local LINK_NAME
    for LINK_NAME in $LINK_LIST; do
      ln -sf libMali.so ${SYSROOT_PREFIX}/usr/lib/${LINK_NAME}
    done
}

post_install() {
  enable_service unbind-console.service
  enable_service libmali.service
}
