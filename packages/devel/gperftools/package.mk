# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gperftools"
PKG_VERSION="2.9.1"
PKG_SHA256="484a88279d2fa5753d7e9dea5f86954b64975f20e796a6ffaf2f3426a674a06a"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/gperftools/gperftools"
PKG_URL="https://github.com/gperftools/gperftools/archive/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Google Performance Tools"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-minimal --disable-debugalloc --disable-static"
