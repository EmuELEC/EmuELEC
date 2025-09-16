# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="t2scan"
PKG_VERSION="0.7"
PKG_SHA256="44e4b738a2beed8eb964be3d90b6da48c2d1c672d81fd8db8bbda87bcc433fcb"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/mighty-p/t2scan"
PKG_URL="https://github.com/mighty-p/t2scan/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A small channel scan tool which generates DVB-T/T2 channels.conf files."
PKG_BUILD_FLAGS="-sysroot"
