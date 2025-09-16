# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="virtual"
PKG_VERSION=""
PKG_LICENSE="GPL"
PKG_SITE="http://www.libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="qemu:host"
PKG_SECTION="virtual"
PKG_LONGDESC="virtual is a Meta package to install Virtual project extra dependencies"

get_graphicdrivers

listcontains "${GRAPHIC_DRIVERS}" "vmware" && PKG_DEPENDS_TARGET+=" open-vm-tools" || true
