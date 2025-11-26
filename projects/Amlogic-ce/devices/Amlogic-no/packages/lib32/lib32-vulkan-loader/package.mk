# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lib32-vulkan-loader"
PKG_64NAME="vulkan-loader"
PKG_VERSION="$(get_pkg_version ${PKG_64NAME})"
PKG_NEED_UNPACK="$(get_pkg_directory ${PKG_64NAME})"
PKG_PATCH_DIRS+=" $(get_pkg_directory ${PKG_64NAME})/patches"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/Vulkan-Loader"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain Python3:host lib32-vulkan-headers"
PKG_LONGDESC="Vulkan Installable Client Driver (ICD) Loader."
PKG_BUILD_FLAGS="lib32"


unpack() {
  ${SCRIPTS}/get ${PKG_64NAME}
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_64NAME}/${PKG_64NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

configure_package() {
    PKG_DEPENDS_TARGET+=" wayland"
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTS=OFF"

  # GAS / GNU Assembler is only supported by aarch64 & x86_64
  if [ "${ARCH}" = "arm" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DUSE_GAS=OFF"
  fi

    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_WSI_XCB_SUPPORT=OFF \
                             -DBUILD_WSI_XLIB_SUPPORT=OFF \
                             -DBUILD_WSI_WAYLAND_SUPPORT=ON \
                             -DCMAKE_INSTALL_LIBDIR=lib32"

}
