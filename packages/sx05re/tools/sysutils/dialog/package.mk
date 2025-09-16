# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="dialog"
PKG_VERSION="1.3-20220117"
PKG_SHA256="754cb6bf7dc6a9ac5c1f80c13caa4d976e30a5a6e8b46f17b3bb9b080c31041f"
PKG_LICENSE="GNU-2.1"
PKG_SITE="https://invisible-mirror.net/archives/dialog"
PKG_URL="${PKG_SITE}/dialog-${PKG_VERSION}.tgz"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_LONGDESC="This version of dialog, formerly known as cdialog is based on the Debian package for dialog 0.9a"
PKG_TOOLCHAIN="auto"

PKG_CONFIGURE_OPTS_TARGET="--with-ncurses --disable-rpath-hack"


