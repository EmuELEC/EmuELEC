# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="steam-controller"
PKG_VERSION="60499dc"
PKG_SHA256="04a846c6f659fb5efca7747fe78e15c1348b5e0579437bb425f538318289bb80"
PKG_REV="102"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ynsta/steamcontroller"
PKG_URL="https://github.com/ynsta/steamcontroller/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host python-libusb1 enum34 linux:host"
PKG_SECTION="driver"
PKG_SHORTDESC="A standalone userland driver for the steam controller to be used where steam client can't be installed."
PKG_LONGDESC="A standalone userland driver for the steam controller to be used where steam client can't be installed."
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDSHARED="${CC} -shared"
}

make_target() {
  python setup.py build
}

makeinstall_target() {

find ${PKG_BUILD}/build/scripts-2.7 -type f -exec sed -i "s|\#\!/mnt.*|\#\!/usr/bin/python|g" {} \;

  mkdir -p ${INSTALL}/usr/bin/
    cp -a ${PKG_BUILD}/build/scripts-2.7/* ${INSTALL}/usr/bin/


  mkdir -p ${INSTALL}/usr/lib
    cp -a ${PKG_BUILD}/build/lib.linux-*-2.7/* ${INSTALL}/usr/lib/
    cp -a $(get_build_dir python-libusb1)/build/lib/* ${INSTALL}/usr/lib/
    cp -a $(get_build_dir enum34)/build/lib/* ${INSTALL}/usr/lib/

  mkdir -p ${INSTALL}/usr/config/emuelec/scinclude/linux
    if [ -f "$(get_build_dir linux)/usr/include/linux/input-event-codes.h" ]; then
      cp $(get_build_dir linux)/usr/include/linux/input-event-codes.h ${INSTALL}/usr/config/emuelec/scinclude/linux/
    fi
    cp $(get_build_dir linux)/usr/include/linux/input.h ${INSTALL}/usr/config/emuelec/scinclude/linux/input.h

  ${TOOLCHAIN}/bin/python -Wi -t -B ${TOOLCHAIN}/lib/${PKG_PYTHON_VERSION}/compileall.py ${INSTALL}/usr/lib/ -f 1>/dev/null
  find ${INSTALL}/usr/lib/ -name '*.py' -exec rm {} \;
}

post_install() {  
    enable_service driver.steam-controller.service
  }
