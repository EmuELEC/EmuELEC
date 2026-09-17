# SPDX-License-Identifier: GPL-2.0-or-later
PKG_NAME="touchhle"
PKG_VERSION="f8f21296b1bf2e5112db5e2ee36a683b7610d1ff"
PKG_SITE="https://github.com/worstcase-scenario/EE_touchHLE"
PKG_GIT_CLONE_BRANCH="emuelec-integration"
PKG_URL="${PKG_SITE}.git"
PKG_LICENSE="MPLv2"
PKG_ARCH="aarch64"
PKG_TOOLCHAIN="manual"
PKG_DEPENDS_TARGET="toolchain rust cargo SDL2 openal-soft"
make_target() {
  unset CMAKE
  export PKG_CONFIG_ALLOW_CROSS=1
  # Workaround for an internal LLVM 22 assertion (VPlan vectorizer,
  # Casting.h:572 "cast<Ty>() argument of incompatible type", VPSingleDefRecipe)
  # that aborts rustc with SIGABRT while optimizing several crates at
  # opt-level=3 (seen on touchHLE_dynarmic_wrapper, ttf_parser, ...). The fault
  # is in LLVM's loop vectorizer, not our code, so disable that pass globally.
  # This is build-time only and doesn't change emulation behaviour.
  export RUSTFLAGS="${RUSTFLAGS} -C llvm-args=-vectorize-loops=false -C llvm-args=-vectorize-slp=false"
  cargo build --release --no-default-features --target ${TARGET_NAME}
}
makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -f ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/touchHLE \
    ${INSTALL}/usr/bin/touchhle-sa
  # External launcher from package scripts dir
  cp -f ${PKG_DIR}/scripts/start_touchhle.sh ${INSTALL}/usr/bin/
  # Runtime data: synced to /storage/.config/touchhle on first run by the launcher
  mkdir -p ${INSTALL}/usr/config/touchhle
  cp -r ${PKG_BUILD}/touchHLE_dylibs ${INSTALL}/usr/config/touchhle/
  cp -r ${PKG_BUILD}/touchHLE_fonts ${INSTALL}/usr/config/touchhle/
  cp -f ${PKG_BUILD}/touchHLE_default_options.txt ${INSTALL}/usr/config/touchhle/
  cp -f ${PKG_BUILD}/touchHLE_options.txt ${INSTALL}/usr/config/touchhle/
  chmod +x ${INSTALL}/usr/bin/*
}