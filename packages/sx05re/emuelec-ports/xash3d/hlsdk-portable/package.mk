# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (github.com/escalade)
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hlsdk-portable"
PKG_VERSION="895b28d0379f8902051d2b733029fc6a0fa9989c"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/FWGS/hlsdk-portable"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Portable Half-Life SDK. GoldSource and Xash3D. Crossplatform."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-lto -gold"

makeinstall_target() {
  # Seems to be needed for some reason
  #if [ "${ARCH}" = "arm" ]; then
  #  CPPFLAGS+="-D__ARM_ARCH_7__"
  #fi

  # Compile xash3d
  cd ${PKG_BUILD}
  ARGS="--build-type=release \
	--64bits"
  ./waf configure ${ARGS}
  ./waf build -v
  ./waf install --destdir=${INSTALL}/usr/lib/xash3d
}
