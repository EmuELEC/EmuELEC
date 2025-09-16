# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tigervnc"
PKG_VERSION="1.10.1"
PKG_SHA256="19fcc80d7d35dd58115262e53cac87d8903180261d94c2a6b0c19224f50b58c4"
PKG_REV="1"
PKG_ARCH="x86_64"
PKG_LICENSE="GPLv2"
PKG_SITE="http://www.tigervnc.org"
PKG_URL="https://github.com/TigerVNC/tigervnc/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain cmake:host libX11 libXdamage libXext libXtst zlib libjpeg-turbo"
PKG_SECTION="service"
PKG_SHORTDESC="${PKG_ADDON_NAME} server"
PKG_LONGDESC="${PKG_ADDON_NAME} (${PKG_VERSION}) is a high-performance, platform-neutral implementation of Virtual Network Computing, a client/server application that allows users to launch and interact with graphical applications on remote machines"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="TigerVNC"
PKG_ADDON_TYPE="xbmc.service"

PKG_CMAKE_OPTS_TARGET="-DBUILD_VIEWER=off -Wno-dev"

makeinstall_target() {
  : # nothing to do
}

# find ${1}.so.[0-9]* in ${2} and copy it to dest
_pkg_copy_lib() {
  find "${2}/usr/lib" -regextype sed -regex ".*/${1}\.so\.[0-9]*" \
    -exec cp {} "${ADDON_BUILD}/${PKG_ADDON_ID}/lib" \;
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/{bin,lib}

  cp ${PKG_BUILD}/.${TARGET_NAME}/unix/vncconfig/vncconfig     \
     ${PKG_BUILD}/.${TARGET_NAME}/unix/vncpasswd/vncpasswd     \
     ${PKG_BUILD}/.${TARGET_NAME}/unix/x0vncserver/x0vncserver \
     ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/

  # copy required libraries for tigervnc
  _pkg_copy_lib libXtst $(get_install_dir libXtst)
}
