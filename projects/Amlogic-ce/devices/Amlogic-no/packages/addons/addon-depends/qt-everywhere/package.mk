# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="qt-everywhere"
PKG_VERSION="5.15.13"
PKG_SHA256="9550ec8fc758d3d8d9090e261329700ddcd712e2dda97e5fcfeabfac22bea2ca"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://qt-project.org"
PKG_URL="http://download.qt.io/archive/qt/${PKG_VERSION%.*}/${PKG_VERSION}/single/${PKG_NAME}-opensource-src-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="pcre2 zlib openssl libjpeg-turbo"
PKG_SOURCE_DIR="${PKG_NAME}-src-${PKG_VERSION}"
PKG_LONGDESC="A cross-platform application and UI framework"

PKG_CONFIGURE_OPTS_TARGET="-prefix /usr
                           -sysroot "${SYSROOT_PREFIX}"
                           -hostprefix "${TOOLCHAIN}"
                           -device linux-libreelec-g++
                           -opensource -confirm-license
                           -release
                           -static
                           -make libs
                           -force-pkg-config
                           -openssl-linked
                           -no-accessibility
                           -system-sqlite
                           -no-sql-mysql
                           -system-zlib
                           -no-mtdev
                           -system-libjpeg
                           -qt-libpng
                           -no-harfbuzz
                           -no-libproxy
                           -system-pcre
                           -no-glib
                           -silent
                           -no-cups
                           -no-iconv
                           -no-evdev
                           -no-tslib
                           -no-icu
                           -no-strip
                           -no-fontconfig
                           -dbus
                           -no-opengl
                           -no-libudev
                           -no-libinput
                           -no-eglfs
                           -skip qt3d
                           -skip qtactiveqt
                           -skip qtandroidextras
                           -skip qtcanvas3d
                           -skip qtconnectivity
                           -skip qtdeclarative
                           -skip qtdoc
                           -skip qtgraphicaleffects
                           -skip qtimageformats
                           -skip qtlocation
                           -skip qtmacextras
                           -skip qtmultimedia
                           -skip qtquickcontrols
                           -skip qtquickcontrols2
                           -skip qtscript
                           -skip qtsensors
                           -skip qtserialbus
                           -skip qtsvg
                           -skip qttranslations
                           -skip qtwayland
                           -skip qtwebchannel
                           -skip qtwebengine
                           -skip qtwebsockets
                           -skip qtwebview
                           -skip qtwinextras
                           -skip qtx11extras
                           -skip qtxmlpatterns"

post_unpack() {
  # HOST_CFLAGS_DBUS is set to SYSROOT_PREFIX/usr/include
  # from libsystemd.pc which is required by dbus-1.pc
  # this fails to build some host tools
  # with -no-dbus this workaround is not needed
  sed -i "s|QT_HOST_CFLAGS_DBUS|QT_HOST_CFLAGS_DBUS_IGNORED|" \
    ${PKG_BUILD}/qtbase/configure.json
}

configure_target() {
  QMAKE_CONF_DIR="qtbase/mkspecs/devices/linux-libreelec-g++"

  cd ..
  mkdir -p ${QMAKE_CONF_DIR}

  cat >"${QMAKE_CONF_DIR}/qmake.conf" <<EOF
MAKEFILE_GENERATOR      = UNIX
CONFIG                 += incremental
QMAKE_INCREMENTAL_STYLE = sublib
include(../../common/linux.conf)
include(../../common/gcc-base-unix.conf)
include(../../common/g++-unix.conf)
load(device_config)
QMAKE_CC         = ${CC}
QMAKE_CXX        = ${CXX}
QMAKE_LINK       = ${CXX}
QMAKE_LINK_SHLIB = ${CXX}
QMAKE_AR         = ${AR} cqs
QMAKE_OBJCOPY    = ${OBJCOPY}
QMAKE_NM         = ${NM} -P
QMAKE_STRIP      = ${STRIP}
QMAKE_CFLAGS     = ${CFLAGS}
QMAKE_CXXFLAGS   = ${CXXFLAGS}
QMAKE_LFLAGS     = ${LDFLAGS}
load(qt_config)
EOF

  cat >"${QMAKE_CONF_DIR}/qplatformdefs.h" <<EOF
#include "../../linux-g++/qplatformdefs.h"
EOF

  unset CC CXX LD RANLIB AR AS CPPFLAGS CFLAGS LDFLAGS CXXFLAGS
  ./configure ${PKG_CONFIGURE_OPTS_TARGET}
}

post_makeinstall_target() {
  # Qt installs directly to $SYSROOT_PREFIX so don't rely on scripts/build fixing this up
  # PKG_ORIG_SYSROOT_PREFIX will be undefined when performing a legacy build
  sed -e "s:\(['= ]\)/usr:\\1${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/usr:g" -i "${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/usr/lib"/libQt*.la
}
