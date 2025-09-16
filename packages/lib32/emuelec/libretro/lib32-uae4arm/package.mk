# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-uae4arm"
PKG_VERSION="$(get_pkg_version uae4arm)"
PKG_NEED_UNPACK="$(get_pkg_directory uae4arm)"
PKG_ARCH="aarch64"
PKG_REV="1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/uae4arm-libretro"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain"
PKG_PATCH_DIRS+=" $(get_pkg_directory uae4arm)/patches"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of uae4arm for libretro (rpi/android)"
PKG_LONGDESC="Port of uae4arm for libretro (rpi/android) "

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
PKG_BUILD_FLAGS="lib32 -lto"

unpack() {
  ${SCRIPTS}/get uae4arm
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/uae4arm/uae4arm-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

make_target() {
  CFLAGS="${CFLAGS} -DARM -marm"
  if [[ "${LIB32_TARGET_FPU}" =~ "neon" ]]; then
    CFLAGS="-D__NEON_OPT"
  fi
  make HAVE_NEON=1 USE_PICASSO96=1
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp uae4arm_libretro.so ${INSTALL}/usr/lib/libretro/uae4arm_32b_libretro.so
}
