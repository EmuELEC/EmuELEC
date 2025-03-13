# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="parse-android-dynparts"
PKG_VERSION="c8837c1cd0c4fbc29641980b71079fc4f3cabcc0"
PKG_SHA256="5a9df34c2078ff947a478723e8b06dc427bc71c238125657a913536acb29146a"
PKG_LICENSE="Apache-2.0 license"
PKG_SITE="https://github.com/tchebb/parse-android-dynparts"
PKG_URL="https://github.com/tchebb/parse-android-dynparts/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl"
PKG_LONGDESC="Tool mounts super.img files with a standard Linux userspace tools."

PKG_CMAKE_OPTS_TARGET="-DCMAKE_CXX_FLAGS=-D_FILE_OFFSET_BITS=64"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
  cp ${PKG_BUILD}/.${TARGET_NAME}/parse-android-dynparts ${INSTALL}/usr/sbin
}
