# SPDX-License-Identifier: GPL-2.0
PKG_NAME="ruffle"
PKG_VERSION="a12f2a9"
PKG_ARCH="aarch64"
PKG_LICENSE="MIT/Apache-2.0"
PKG_SITE="https://github.com/Hexadecinull/ruffle4consoles"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="master"
PKG_DEPENDS_TARGET="toolchain SDL2 cargo:host"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="Native Flash player (Ruffle) for aarch64, SDL2 + GLES2"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  # The project sets a nightly-only rustflag globally; the stable toolchain
  # used here rejects it.
  sed -i '/^\[build\]$/,$d' ${PKG_BUILD}/.cargo/config.toml

  # Link against EmuELEC's SDL2 instead of building a static copy.
  sed -i 's/sdl2 = { version = "0.38.0", features = \["static-link", "use-pkgconfig"\] }/sdl2 = { version = "0.38.0" }/' \
    ${PKG_BUILD}/Cargo.toml

  # The patches/ directory is applied automatically by the build system:
  #   001  follow the current display size and go fullscreen instead of using
  #        a fixed 1280x720 window, keep the content root relative, and ignore
  #        external navigation requests instead of panicking. Published by the
  #        Ruffle-Handheld project (MIT): github.com/SilverPsychoo/Ruffle-Handheld
  #   002  handle SDL keyboard events - upstream targets consoles and only
  #        reads controller input, but here the pad is translated into key
  #        presses by gptokeyb like for every other EmuELEC emulator.
  #   003  letterbox the stage and scale the movie to fit. Without this,
  #        content outside the stage bounds keeps being drawn next to the
  #        black bars (visible e.g. in Alien Hominid).
  #   004  centre the stage. Movies that request a corner alignment would
  #        otherwise sit flush left with all the black on one side.
}

make_target() {
  cd ${PKG_BUILD}

  # No --locked: pre_make_target edits Cargo.toml (system SDL2), which
  # invalidates the shipped Cargo.lock.
  export RUSTC_LINKER=${CC}
  cargo build --target ${TARGET_NAME} --release

  ${STRIP} ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/ruffle4consoles
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/bin"

  cp "${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/ruffle4consoles" \
     "${INSTALL}/usr/bin/ruffle.aarch64"
  chmod +x "${INSTALL}/usr/bin/ruffle.aarch64"

  # Software mouse cursor: EmuELEC's SDL2 mali backend has no hardware cursor.
  ${CC} -shared -fPIC -O2 -o "${INSTALL}/usr/bin/ruffle_cursor.so" \
    "${PKG_DIR}/sources/ruffle_cursor.c" -ldl

  # Launcher
  cp "${PKG_DIR}/scripts/startruffle.sh" "${INSTALL}/usr/bin/startruffle.sh"
  chmod +x "${INSTALL}/usr/bin/startruffle.sh"

  # Gamepad config
  mkdir -p "${INSTALL}/usr/config/emuelec/configs/ruffle/gptk"
  cp -f "${PKG_DIR}/config/flash.gptk" \
    "${INSTALL}/usr/config/emuelec/configs/ruffle/gptk/flash.gptk"
}