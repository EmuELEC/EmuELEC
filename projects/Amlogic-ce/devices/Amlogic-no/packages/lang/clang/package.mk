# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present Team CoreELEC (https://coreelec.org)

PKG_NAME="clang"
# Android 14, Android U, 'Upside Down Cake'
PKG_VERSION="r487747c"
# sha changes with every download
PKG_SHA256=""
PKG_LICENSE="Apache License 2.0 with LLVM Exceptions"
PKG_SITE="https://android.googlesource.com"
PKG_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-14.0.0_r0.118/clang-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST=""
PKG_LONGDESC="Android Clang compiler"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${TOOLCHAIN}/lib/${PKG_NAME}
  tar -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${TOOLCHAIN}/lib/${PKG_NAME}
}
