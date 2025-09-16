# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="pgi"
PKG_VERSION="0.0.11.2"
PKG_SHA256="7a1ca8ac4e8bee6b663e6d556ecda8032584de753acd76ab3fc21c4f874fa738"
PKG_ARCH="any"
PKG_LICENSE="LGPL"
PKG_SITE="https://github.com/pygobject/pgi"
PKG_URL="https://github.com/pygobject/pgi/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3"
PKG_SECTION="python/devel"
PKG_SHORTDESC="PGI - Pure Python GObject Introspection Bindings"
PKG_LONGDESC="GObject Introspection bindings written in pure Python using ctypes and cffi (optional). API compatible with PyGObject."
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PYTHONXCPREFIX="$SYSROOT_PREFIX/usr"
}

make_target() {
  exec_thread_safe python3 setup.py build
}

makeinstall_target() {
  exec_thread_safe python3 setup.py install --root=$INSTALL --prefix=/usr
}

post_makeinstall_target() {
  find $INSTALL/usr/lib -name "*.py" -exec rm -rf "{}" ";"
  rm -rf $INSTALL/usr/lib/python*/site-packages/*/tests
}
