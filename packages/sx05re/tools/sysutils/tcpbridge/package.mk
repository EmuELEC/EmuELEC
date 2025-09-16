# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Based on libreelec pycryptodome package

PKG_NAME="tcpbridge"
PKG_VERSION="b8d11ef8a33f5484fa4f48f5f50801f7418aebe5"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Cacaonut/tcpbridge"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="Python3 dbus-python"
PKG_LONGDESC="TCP bridge for data transfer."
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}

  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDSHARED="${CC} -shared"
}

make_target() {
  python setup.py build
}

makeinstall_target() {
  python setup.py install --root=${INSTALL} --prefix=/usr
}
