# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="jsonschema"
PKG_VERSION="4.17.3"
PKG_SHA256="0f864437ab8b6076ba6707453ef8f98a6a0d512a80e93f8abdb676f737ecb60d"
PKG_LICENSE="MIT"
PKG_SITE="https://pypi.org/project/jsonschema/"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="Python3:host attrs:host pyrsistent:host"
PKG_LONGDESC="An implementation of JSON Schema validation for Python."
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  cp -r ${PKG_BUILD}/jsonschema ${TOOLCHAIN}/lib/${PKG_PYTHON_VERSION}/site-packages
}
