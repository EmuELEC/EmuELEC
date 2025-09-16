PKG_NAME="lr-dolphin"
PKG_VERSION="89a4df725d4eb24537728f7d655cddb1add25c18"
PKG_ARCH="x86_64 aarch64"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/dolphin"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Dolphin is a GameCube / Wii emulator, allowing you to play games for these two platforms on PC with improvements."
PKG_TOOLCHAIN="cmake"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

PKG_CMAKE_OPTS_TARGET="-DENABLE_X11=OFF \
                       -DLIBRETRO=ON \
                       -DENABLE_NOGUI=OFF \
                       -DENABLE_QT=OFF \
                       -DENABLE_TESTS=OFF \
                       -DUSE_DISCORD_PRESENCE=OFF \
                       -DBUILD_SHARED_LIBS=OFF \
                       -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -v ${PKG_BUILD}/.${TARGET_NAME}/dolphin_libretro.so ${INSTALL}/usr/lib/libretro/
  mkdir -p ${INSTALL}/usr/share/retroarch-system/dolphin-emu
    cp -vr ${PKG_BUILD}/Data/Sys ${INSTALL}/usr/share/retroarch-system/dolphin-emu/
}
