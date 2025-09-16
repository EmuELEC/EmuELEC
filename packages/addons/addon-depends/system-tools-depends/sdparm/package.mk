# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="sdparm"
PKG_VERSION="1.12"
PKG_SHA256="c4c9efafdbeb662e2f9712707ec490932bd4d010bb1129ae7a99526546eeadbe"
PKG_LICENSE="BSD"
PKG_SITE="https://sg.danny.cz/sg/sdparm.html"
PKG_URL="https://sg.danny.cz/sg/p/sdparm-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="The sdparm utility accesses SCSI device parameters."
PKG_BUILD_FLAGS="-sysroot"
