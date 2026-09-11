# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="cbindgen"
PKG_VERSION="0.29.4"
PKG_SHA256="9b5757e915cf8be523d3aca282b9b5651bafa112e14bf1ba488562ba282807d6"
PKG_LICENSE="MPL-2.0"
PKG_SITE="https://github.com/mozilla/bindgen"
PKG_URL="https://github.com/mozilla/cbindgen/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="cargo:host"
PKG_LONGDESC="A project for generating C bindings from Rust code"
PKG_TOOLCHAIN="manual"

configure_host() {
  cd ${PKG_BUILD}
}

make_host() {
  cd ${PKG_BUILD}

  cargo build -v --target ${RUST_HOST} --release
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -a ${PKG_BUILD}/.${RUST_HOST}/target/${RUST_HOST}/release/cbindgen ${TOOLCHAIN}/bin/
}
