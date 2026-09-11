# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="xroar"
PKG_VERSION="1.11"
PKG_SHA256="70270805ebd52c0b62237cc2f28b32b5c7df9764d10a7c7190de584cfc6e95af"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://www.6809.org.uk/xroar/"
PKG_URL="https://www.6809.org.uk/xroar/dl/xroar-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libpng zlib"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="XRoar - Dragon/CoCo Emulator"
PKG_TOOLCHAIN="autotools"

configure_target() {
  cd ${PKG_BUILD}
  ./configure \
    --host=${TARGET_NAME} \
    --prefix=/usr \
    --enable-dragon \
    --enable-coco3 \
    --enable-mc10 \
    --without-gtk2 \
    --without-gtk3 \
    --without-gtkgl \
    --without-cocoa \
    --without-oss \
    --without-pulse \
    --without-coreaudio \
    --without-x
}

make_target() {
  cd ${PKG_BUILD}
  make
}

makeinstall_target() {
  cd ${PKG_BUILD}
  make DESTDIR=${INSTALL} install

  cp ${PKG_DIR}/scripts/xroarstart.sh ${INSTALL}/usr/bin/xroarstart.sh
  chmod +x ${INSTALL}/usr/bin/xroarstart.sh

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/xroar

  if [ -f "${PKG_DIR}/config/xroar.gptk" ]; then
    mkdir -p ${INSTALL}/usr/config/emuelec/configs/xroar/gptk
    cp -f "${PKG_DIR}/config/xroar.gptk" \
      "${INSTALL}/usr/config/emuelec/configs/xroar/gptk/xroar.gptk"
  fi
}