# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bluez"
PKG_VERSION="5.87"
PKG_SHA256="26bdcf2cebd7310c6f598850606b037ef0c515fe6608ebc54d22c50c4c32b35f"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="http://www.bluez.org/"
PKG_URL="https://www.kernel.org/pub/linux/bluetooth/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain dbus glib readline systemd"
PKG_LONGDESC="Bluetooth Tools and System Daemons for Linux."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+lto"

if build_with_debug; then
  BLUEZ_CONFIG="--enable-debug"
else
  BLUEZ_CONFIG="--disable-debug"
fi

BLUEZ_CONFIG+=" --enable-monitor --enable-test"

PKG_CONFIGURE_OPTS_TARGET="--disable-dependency-tracking \
                           --disable-silent-rules \
                           --enable-library \
                           --enable-udev \
                           --disable-cups \
                           --disable-obex \
                           --enable-client \
                           --enable-systemd \
                           --enable-tools \
                           --enable-deprecated \
                           --enable-datafiles \
                           --disable-manpages \
                           --disable-experimental \
                           --enable-sixaxis \
                           --with-gnu-ld \
                           ${BLUEZ_CONFIG} \
                           storagedir=/storage/.cache/bluetooth"

pre_configure_target() {
  # bluez fails to build in subdirs
  cd ${PKG_BUILD}
    rm -rf .${TARGET_NAME}

  export LIBS="-lncurses"
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/lib/systemd
  safe_remove ${INSTALL}/usr/bin/bluemoon
  safe_remove ${INSTALL}/usr/bin/ciptool

  mkdir -p ${INSTALL}/etc/bluetooth
    cp src/main.conf ${INSTALL}/etc/bluetooth
    sed -i ${INSTALL}/etc/bluetooth/main.conf \
        -e "s|^#\[Policy\]|\[Policy\]|g" \
        -e "s|^#AutoEnable.*|AutoEnable=true|g" \
        -e "s|^#JustWorksRepairing.*|JustWorksRepairing=always|g"
    echo "[General]" >${INSTALL}/etc/bluetooth/input.conf
    echo "ClassicBondedOnly=false" >>${INSTALL}/etc/bluetooth/input.conf

  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_BUILD}/tools/btmgmt ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/services
    cp -P ${PKG_DIR}/default.d/*.conf ${INSTALL}/usr/share/services

  # bluez looks in /etc/firmware/
    ln -sf /usr/lib/firmware ${INSTALL}/etc/firmware

  # kodi requires bluez pkgconfig
    cp -P ${PKG_BUILD}/lib/bluez.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
}

post_install() {
  enable_service bluetooth-defaults.service
  enable_service bluetooth.service
  enable_service obex.service
}
