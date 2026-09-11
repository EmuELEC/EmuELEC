# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="cargo-c"
PKG_VERSION="v0.10.12"
PKG_SHA256="ae118882067e1e7dcd8106933329cf018ddc6ea56cabfea7642a7699d6ce700f"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/lu-zero/cargo-c"
PKG_URL="https://github.com/lu-zero/cargo-c/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="cargo:host"
PKG_LONGDESC="Use Cargo-c to build and install C-compatible libraries"
PKG_TOOLCHAIN="manual"

make_host() {
  cargo build --release --manifest-path ${PKG_BUILD}/Cargo.toml
}

makeinstall_host() {
  cargo install --profile release --path ${PKG_BUILD}
}
