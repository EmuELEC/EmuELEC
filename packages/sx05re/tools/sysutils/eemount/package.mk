# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="eemount"
PKG_VERSION="2321603bdc7a4c09cf805de0e3546512574d8360"
PKG_SHA256="12cf5fc00291d319f3e598b3b09ac14d591ba86075a61a7a9ed6bd21db16fc78"
PKG_SITE="https://github.com/7Ji/eemount"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="Multi-source ROMs mounting utility for EmuELEC"
PKG_TOOLCHAIN="make"
PKG_MAKE_OPTS_TARGET="LOGGING_ALL_TO_STDOUT=1"
