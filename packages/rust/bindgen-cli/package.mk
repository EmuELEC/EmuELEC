# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2024-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bindgen-cli"
PKG_VERSION="0.72.0"
PKG_SHA256="1da7050a17fdab0e20d5d8c20d48cddce2973e8b7cb0afc15185bfad22f8ce5b"
PKG_LICENSE="BSD-3-Clause"
PKG_SITE="https://rust-lang.github.io/rust-bindgen/"
PKG_URL="https://github.com/rust-lang/rust-bindgen/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="cargo:host"
PKG_LONGDESC="Automatically generates Rust FFI bindings to C and some C++ libraries"
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
    cp -a ${PKG_BUILD}/.${RUST_HOST}/target/${RUST_HOST}/release/bindgen ${TOOLCHAIN}/bin/
}
