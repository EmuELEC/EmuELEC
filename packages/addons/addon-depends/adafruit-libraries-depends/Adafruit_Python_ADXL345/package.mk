# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="Adafruit_Python_ADXL345"
PKG_VERSION="dca3d90b5477a304fa130f5cc90ea59e3968ce6f"
PKG_SHA256="22ec0fc6679cc3e9b5f0aff5cfeef34cbbf13e59aecfb829c2f0dc2d90b5fb8b"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/adafruit/${PKG_NAME}"
PKG_URL="https://github.com/adafruit/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="Python code to use the ADXL345 triple-axis accelerometer over I2C with a Raspberry Pi."
PKG_TOOLCHAIN="manual"
