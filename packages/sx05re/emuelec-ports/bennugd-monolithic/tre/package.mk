# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="tre"
PKG_VERSION="6092368aabdd0dbb0fbceb2766a37b98e0ff6911"
PKG_ARCH="any"
PKG_SITE="https://github.com/laurikari/tre"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="The approximate regex matching library and agrep command line tool."
PKG_TOOLCHAIN="autotools"

pre_configure_target() {
sed -i "s|AM_GNU_GETTEXT_VERSION(0.17)|AM_GNU_GETTEXT_REQUIRE_VERSION(0.17)|" ${PKG_BUILD}/configure.ac
}

