# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="megatools"
PKG_VERSION="1.10.3"
PKG_SHA256="8dc1ca348633fd49de7eb832b323e8dc295f1c55aefb484d30e6475218558bdb"
PKG_LICENSE="GPL"
PKG_SITE="https://megatools.megous.com/"
PKG_URL="https://megatools.megous.com/builds/megatools-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib openssl curl"
PKG_LONGDESC="Megatools is a collection of programs for accessing Mega.nz service from a command line of your desktop or server."
PKG_TOOLCHAIN="configure"
PKG_CONFIGURE_OPTS_TARGET="--disable-docs"
