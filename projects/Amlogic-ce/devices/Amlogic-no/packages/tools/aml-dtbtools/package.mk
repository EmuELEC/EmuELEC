# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="aml-dtbtools"
PKG_VERSION="cce100f"
PKG_SHA256="8bcaa83fcc9e85c9c04930e7411447d96a97da0809c5ecd9af91c8b554133c41"
PKG_LICENSE="free"
PKG_SITE="https://github.com/Wilhansen/aml-dtbtools"
PKG_URL="https://github.com/Wilhansen/aml-dtbtools/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="gcc:host zlib:host dtc:host"
PKG_DEPENDS_TARGET="toolchain zlib dtc"
PKG_LONGDESC="AML DTB Tools"

PKG_MAKE_OPTS_HOST="dtbTool"
PKG_MAKE_OPTS_TARGET="dtbTool dtbSplit"

pre_make_host() {
  rm -f ${PKG_MAKE_OPTS_HOST}
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp dtbTool ${TOOLCHAIN}/bin
}

pre_make_target() {
  rm -f ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp dtbTool dtbSplit ${INSTALL}/usr/bin
}
