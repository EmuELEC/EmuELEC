# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="python3-protobuf"
PKG_VERSION="4f49062a95f18a6c7e21ba17715a2b0a4608151a"
PKG_SHA256="b96b86607ee0b1620b6cb512fa8ea01149493a9af01438906b006f685fd43e59"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/protocolbuffers/protobuf"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host protobuf"
PKG_DEPENDS_HOST="toolchain Python3:host distutilscross:host protobuf protobuf:host"
PKG_LONGDESC="Python 2 and 3 compatibility library "
PKG_TOOLCHAIN="manual"


make_host() {
 cd ${PKG_BUILD}/python
  python3 setup.py build
}

makeinstall_host() {
 cd ${PKG_BUILD}/python
  python3 setup.py install --prefix=${TOOLCHAIN}
}

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib -L${SYSROOT_PREFIX}/lib"
  export LDSHARED="${CC} -shared"
  cd ${PKG_BUILD}/python
}

make_target() {
cd ${PKG_BUILD}/python
  python3 setup.py build
}

makeinstall_target() {
  python3 setup.py install --root=${INSTALL} --prefix=/usr
}

post_makeinstall_target() {
  find ${INSTALL}/usr/lib/python*/site-packages/  -name "*.py" -exec rm -rf {} ";"
}
