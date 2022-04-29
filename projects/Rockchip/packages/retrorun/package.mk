# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="retrorun"
PKG_VERSION="7e3ab628d465a024a06ee113de50929b873157d0"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/AmberELEC/retrorun-go2"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain libgo2 libdrm libpng linux"
PKG_TOOLCHAIN="make"

pre_make_target() {
  mkdir -p src/go2
  cp -f $SYSROOT_PREFIX/usr/include/go2/*.h src/go2
}

pre_configure_target() {
	CFLAGS+=" -I$(get_build_dir libdrm)/include/drm"
	CFLAGS+=" -I$(get_build_dir linux)/include/uapi"
	CFLAGS+=" -I$(get_build_dir linux)/tools/include"
	
	PKG_MAKE_OPTS_TARGET=" config=release ARCH="

	sed -i "s|/storage/.config/distribution/|/storage/.config/retrorun/|g" ${PKG_BUILD}/src/main.cpp
}

makeinstall_target() {
	mkdir -p $INSTALL/usr/bin
  if [ "${ARCH}" != "aarch64" ]; then
    cp retrorun $INSTALL/usr/bin/retrorun32
  else
    cp retrorun $INSTALL/usr/bin
		#cp retrorun $INSTALL/usr/bin/retrorun32
		#cp -vP $PKG_BUILD/../../install_pkg/retrorun-*/usr/bin/retrorun32 $INSTALL/usr/bin
		#patchelf --set-interpreter /emuelec/lib32/ld-linux-armhf.so.3 $INSTALL/usr/bin/retrorun32

    cp $PKG_DIR/retrorun.sh $INSTALL/usr/bin
    
    mkdir -p $INSTALL/usr/config/retrorun/configs
    cp -vP $PKG_DIR/retrorun.cfg $INSTALL/usr/config/retrorun/configs
  fi
	
}

