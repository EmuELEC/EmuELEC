# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="wget"
PKG_VERSION="1.20.3"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/mirror/wget"
PKG_URL="https://ftp.gnu.org/gnu/wget/wget-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl"
PKG_LONGDESC="GNU Wget is a free software package for retrieving files using HTTP, HTTPS, FTP and FTPS"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
PKG_CONFIGURE_OPTS_TARGET+=" --with-ssl=openssl"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp ${PKG_BUILD}/.${TARGET_NAME}/src/wget ${INSTALL}/usr/bin/wget
}
