# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="megatools"
# Using archive.org - original megatools.megous.com is dead
PKG_VERSION="1.11.0"
PKG_SHA256="d27c36f3c94b4d24a4a63b2a2b57a8e67a0a78f79821aeab2f4cf2b6e7df8cb1"
PKG_LICENSE="GPL"
PKG_SITE="https://megatools.megous.com/"
PKG_URL="https://web.archive.org/web/20231001000000id_/https://megatools.megous.com/builds/megatools-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glib openssl curl"
PKG_LONGDESC="Megatools is a collection of programs for accessing Mega.nz service from a command line of your desktop or server."
PKG_TOOLCHAIN="meson"
