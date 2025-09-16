# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="sshfs"
PKG_VERSION="3.7.3"
PKG_SHA256="5218ce7bdd2ce0a34137a0d7798e0f6d09f0e6d21b1e98ee730a18b0699c2e99"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libfuse/sshfs"
PKG_URL="https://github.com/libfuse/sshfs/releases/download/sshfs-${PKG_VERSION}/sshfs-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain fuse3 glib"
PKG_LONGDESC="A filesystem client based on the SSH File Transfer Protocol."
PKG_BUILD_FLAGS="-sysroot"
