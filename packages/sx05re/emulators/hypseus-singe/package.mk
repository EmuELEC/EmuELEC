PKG_NAME="hypseus-singe"
PKG_VERSION="4cfd20d834ee6cf42c1c347ffd2627d87aaf8e2f"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/DirtBagXon/hypseus-singe"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="sdl2"
PKG_DEPENDS_TARGET="toolchain SDL2 libvorbis SDL2_ttf SDL2_image SDL2_mixer libmpeg2"
PKG_LONGDESC="Hypseus is a fork of Daphne. A program that lets one play the original versions of many laserdisc arcade games on one's PC."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"
PKG_CMAKE_OPTS_TARGET="-DABSTRACT_SINGE=OFF ./src"

pre_configure_target() {
mkdir -p ${INSTALL}/usr/config/emuelec/configs/hypseus
ln -fs /storage/roms/daphne/roms ${INSTALL}/usr/config/emuelec/configs/hypseus/roms
ln -fs /usr/share/daphne/sound ${INSTALL}/usr/config/emuelec/configs/hypseus/sound
ln -fs /usr/share/daphne/fonts ${INSTALL}/usr/config/emuelec/configs/hypseus/fonts
ln -fs /usr/share/daphne/pics ${INSTALL}/usr/config/emuelec/configs/hypseus/pics
ln -fs /usr/share/daphne/midi ${INSTALL}/usr/config/emuelec/configs/hypseus/midi
}

post_makeinstall_target() {
mkdir -p ${INSTALL}/usr/share/daphne
cp -rf ${PKG_BUILD}/pics ${INSTALL}/usr/share/daphne/
cp -rf ${PKG_BUILD}/sound ${INSTALL}/usr/share/daphne/
cp -rf ${PKG_BUILD}/fonts ${INSTALL}/usr/share/daphne/
cp -rf ${PKG_BUILD}/midi ${INSTALL}/usr/share/daphne/
cp -rf ${PKG_BUILD}/doc/hypinput.ini ${INSTALL}/usr/config/emuelec/configs/hypseus/hypinput.ini
cp -rf ${PKG_BUILD}/doc/hypinput_gamepad.ini ${INSTALL}/usr/config/emuelec/configs/hypseus/hypinput_gamepad.ini
ln -fs /storage/.config/emuelec/configs/hypseus/hypinput.ini ${INSTALL}/usr/share/daphne/hypinput.ini
}