# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

PKG_NAME="libdovi"
PKG_VERSION="3ec01dccbf5a74dfc7c58e3864029187b715344f"
PKG_SITE="https://github.com/quietvoid/dovi_tool"
PKG_DEPENDS_TARGET="toolchain"
if [ "${BUILD_FROM_SRC}" = "yes" ]; then
  PKG_SHA256="9483c81af5ca34ad8081ee71b0c31bdb92114d29bdcb664774ede4071c3fcea2"
  PKG_URL="https://github.com/quietvoid/dovi_tool/archive/${PKG_VERSION}.tar.gz"
  PKG_DEPENDS_TARGET+=" cargo-c:host"
else
  case "${TARGET_ARCH}" in
    "arm")
      PKG_SHA256="e034776d5e8fbad6f22092cd06c7a94252962467de7ae298cc98f2823281f8fa"
      ;;
    "aarch64")
      PKG_SHA256="6807b37cb55d49953196cc150941e6fe26c7deb42e25d266d82bb37b29e3c612"
      ;;
  esac
  PKG_SOURCE_NAME="${PKG_NAME}-${ARCH}-${PKG_VERSION}.tar.xz"
  PKG_URL="https://sources.coreelec.org/${PKG_SOURCE_NAME}"
fi
PKG_LICENSE="MIT"
PKG_LONGDESC="dovi_tool is a CLI tool combining multiple utilities for working with Dolby Vision."
PKG_TOOLCHAIN="manual"

if [ "${BUILD_FROM_SRC}" = "yes" ]; then
pre_make_target() {
  CARGO_BASE_OPTS="--manifest-path ${PKG_BUILD}/dolby_vision/Cargo.toml \
                   --target ${TARGET_NAME}"
  CARGO_BUILD_OPTS="--library-type staticlib \
                    --profile release \
                    --prefix /usr
                    ${CARGO_BASE_OPTS}"
}

make_target() {
  cargo fetch ${CARGO_BASE_OPTS}
  cargo cbuild ${CARGO_BUILD_OPTS}
}

makeinstall_target() {
  cargo cinstall ${CARGO_BUILD_OPTS} --destdir ${SYSROOT_PREFIX}
  cargo cinstall ${CARGO_BUILD_OPTS} --destdir ${INSTALL}
}
else
make_target() {
  cp -PR * ${SYSROOT_PREFIX}
}

makeinstall_target() {
  : #
}
fi
