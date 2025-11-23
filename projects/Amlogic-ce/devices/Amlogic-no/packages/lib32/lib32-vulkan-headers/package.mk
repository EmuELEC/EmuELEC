# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lib32-vulkan-headers"
PKG_64NAME="vulkan-headers"
PKG_VERSION="$(get_pkg_version ${PKG_64NAME})"
PKG_NEED_UNPACK="$(get_pkg_directory ${PKG_64NAME})"
PKG_PATCH_DIRS+=" $(get_pkg_directory ${PKG_64NAME})/patches"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/Vulkan-Headers"
PKG_URL=""
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Vulkan Header files and API registry"
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get ${PKG_64NAME}
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_64NAME}/${PKG_64NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}
