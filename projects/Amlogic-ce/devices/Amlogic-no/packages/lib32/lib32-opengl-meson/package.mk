# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-opengl-meson"
PKG_VERSION="$(get_pkg_version opengl-meson)"
PKG_NEED_UNPACK="$(get_pkg_directory opengl-meson)"
PKG_ARCH="aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="http://openlinux.amlogic.com:8000/download/ARM/filesystem/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain opengl-meson lib32-libdrm"
PKG_LONGDESC="OpenGL ES pre-compiled libraries for Mali GPUs found in Amlogic Meson SoCs."
PKG_PATCH_DIRS+=" $(get_pkg_directory opengl-meson)/patches"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="lib32"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib32
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
  local DIR_MESON="$(get_build_dir opengl-meson)"
  local DIR_ARM=${DIR_MESON}/lib/eabihf
  local DIR_ARM_local=${PKG_DIR}/src/eabihf
  local SINGLE_LIBMALI='no'

  case "${DEVICE}" in 
    Amlogic-ng)
      cp -p ${DIR_ARM}/gondul/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.gondul.so
      cp -p ${DIR_ARM}/dvalin/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.dvalin.so
      cp -p ${DIR_ARM}/m450/r7p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.m450.so
      cp -p ${DIR_ARM}/gondul/r12p0/fbdev/libMali.so ${SYSROOT_PREFIX}/usr/lib/
    ;;
    Amlogic-old)
      cp -p ${DIR_ARM}/m450/r7p0/fbdev/libMali.so ${INSTALL}/usr/lib32/
      cp -p ${DIR_ARM}/m450/r7p0/fbdev/libMali.so ${SYSROOT_PREFIX}/usr/lib/
      SINGLE_LIBMALI='yes'
    ;;
    Amlogic-ne)
      cp -p ${DIR_ARM_local}/gondul/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.gondul.g12b.so
      cp -p ${DIR_ARM_local}/dvalin/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.dvalin.g12a.so
      cp -p ${DIR_ARM}/gondul/r37p0/fbdev/libMali_r1p0.so ${INSTALL}/usr/lib32/libMali.gondul.so
      cp -p ${DIR_ARM}/dvalin/r37p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.dvalin.so
      cp -p ${DIR_ARM}/valhall/r41p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.valhall.so
      cp -p ${DIR_ARM}/gondul/r37p0/fbdev/libMali_r1p0.so ${SYSROOT_PREFIX}/usr/lib/libMali.so
    ;;
    Amlogic-no)
      cp -p ${DIR_ARM_local}/gondul/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.gondul.g12b.so
      cp -p ${DIR_ARM_local}/dvalin/r12p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.dvalin.g12a.so
      cp -p ${DIR_ARM}/gondul/r37p0/fbdev/libMali_r1p0.so ${INSTALL}/usr/lib32/libMali.gondul.so
      cp -p ${DIR_ARM}/dvalin/r37p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.dvalin.so
      cp -p ${DIR_ARM}/valhall/r41p0/fbdev/libMali.so ${INSTALL}/usr/lib32/libMali.valhall.so
      cp -p ${DIR_ARM}/gondul/r37p0/fbdev/libMali_r1p0.so ${SYSROOT_PREFIX}/usr/lib/libMali.so
    ;;
    *)
      echo "${PKG_NAME}: Trying to install for device ${DEVICE} when only Amlogic-ng, Amlogic-old and Amlogic-ne are supported" 1>&2
      return 1
    ;;
  esac

  if [[ "${SINGLE_LIBMALI}" == 'yes' ]]; then
    ln -sf /var/lib32/libMali.so ${INSTALL}/usr/lib32/libMali.so
  fi

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
  for LINK_NAME in ${LINK_LIST}; do
    ln -sf libMali.so ${INSTALL}/usr/lib32/${LINK_NAME}
    ln -sf libMali.so ${SYSROOT_PREFIX}/usr/lib/${LINK_NAME}
  done

  # install headers and libraries to TOOLCHAIN
  cp -rf ${DIR_MESON}/include/* ${SYSROOT_PREFIX}/usr/include
  cp -rf "$(get_build_dir opengl-meson)/lib/pkgconfig/"* ${SYSROOT_PREFIX}/usr/lib/pkgconfig
  cp ${SYSROOT_PREFIX}/usr/include/EGL_platform/platform_fbdev/* ${SYSROOT_PREFIX}/usr/include/EGL
  rm -rf ${SYSROOT_PREFIX}/usr/include/EGL_platform
}

