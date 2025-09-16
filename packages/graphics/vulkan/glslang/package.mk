# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="glslang"
# The SPIRV-Tools & SPIRV-Headers pkg_version/s need to match the compatible (known_good) glslang pkg_version.
# https://raw.githubusercontent.com/KhronosGroup/glslang/${PKG_VERSION}/known_good.json
# When updating glslang pkg_version please update to the known_good spirv-tools & spirv-headers pkg_version/s.
PKG_VERSION="12.0.0"
PKG_SHA256="7cb45842ec1d4b6ea775d624c3d2d8ba9450aa416b0482b0cc7e4fdd399c3d75"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/glslang"
PKG_URL="https://github.com/KhronosGroup/glslang/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host Python3:host"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_LONGDESC="Khronos-reference front end for GLSL/ESSL, partial front end for HLSL, and a SPIR-V generator."
PKG_DEPENDS_UNPACK="spirv-headers spirv-tools"

PKG_CMAKE_OPTS_COMMON="-DBUILD_EXTERNAL=ON \
                       -DENABLE_SPVREMAPPER=OFF \
                       -DENABLE_GLSLANG_JS=OFF \
                       -DENABLE_RTTI=OFF \
                       -DENABLE_EXCEPTIONS=OFF \
                       -DENABLE_OPT=ON \
                       -DENABLE_PCH=ON \
                       -DENABLE_CTEST=OFF \
                       -DUSE_CCACHE=ON \
                       -Wno-dev"

post_unpack() {
  # Enables SPIR-V optimzer capability needed for ENABLE_OPT CMake build option
  mkdir -p ${PKG_BUILD}/External/spirv-tools/external/spirv-headers
    cp -R $(get_build_dir spirv-tools)/* ${PKG_BUILD}/External/spirv-tools
    cp -R $(get_build_dir spirv-headers)/* ${PKG_BUILD}/External/spirv-tools/external/spirv-headers
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
