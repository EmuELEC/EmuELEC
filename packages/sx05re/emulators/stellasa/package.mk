# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="stellasa"
PKG_VERSION="aaa6c154750119905190da49569fa9e2de7bb97b"
PKG_SHA256="050e37f670057125d8529c1d0305ab479c458f808e48bc3584431d1fc4f489fa"
PKG_REV="1"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/stella-emu/stella"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="A multi-platform Atari 2600 Emulator"
PKG_TOOLCHAIN="configure"

pre_configure_target() { 
TARGET_CONFIGURE_OPTS="--host=${TARGET_NAME} --with-sdl-prefix=${SYSROOT_PREFIX}/usr/bin --disable-windowed"
}

make_target() {
cd ${PKG_BUILD}
mv ${PKG_BUILD}/.${TARGET_NAME}/* ${PKG_BUILD}
make 
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp -rf ${PKG_BUILD}/stella ${INSTALL}/usr/bin
cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
