# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gcc-linaro-aarch64-elf"
PKG_VERSION="4.9.4-2017.01"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="Linaro Aarch64 GNU Linux Binary Toolchain"
PKG_TOOLCHAIN="manual"

if [ "${MACHINE_HARDWARE_NAME}" = "aarch64" ]; then
  PKG_SHA256="7b2082188cd94f35ae2185d0c37c22d0100982f5a8e1875b9b03c416ec653fd1"
  PKG_URL="https://sources.coreelec.org/gcc-linaro-${PKG_VERSION}-aarch64-elf.tar.xz"
else
  PKG_SHA256="00c79aaf7ff9b1c22f7b0443a730056b3936561a4206af187ef61a4e3cab1716"
  PKG_URL="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/aarch64-elf/gcc-linaro-${PKG_VERSION}-x86_64_aarch64-elf.tar.xz"
fi

makeinstall_host() {
  mkdir -p $TOOLCHAIN/lib/gcc-linaro-aarch64-elf/
    cp -a * $TOOLCHAIN/lib/gcc-linaro-aarch64-elf
}
