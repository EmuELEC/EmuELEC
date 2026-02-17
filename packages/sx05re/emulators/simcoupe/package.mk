PKG_NAME="simcoupe"
PKG_VERSION="1.2"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/simonowen/simcoupe"
PKG_URL="$PKG_SITE/archive/refs/heads/master.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 zlib libpng"
PKG_PRIORITY="optional"
PKG_SECTION="emulators"
PKG_SHORTDESC="SimCoupe - SAM Coupe emulator"
PKG_LONGDESC="SimCoupe is a SAM Coupe emulator for various platforms"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  cp $PKG_BUILD/.$TARGET_NAME/simcoupe $INSTALL/usr/bin/
  
  cp ${PKG_DIR}/scripts/simcoupestart.sh ${INSTALL}/usr/bin/simcoupestart.sh
  chmod +x ${INSTALL}/usr/bin/simcoupestart.sh
  
  mkdir -p $INSTALL/usr/lib
  cp $PKG_BUILD/.$TARGET_NAME/_deps/saasound-build/libSAASound.so* $INSTALL/usr/lib/
  
  mkdir -p $INSTALL/usr/share/simcoupe
  cp $PKG_BUILD/Resource/*.rom $INSTALL/usr/share/simcoupe/ 2>/dev/null || true
  cp $PKG_BUILD/Resource/*.zx82 $INSTALL/usr/share/simcoupe/ 2>/dev/null || true
  cp $PKG_BUILD/Resource/*.bin $INSTALL/usr/share/simcoupe/ 2>/dev/null || true
  
}