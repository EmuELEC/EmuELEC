# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="Adafruit_Python_BMP"
PKG_VERSION="e8521e969afae3321d9789353d7e92ea9a5e9a56"
PKG_SHA256="e5e140c34e312f6a00c62b1bd47ebe3f1857009b1c202c18c7b092ebb2e1eb9c"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/adafruit/${PKG_NAME}"
PKG_URL="https://github.com/adafruit/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="Python library for accessing the BMP series pressure and temperature sensors like the BMP085/BMP180 on a Raspberry Pi."
PKG_TOOLCHAIN="manual"
