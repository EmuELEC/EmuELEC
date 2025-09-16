# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-libgo2"
PKG_VERSION="$(get_pkg_version libgo2)"
PKG_NEED_UNPACK="$(get_pkg_directory libgo2)"
PKG_ARCH="aarch64"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/OtherCrashOverride/libgo2"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libevdev lib32-librga lib32-libpng lib32-openal-soft lib32-${OPENGLES}"
PKG_PATCH_DIRS+=" $(get_pkg_directory libgo2)/patches"
PKG_LONGDESC="Support library for the ODROID-GO Advance "
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="lib32"

if [ "${DEVICE}" = "GameForce" ]; then
  PKG_PATCH_DIRS+=" ${PROJECT_DIR}/Rockchip/devices/GameForce/patches/libgo2"
fi

PKG_MAKE_OPTS_TARGET="config=release ARCH= INCLUDES=-I${LIB32_SYSROOT_PREFIX}/usr/include/libdrm -I${LIB32_SYSROOT_PREFIX}/usr/include"

unpack() {
  ${SCRIPTS}/get libgo2
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/libgo2/libgo2-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib32 \
           ${SYSROOT_PREFIX}/usr/include/go2 \
           ${SYSROOT_PREFIX}/usr/lib
  cp libgo2.so ${INSTALL}/usr/lib32/
  cp src/*.h ${SYSROOT_PREFIX}/usr/include/go2/
  cp libgo2.so ${SYSROOT_PREFIX}/usr/lib/
}
