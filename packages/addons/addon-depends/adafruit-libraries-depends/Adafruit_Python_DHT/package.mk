# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="Adafruit_Python_DHT"
PKG_VERSION="18846deec6a96572b3f2c4a9edfb5bac55b46f5b"
PKG_SHA256="9125f8f42b4874db257a45184b866e8b424aa67230d2ffbc734b53686da7817f"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/adafruit/${PKG_NAME}"
PKG_URL="https://github.com/adafruit/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="Python library to read the DHT series of humidity and temperature sensors on a Raspberry Pi."
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDSHARED="${CC} -shared"
}

make_target() {
  case "${PROJECT}:${DEVICE}" in
    "RPi:RPi")
      PKG_RPI_VERSION="--force-pi"
      ;;
    "RPi:RPi2")
      PKG_RPI_VERSION="--force-pi2"
      ;;
    *)
      PKG_RPI_VERSION=""
  esac

  python3 setup.py build ${PKG_RPI_VERSION} --cross-compile
}
