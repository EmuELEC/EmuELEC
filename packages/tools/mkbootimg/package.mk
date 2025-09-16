# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mkbootimg"
PKG_VERSION="6668fc24a3130ab003aae9fda95bcd4110617de9"
PKG_SHA256="d84870e055414d638a3e7eb4b7a3ebf415899841218f24cb3647d06ecf6ddb17"
PKG_LICENSE="GPL"
PKG_SITE="https://android.googlesource.com/platform/system/core/+/master/mkbootimg/"
PKG_URL="https://github.com/codesnake/mkbootimg/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_LONGDESC="mkbootimg: Creates kernel boot images for Android"

makeinstall_host() {
  mkdir -p ${SYSROOT_PREFIX}/usr/include
  cp mkbootimg ${TOOLCHAIN}/bin/
}
