# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libseccomp"
PKG_VERSION="2.5.4"
PKG_SHA256="d82902400405cf0068574ef3dc1fe5f5926207543ba1ae6f8e7a1576351dcbdb"
PKG_LICENSE="LGPLv2.1"
PKG_SITE="https://github.com/seccomp/libseccomp"
PKG_URL="https://github.com/seccomp/libseccomp/releases/download/v${PKG_VERSION}/libseccomp-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="An easy to use, platform independent, interface to the Linux Kernel syscall filtering mechanism"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET+=" --enable-static --enable-shared"
