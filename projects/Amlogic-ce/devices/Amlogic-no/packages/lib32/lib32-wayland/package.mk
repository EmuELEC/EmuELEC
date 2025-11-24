# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present Team EmuELEC (https://emuelec.org)

PKG_NAME="lib32-wayland"
PKG_64NAME="wayland"
PKG_VERSION="$(get_pkg_version ${PKG_64NAME})"
PKG_NEED_UNPACK="$(get_pkg_directory ${PKG_64NAME})"
PKG_LICENSE="OSS"
PKG_SITE="https://wayland.freedesktop.org/"
PKG_URL=""
PKG_DEPENDS_HOST="toolchain:host lib32-expat:host lib32-libxml2:host"
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libpciaccess lib32-libffi lib32-expat lib32-libxml2 lib32-wayland:host"
PKG_PATCH_DIRS+=" $(get_pkg_directory ${PKG_64NAME})/patches"
PKG_LONGDESC="a display server protocol"
PKG_BUILD_FLAGS="lib32"

PKG_MESON_OPTS_HOST="-Dlibraries=false \
                     -Dscanner=true \
                     -Dtests=false \
                     -Ddocumentation=false \
                     -Ddtd_validation=false"

PKG_MESON_OPTS_TARGET="-Dlibraries=true \
                       -Dscanner=false \
                       -Dtests=false \
                       -Ddocumentation=false \
                       -Ddtd_validation=false
                       --libdir=/usr/lib"


unpack() {
  ${SCRIPTS}/get ${PKG_64NAME}
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_64NAME}/${PKG_64NAME}-${PKG_VERSION}.tar.xz -C ${PKG_BUILD}
}


pre_configure_target() {
  # wayland does not build with NDEBUG (requires assert for tests)
  export TARGET_CFLAGS=$(echo ${TARGET_CFLAGS} | sed -e "s|-DNDEBUG||g")
}


post_makeinstall_host() {
  cp ${TOOLCHAIN}/lib/pkgconfig/wayland-scanner.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig/
  mkdir -p ${SYSROOT_PREFIX}/usr/share/wayland
    cp ${TOOLCHAIN}/share/wayland/wayland.xml ${SYSROOT_PREFIX}/usr/share/wayland/
}
