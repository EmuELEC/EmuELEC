PKG_NAME="b2"
PKG_VERSION="9a00b269"
PKG_SHA256=""
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/zoltanvb/b2-libretro"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="BBC Micro emulator for libretro"
PKG_LONGDESC="Adaptation of Tom Seddon's b2 emulator for BBC Micro"
PKG_TOOLCHAIN="make"

PKG_LIBRETRO="src/libretro"

pre_make_target() {
 
  cd ${PKG_BUILD}/${PKG_LIBRETRO}
}

make_target() {
  cd ${PKG_BUILD}/${PKG_LIBRETRO}
  make GIT_VERSION=${PKG_VERSION}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/${PKG_LIBRETRO}/b2_libretro.so ${INSTALL}/usr/lib/libretro/
}