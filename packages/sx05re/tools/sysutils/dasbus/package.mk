# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Based on libreelec pycryptodome package

PKG_NAME="dasbus"
PKG_VERSION="592f444f91707e6a23efe587b01592d09b3541f7"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/rhinstaller/dasbus"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="Python3 dbus-python tcpbridge"
PKG_LONGDESC="DBus library in Python 3 "
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
