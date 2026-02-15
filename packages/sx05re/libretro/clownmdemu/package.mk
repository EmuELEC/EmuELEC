PKG_NAME="clownmdemu"
PKG_VERSION="7591c16337b217006c524727df76670a85efad0f"
PKG_SHA256=""
PKG_LICENSE="AGPLv3"
PKG_SITE="https://github.com/Clownacy/clownmdemu-libretro"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ClownMDEmu - Sega Mega Drive/Genesis emulator libretro core"
PKG_TOOLCHAIN="make"

GET_HANDLER_SUPPORT="git"

PKG_LIBNAME="clownmdemu_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"

make_target() {
  cd ${PKG_BUILD}
  make GIT_VERSION=1.5
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/${PKG_LIBNAME} ${INSTALL}/usr/lib/libretro/
}