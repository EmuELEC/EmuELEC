# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-mame2010"
PKG_VERSION="5f524dd5fca63ec1dcf5cca63885286109937587"
PKG_SHA256="deb2a5126fcf9791ebaaba604143b6fb1bf4fa48fdc7a2ef919c900a3f9e4d69"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame2010-libretro"
PKG_URL="https://github.com/libretro/mame2010-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="Late 2010 version of MAME (0.139) for libretro"

PKG_LIBNAME="mame2010_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="MAME2010_LIB"

pre_configure_target() {
  export CFLAGS="${CFLAGS} -fpermissive"
  export CXXFLAGS="${CXXFLAGS} -fpermissive"
  export LD="${CXX}"

  case ${TARGET_CPU} in
    arm1176jzf-s)
      PKG_MAKE_OPTS_TARGET="platform=armv6-hardfloat-${TARGET_CPU}"
      ;;
    cortex-a7|cortex-a8|cortex-a9)
      PKG_MAKE_OPTS_TARGET="platform=armv7-neon-hardfloat-${TARGET_CPU}"
      ;;
    *cortex-a53|cortex-a17)
      if [ "${TARGET_ARCH}" = "aarch64" ]; then
        PKG_MAKE_OPTS_TARGET="platform=unix PTR64=1 ARM_ENABLED=1 LCPU=arm64"
      else
        PKG_MAKE_OPTS_TARGET="platform=armv7-neon-hardfloat-cortex-a9"
      fi
      ;;
  esac
}

pre_make_target() {
  # precreate the build directories because they may be created too late
  make ${PKG_MAKE_OPTS_TARGET} maketree
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
