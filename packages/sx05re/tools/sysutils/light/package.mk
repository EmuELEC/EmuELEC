# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="light"
PKG_VERSION="33f2316e5512762a5a33a62c78db7a435d9fec9b"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/haikarainen/light"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Light - A program to control backlights (and other hardware lights) in GNU/Linux"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
	./autogen.sh
}
