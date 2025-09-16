# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet6-runtime"
PKG_VERSION="6.0.24"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="ee6b660b3c8b3fb88eb64690ac78a47752dae68c21647fccdc5f810bc68829ab"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/d562ba2b-8e2c-48e5-9853-f8616a9cb4e4/f4e251ba67b718083c28017e3b0c6349/aspnetcore-runtime-6.0.24-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="634b0ecd7312e8a46adedcbff6e1b23e514fa153f7135a6b9f6aefb5851f9d88"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/9c00fe25-e1e0-4390-9061-77d07e95356f/09886ffeaed522c3fa8803e879ce070c/aspnetcore-runtime-6.0.24-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="022dc914af7490bcd2d885edeb5d4c1faa4b771b503b8059d5181f130191cf2c"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/8f5a65c0-9bc8-497d-9ce2-4658c461dc55/b6c01c3cd060552d987501ba6bbde09f/aspnetcore-runtime-6.0.24-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
