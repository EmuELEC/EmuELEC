# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="jslisten"
PKG_VERSION="f6842f6be8ffff2013ce4a7f56b421bed61c269c"
PKG_SHA256="9ad886915544ca620b751de65fd8337613de94c742fbac550d13d8a6f692dea3"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/shantigilbert/jslisten"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_GIT_CLONE_BRANCH="EmuELEC"
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="listen to gamepad inputs and trigger a command, cloned from https://github.com/workinghard/jslisten"
PKG_TOOLCHAIN="make"

make_target() {
mkdir bin
make 
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp bin/jslisten ${INSTALL}/usr/bin
} 
