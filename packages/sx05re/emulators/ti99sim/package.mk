PKG_NAME="ti99sim"
PKG_VERSION="0.16.0"
PKG_SHA256="14bd72f372fe1a253c3a25bca579d29b5c3e47aff2f22622188dc4023576b159"
PKG_LICENSE="GPL-3.0"
PKG_SITE="https://www.mrousseau.org/programs/ti99sim/"
PKG_URL="https://www.mrousseau.org/programs/ti99sim/archives/ti99sim-${PKG_VERSION}.src.tar.xz"

PKG_DEPENDS_TARGET="toolchain SDL2 openssl"
PKG_LONGDESC="TI-99/4A Emulator"
PKG_TOOLCHAIN="make"

pre_configure_target() {
  sed -i 's/-march=aarch64/-march=armv8-a/g; s/-march=$(ARCH)/-march=armv8-a/g' "$PKG_BUILD/rules.mak" 2>/dev/null || true
  f="$PKG_BUILD/src/core/device-support.cpp"
  grep -q '^#include <cstring>' "$f" 2>/dev/null || sed -i '/^#include "cf7+\.hpp"$/a #include <cstring>' "$f"
}

pre_make_target() { make -C "$PKG_BUILD/src/core" CC="$CC" CXX="$CXX" AR="$AR"; }
make_target()     { make -C "$PKG_BUILD/src/sdl"  CC="$CC" CXX="$CXX" SDL2=1; }

makeinstall_target() {
	
	mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/bin/ti99sim-sdl ${INSTALL}/usr/bin/ti99sim-sdl  
    chmod +x ${INSTALL}/usr/bin/ti99sim-sdl
   
    cp ${PKG_DIR}/scripts/ti99sdlstart.sh ${INSTALL}/usr/bin/ti99sdlstart.sh
    chmod +x ${INSTALL}/usr/bin/ti99sdlstart.sh
	
					}
