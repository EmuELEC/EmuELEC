# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="viceSA"
PKG_VERSION="3.3"
PKG_SHA256="1a55b38cc988165b077808c07c52a779d181270b28c14b5c9abf4e569137431d"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE="https://freefr.dl.sourceforge.net/project/vice-emu/releases"
PKG_URL="${PKG_SITE}/vice-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer SDL2_ttf xa:host ffmpeg"
PKG_LONGDESC="VICE is an emulator collection which emulates the C64, the C64-DTV, the C128, the VIC20, practically all PET models, the PLUS4 and the CBM-II (aka C610)."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET=" --enable-external-ffmpeg --disable-option-checking --enable-midi --enable-lame --with-zlib --with-jpeg --with-png --enable-x64"

pre_configure_target() {
	LDFLAGS="${LDFLAGS} -lSDL2"
}
