# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gcc-linaro-arm-eabi"
PKG_VERSION="4.9.4-2017.01"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="Linaro ARM GNU Linux Binary Toolchain"
PKG_TOOLCHAIN="manual"

if [ "${MACHINE_HARDWARE_NAME}" = "aarch64" ]; then
  PKG_SHA256="4b9a62d912de4c1fd2153e6652fbd296a62ac081515b6625edf3b8e0388ac6dd"
  PKG_URL="https://sources.coreelec.org/gcc-linaro-${PKG_VERSION}-arm-eabi.tar.xz"
else
  PKG_SHA256="5fa170a74db172dca098c70ae58f4c08d2fca0232ce135530b2ef4996326b4bd"
  PKG_URL="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-eabi/gcc-linaro-${PKG_VERSION}-x86_64_arm-eabi.tar.xz"
fi

makeinstall_host() {
  mkdir -p $TOOLCHAIN/lib/gcc-linaro-arm-eabi/
    cp -a * $TOOLCHAIN/lib/gcc-linaro-arm-eabi
}
