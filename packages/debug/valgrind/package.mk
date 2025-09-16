# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="valgrind"
PKG_VERSION="3.20.0"
PKG_SHA256="8536c031dbe078d342f121fa881a9ecd205cb5a78e639005ad570011bdb9f3c6"
PKG_LICENSE="GPL"
PKG_SITE="https://valgrind.org/"
PKG_URL="https://sourceware.org/pub/valgrind/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A tool to help find memory-management problems in programs"

if [ "${TARGET_ARCH}" = "arm" ]; then
  PKG_CONFIGURE_OPTS_TARGET="--enable-only32bit"
elif [ "${TARGET_ARCH}" = "aarch64" -o "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_CONFIGURE_OPTS_TARGET="--enable-only64bit"
fi
