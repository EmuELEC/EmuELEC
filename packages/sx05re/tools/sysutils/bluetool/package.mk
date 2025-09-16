# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Based on libreelec pycryptodome package

PKG_NAME="bluetool"
PKG_VERSION="29570c71ed77d0db0ef19ac8d2172e8989fcecac"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/emlid/bluetool"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="Python3 dbus-python tcpbridge"
PKG_LONGDESC="A simple Python API for Bluetooth D-Bus calls. Allows easy pairing, connecting and scanning.Also provides a TCP-to-RFCOMM socket bridge for data transfer."
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
