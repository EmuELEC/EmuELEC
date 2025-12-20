# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="pyrsistent"
PKG_VERSION="0.19.3"
PKG_SHA256="1a2994773706bbb4995c31a97bc94f1418314923bd1048c6d964837040376440"
PKG_LICENSE="GPL"
PKG_SITE="https://pypi.org/project/pyrsistent/"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="Python3:host setuptools:host"
PKG_LONGDESC="Persistent/Functional/Immutable data structures."
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  exec_thread_safe python3 setup.py install --prefix=${TOOLCHAIN}
}
