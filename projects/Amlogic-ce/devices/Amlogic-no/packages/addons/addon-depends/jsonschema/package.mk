# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="jsonschema"
PKG_VERSION="4.23.0"
PKG_SHA256="d71497fef26351a33265337fa77ffeb82423f3ea21283cd9467bb03999266bc4"
PKG_LICENSE="MIT"
PKG_SITE="https://pypi.org/project/jsonschema/"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="Python3:host"
PKG_LONGDESC="An implementation of JSON Schema validation for Python."
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  cp -r ${PKG_BUILD}/jsonschema ${TOOLCHAIN}/lib/${PKG_PYTHON_VERSION}/site-packages
}
