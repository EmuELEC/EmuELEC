# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (github.com/escalade)
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="xash3d"
PKG_VERSION="b59ba5a1275e052626cea9577da32c634ae5527c"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/FWGS/xash3d-fwgs"
PKG_URL="https://github.com/FWGS/xash3d-fwgs.git"
PKG_DEPENDS_TARGET="toolchain hlsdk-portable SDL2"
PKG_LONGDESC="Xash3D FWGS engine. Rebooted fork since big Xash3D 0.99"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-lto"

makeinstall_target() {

cd ${PKG_BUILD}
  ARGS="--build-type=release \
	--prefix=/usr \
	--sdl2=${PKG_ORIG_SYSROOT_PREFIX}/usr \
	--64bits \
	--disable-gl \
	--enable-gles2"
  ./waf configure ${ARGS}
  ./waf build -v
  ./waf install --destdir=${INSTALL}/usr/bin/xash3d

  mkdir -p ${INSTALL}/usr/lib/xash3d/valve
  mkdir -p ${INSTALL}/usr/emuelec/configs/hl
  wget -q -O ${INSTALL}/usr/lib/xash3d/valve/extras.pak https://github.com/FWGS/xash-extras/releases/download/v0.19.2/extras.pak
  cp ${PKG_DIR}/files/xash3d.sh ${INSTALL}/usr/bin/
  cp ${PKG_DIR}/files/config.cfg ${INSTALL}/usr/emuelec/configs/hl
}
