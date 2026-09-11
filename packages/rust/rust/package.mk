# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rust"
PKG_VERSION="1.97.1"
PKG_SHA256="622c2b429c53cbfdc0dd3a51d03554e91cd63ebec1912c1f5709640cdfef1a9d"
PKG_LICENSE="MIT OR Apache-2.0"
PKG_SITE="https://www.rust-lang.org"
PKG_URL="https://static.rust-lang.org/dist/rustc-${PKG_VERSION}-src.tar.gz"
PKG_DEPENDS_HOST="toolchain llvm:host"
PKG_DEPENDS_UNPACK="rustc-snapshot rust-std-snapshot cargo-snapshot"
PKG_LONGDESC="A systems programming language that prevents segfaults, and guarantees thread safety."
PKG_TOOLCHAIN="manual"

pre_configure_host() {
  "$(get_build_dir rustc-snapshot)/install.sh" --prefix="${PKG_BUILD}/rust-snapshot" --disable-ldconfig
  "$(get_build_dir rust-std-snapshot)/install.sh" --prefix="${PKG_BUILD}/rust-snapshot" --disable-ldconfig
  "$(get_build_dir cargo-snapshot)/install.sh" --prefix="${PKG_BUILD}/rust-snapshot" --disable-ldconfig
}

configure_host() {

  cat >${PKG_BUILD}/config.toml  <<END
change-id = 154587

[llvm]
download-ci-llvm = false

[target.${TARGET_NAME}]
llvm-config = "${TOOLCHAIN}/bin/llvm-config"
cxx = "${TARGET_PREFIX}g++"
cc = "${TARGET_PREFIX}gcc"

[target.${RUST_HOST}]
llvm-config = "${TOOLCHAIN}/bin/llvm-config"
cxx = "${CXX}"
cc = "${CC}"

[rust]
rpath = true
channel = "stable"
codegen-tests = false
optimize = true
download-rustc = false

[build]
submodules = false
docs = false
profiler = true
vendor = true

rustc = "${PKG_BUILD}/rust-snapshot/bin/rustc"
cargo = "${PKG_BUILD}/rust-snapshot/bin/cargo"

target = [
  "${TARGET_NAME}",
  "${RUST_HOST}"
]

host = [
  "${RUST_HOST}"
]

build = "${RUST_HOST}"

[install]
prefix = "${TOOLCHAIN}"
bindir = "${TOOLCHAIN}/bin"
libdir = "${TOOLCHAIN}/lib"
datadir = "${TOOLCHAIN}/share"
mandir = "${TOOLCHAIN}/share/man"

END

  CARGO_HOME="${PKG_BUILD}/cargo_home"
  mkdir -p "${CARGO_HOME}"

  cat >${CARGO_HOME}/config.toml <<END
[target.${TARGET_NAME}]
linker = "${TARGET_PREFIX}gcc"

[target.${RUST_HOST}]
linker = "${CC}"
rustflags = ["-C", "link-arg=-Wl,-rpath,${TOOLCHAIN}/lib"]

[build]
target-dir = "${PKG_BUILD}/target"

[term]
progress.when = 'always'
progress.width = 80

END
}

make_host() {
  cd ${PKG_BUILD}

  unset CFLAGS
  unset CXXFLAGS
  unset CPPFLAGS
  unset LDFLAGS

  export RUST_TARGET_PATH="${PKG_BUILD}/targets/"
  export HOST_CMAKE="${TOOLCHAIN}/bin/cmake"
  export HOST_CMAKE_TOOLCHAIN_FILE="${CMAKE_CONF}"

  python3 src/bootstrap/bootstrap.py -j ${CONCURRENCY_MAKE_LEVEL} build --stage 2 --verbose
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -a build/${RUST_HOST}/stage2/bin/* ${TOOLCHAIN}/bin

  mkdir -p ${TOOLCHAIN}/lib/rustlib
    cp -a build/${RUST_HOST}/stage2/lib/* ${TOOLCHAIN}/lib
}
