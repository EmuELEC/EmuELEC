PKG_NAME="libretro-vircon32"
PKG_VERSION="669f9c1795973e78909b6ea1dc5bc41a271980f1"
PKG_SHA512="12aedd6167d2256bf1f126052cc7c299704c7a3d843d24a667099c89e7c9ca299371f3545aeb57a1d55d798196f9089f6f8002f800fad9854b915ff7c0c96c83"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/vircon32/vircon32-libretro"
PKG_URL="${PKG_SITE}.git"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="opengl-meson"
PKG_LONGDESC="Vircon32 32-bit Virtual Console"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" \
  -DENABLE_OPENGLES2=1 \
  -DPLATFORM=EMUELEC \
  -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
  -DCMAKE_BUILD_TYPE=Release"
}

PKG_LIBNAME="vircon32_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="VIRCON32_LIB"

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
