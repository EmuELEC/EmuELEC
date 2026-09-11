PKG_NAME="amiarcadia"
PKG_VERSION="34af1c9eb71c7ef58e7719e67d77881a99874c36"
PKG_REV="1"
PKG_ARCH="aarch64"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/warmenhoven/amiarcadia"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro core for Signetics 2650 CPU-based systems (Arcadia 2001, Interton VC 4000, Elektor TV Games, Zaccaria, Malzak)."
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

make_target() {
  make platform=unix \
    CC="$CC" \
    CXX="$CXX" \
    AR="$AR"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp amiarcadia_libretro.so $INSTALL/usr/lib/libretro/
}