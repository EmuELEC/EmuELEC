# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="cargo"
PKG_VERSION="$(get_pkg_version rust)"
PKG_LICENSE="MIT"
PKG_SITE="https://www.rust-lang.org"
PKG_DEPENDS_HOST="openssl:host rust:host"
PKG_DEPENDS_UNPACK="cargo-snapshot rust"
PKG_LONGDESC="Cargo is the Rust package manager"
PKG_TOOLCHAIN="manual"

pre_configure_host() {
  "$(get_build_dir cargo-snapshot)/install.sh" --prefix="${PKG_BUILD}/cargo-snapshot" --disable-ldconfig
}

configure_host() {
  cd ${PKG_BUILD}
}

make_host() {
  cd ${PKG_BUILD}

  export RUSTC_BOOTSTRAP="1"

  ./cargo-snapshot/bin/cargo build -v --target ${RUST_HOST} --release --manifest-path="$(get_build_dir rust)/src/tools/cargo/Cargo.toml"
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -a ${PKG_BUILD}/.${RUST_HOST}/target/${RUST_HOST}/release/cargo ${TOOLCHAIN}/bin/
}
