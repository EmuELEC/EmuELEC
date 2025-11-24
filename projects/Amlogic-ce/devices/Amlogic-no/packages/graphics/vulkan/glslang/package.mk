# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="glslang"
# The SPIRV-Tools & SPIRV-Headers pkg_version/s need to match the compatible (known_good) glslang pkg_version.
# https://raw.githubusercontent.com/KhronosGroup/glslang/${PKG_VERSION}/known_good.json
# When updating glslang pkg_version please update to the known_good spirv-tools & spirv-headers pkg_version/s.
PKG_VERSION="16.0.0"
PKG_SHA256="172385478520335147d3b03a1587424af0935398184095f24beab128a254ecc7"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/glslang"
PKG_URL="https://github.com/KhronosGroup/glslang/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host Python3:host"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="Khronos-reference front end for GLSL/ESSL, partial front end for HLSL, and a SPIR-V generator."
PKG_DEPENDS_UNPACK="spirv-headers spirv-tools"

PKG_CMAKE_OPTS_COMMON="-DBUILD_EXTERNAL=ON \
                       -DENABLE_GLSLANG_JS=OFF \
                       -DENABLE_RTTI=OFF \
                       -DENABLE_EXCEPTIONS=OFF \
                       -DENABLE_OPT=ON \
                       -DENABLE_PCH=ON \
                       -DGLSLANG_TESTS=OFF \
                       -Wno-dev"

post_unpack() {
  # Enables SPIR-V optimizer capability needed for ENABLE_OPT CMake build option
  mkdir -p ${PKG_BUILD}/External/spirv-tools
    tar --strip-components=1 \
      -xf "${SOURCES}/spirv-tools/spirv-tools-$(get_pkg_version spirv-tools).tar.gz" \
      -C "${PKG_BUILD}/External/spirv-tools"
  mkdir -p ${PKG_BUILD}/External/spirv-tools/external/spirv-headers
    tar --strip-components=1 \
      -xf "${SOURCES}/spirv-headers/spirv-headers-$(get_pkg_version spirv-headers).tar.gz" \
      -C "${PKG_BUILD}/External/spirv-tools/external/spirv-headers"
}

pre_configure_host() {
  PKG_CMAKE_OPTS_HOST+="${PKG_CMAKE_OPTS_COMMON} \
                        -DBUILD_SHARED_LIBS=OFF"

}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+="${PKG_CMAKE_OPTS_COMMON} \
                          -DBUILD_SHARED_LIBS=ON \
                          -DENABLE_GLSLANG_BINARIES=OFF"
}
