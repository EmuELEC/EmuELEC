# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-scummvm"
PKG_VERSION="0b219a46770776e10c954c6242870928113cacc0"
PKG_SHA256="aff5f337ec9b6d5baa951610eec5f405c20f8840b53cac9a4fcaf061de9ac2cc"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/scummvm-wrapper"
PKG_URL="https://github.com/libretro/scummvm-wrapper/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.scummvm: scummvm for Kodi"
PKG_TOOLCHAIN="make"

PKG_LIBNAME="scummvm_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="SCUMMVM_LIB"

PKG_MAKE_OPTS_TARGET="platform=unix GIT_VERSION=${PKG_VERSION:0:7}"

pre_configure_target() {
  cd ${PKG_BUILD}

  if [ "${TARGET_ARCH}" = "arm" ]; then
    PKG_MAKE_OPTS_TARGET+=" TARGET_64BIT=0"
  else
    PKG_MAKE_OPTS_TARGET+=" TARGET_64BIT=1"
  fi

  if target_has_feature neon; then
    PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
  fi

  if [ "${BUILD_WITH_DEBUG}" = "yes" ]; then
    PKG_MAKE_OPTS_TARGET+=" DEBUG=1"
  fi
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
