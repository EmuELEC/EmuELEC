PKG_NAME="melondsds"
PKG_VERSION="86986bfd82fb130d4d4739d93159acd986921808"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/JesseTG/melonds-ds"
PKG_GIT_CLONE_BRANCH="dev"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} ${EGL}"

PKG_SHORTDESC="An enhanced remake of the melonDS core for libretro that prioritizes standalone parity, reliability, and usability."
PKG_TOOLCHAIN="cmake-make"

PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release \
                        -DCMAKE_RULE_MESSAGES=OFF \
                        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
                        -DENABLE_OPENGL=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/src/libretro/melondsds_libretro.so ${INSTALL}/usr/lib/libretro/
}
