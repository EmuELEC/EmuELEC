# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="slang"
PKG_VERSION="2.3.3"
PKG_SHA256="f9145054ae131973c61208ea82486d5dd10e3c5cdad23b7c4a0617743c8f5a18"
PKG_LICENSE="GPL"
PKG_SITE="http://www.jedsoft.org/slang/"
PKG_URL="https://www.jedsoft.org/releases/slang/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain pcre"
PKG_LONGDESC="A library designed to allow a developer to create robust multi-platform software."
PKG_BUILD_FLAGS="-parallel"

PKG_CONFIGURE_OPTS_TARGET="--without-onig"

pre_configure_target() {
 # slang fails to build in subdirs
 cd ${PKG_BUILD}
 sed -i 's|RPATH=".*"|RPATH=""|' configure
 rm -rf .${TARGET_NAME}
}

pre_configure_host() {
 # slang fails to build in subdirs
 cd ${PKG_BUILD}
 rm -rf .${HOST_NAME}
}
