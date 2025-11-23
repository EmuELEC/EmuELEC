# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lib32-vulkan-tools"
PKG_64NAME="vulkan-tools"
PKG_VERSION="$(get_pkg_version ${PKG_64NAME})"
PKG_NEED_UNPACK="$(get_pkg_directory ${PKG_64NAME})"
PKG_PATCH_DIRS+=" $(get_pkg_directory ${PKG_64NAME})/patches"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/Vulkan-Tools"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-vulkan-loader glslang:host"
PKG_LONGDESC="This project provides Khronos official Vulkan Tools and Utilities."
PKG_BUILD_FLAGS="lib32"

unpack() {
  ${SCRIPTS}/get ${PKG_64NAME}
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/${PKG_64NAME}/${PKG_64NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

configure_package() {
  # Displayserver Support
  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_DEPENDS_TARGET+=" libxcb libX11"
  elif [ "${DISPLAYSERVER}" = "wl" ]; then
    PKG_DEPENDS_TARGET+=" wayland"
  fi
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DVULKAN_HEADERS_INSTALL_DIR=${SYSROOT_PREFIX}/usr \
                         -DBUILD_VULKANINFO=ON \
                         -DBUILD_ICD=OFF \
                         -DINSTALL_ICD=OFF \
                         -DBUILD_WSI_DIRECTFB_SUPPORT=OFF \
                         -Wno-dev"

  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_CUBE=ON \
                             -DBUILD_WSI_XCB_SUPPORT=ON \
                             -DBUILD_WSI_XLIB_SUPPORT=ON \
                             -DBUILD_WSI_WAYLAND_SUPPORT=OFF \
                             -DCUBE_WSI_SELECTION=XCB"
  elif [ "${DISPLAYSERVER}" = "wl" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_CUBE=ON \
                             -DBUILD_WSI_XCB_SUPPORT=OFF \
                             -DBUILD_WSI_XLIB_SUPPORT=OFF \
                             -DBUILD_WSI_WAYLAND_SUPPORT=ON
                             -DCUBE_WSI_SELECTION=WAYLAND"
  else
    PKG_CMAKE_OPTS_TARGET+=" -DBUILD_CUBE=ON \
                             -DBUILD_WSI_XCB_SUPPORT=OFF \
                             -DBUILD_WSI_XLIB_SUPPORT=OFF \
                             -DBUILD_WSI_WAYLAND_SUPPORT=OFF \
                             -DCUBE_WSI_SELECTION=DISPLAY"
  fi
}

pre_make_target() {
  # Fix cross compiling
  find ${PKG_BUILD} -name flags.make -exec sed -i  "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

post_makeinstall_target() {
  # Clean up - two graphic test tools are superflous
  safe_remove ${INSTALL}/usr/bin/vkcubepp
}
