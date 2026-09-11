PKG_NAME="virtualxt"
PKG_VERSION="64b40e6aaa1947e9878a0a844f7abb15561b32a8"
PKG_URL="https://codeberg.org/virtualxt/virtualxt.git"
PKG_GIT_CLONE_BRANCH="develop"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

make_target() {
  touch src/frontend/generated/*.h
  make release
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp virtualxt_libretro.so ${INSTALL}/usr/lib/libretro/
  mkdir -p ${INSTALL}/usr/share/libretro/info
  cp virtualxt_libretro.info ${INSTALL}/usr/share/libretro/info/
}