# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="Adafruit_Python_WS2801"
PKG_VERSION="d0c190715ffef1b00e5ffa2d7b7560e7f8ed4263"
PKG_SHA256="6219edb5c1d767ff950f5020bacdfb5ba608b4995eb14d6073fdec2f17f584cb"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/adafruit/${PKG_NAME}"
PKG_URL="https://github.com/adafruit/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="Python code to control WS2801 and similar SPI interface addressable RGB LED strips on a Raspberry Pi."
PKG_TOOLCHAIN="manual"
