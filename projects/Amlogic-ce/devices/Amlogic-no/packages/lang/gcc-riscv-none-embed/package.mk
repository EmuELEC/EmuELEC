# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gcc-riscv-none-embed"
PKG_VERSION="8.3.0-1.2"
PKG_SHA256="079a88d7f7c18cfd735a9ed1f0eefa28ab28d3007b5f7591920ab25225c89248"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack"
PKG_URL="https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/download/v${PKG_VERSION}/xpack-riscv-none-embed-gcc-${PKG_VERSION}-linux-x64.tar.gz"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="RISC-V GCC"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  mkdir -p ${TOOLCHAIN}/lib/${PKG_NAME}

  tar --strip-components=1 -xf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${TOOLCHAIN}/lib/${PKG_NAME}
}

makeinstall_host() {
  : # nothing, unpacked directly to toolchain
}
