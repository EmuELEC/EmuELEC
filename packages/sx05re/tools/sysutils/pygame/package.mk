# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="pygame"
PKG_VERSION="ee0fc698531a0c14f3e6a06734d35f8460ab71f4"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/pygame/pygame"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer SDL2_net SDL2_ttf libpng libjpeg-turbo Python3"
PKG_LONGDESC="pygame (the library) is a Free and Open Source python programming language library for making multimedia applications like games built on top of the excellent SDL library. C, Python, Native, OpenGL. "
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib -L${SYSROOT_PREFIX}/lib"
  export LDSHARED="${CC} -shared"

  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" ${PKG_BUILD}/buildconfig/config_unix.py
  sed -i "s|freetype-config|${SYSROOT_PREFIX}/usr/bin/freetype-config|g" ${PKG_BUILD}/buildconfig/config_unix.py
  sed -i "s|raise SystemExit(\"Missing dependencies\")||g" ${PKG_BUILD}/buildconfig/config_unix.py
}

make_target() {
  LOCALBASE="${SYSROOT_PREFIX}/usr" python3 setup.py build
}

makeinstall_target() {
  python3 setup.py install --root=${INSTALL} --prefix=/usr 
}

post_makeinstall_target() {
  find ${INSTALL}/usr/lib/python*/site-packages/  -name "*.pyc" -exec rm -rf {} ";"
}
