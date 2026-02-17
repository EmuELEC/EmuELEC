PKG_NAME="libretro-vircon32"
PKG_VERSION="d8a92430e887286b4e5351916ef0bd35d8cb40e8"
PKG_SHA512="8746ba64b721954adab761dad17071d6c92a48bb35944d6cc1360c25046774ec9cc2f6c144036a3376deb9723e9d106ffc2bf520e4a4595130e8ef864bb5bd2d"
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