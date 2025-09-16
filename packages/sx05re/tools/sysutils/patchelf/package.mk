# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="patchelf"
PKG_VERSION="47dc18d0e5c1ff24f815177927940c294b1fde76"
PKG_SHA256="4799c754930293281966426f0aae596a629d1a1b77612f92b8ff8a98063d511c"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/NixOS/patchelf"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="A small utility to modify the dynamic linker and RPATH of ELF executables"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
./bootstrap.sh
}
