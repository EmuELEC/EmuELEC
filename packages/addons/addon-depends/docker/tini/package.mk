# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Lukas Rusak (lrusak@libreelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tini"
PKG_VERSION="0.19.0"
PKG_SHA256="0fd35a7030052acd9f58948d1d900fe1e432ee37103c5561554408bdac6bbf0d"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/krallin/tini"
PKG_URL="https://github.com/krallin/tini/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Tini is a simplest init system."

PKG_MAKE_OPTS_TARGET="tini-static"

pre_configure_target(){
  sed -i "s|@tini_VERSION_GIT@| - git.${PKG_VERSION}|" ${PKG_BUILD}/src/tiniConfig.h.in
}

makeinstall_target() {
  :
}
