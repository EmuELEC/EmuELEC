# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="attrs"
PKG_VERSION="22.2.0"
PKG_SHA256="c9227bfc2f01993c03f68db37d1d15c9690188323c067c641f1a35ca58185f99"
PKG_LICENSE="GPL"
PKG_SITE="https://pypi.org/project/attrs/"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="Python3:host setuptools:host"
PKG_LONGDESC="Classes Without Boilerplate."
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  exec_thread_safe python3 setup.py install --prefix=${TOOLCHAIN}
}
