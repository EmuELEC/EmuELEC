# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="alsa-topology-conf"
PKG_VERSION="1.2.5.1"
PKG_SHA256="f7c5bae1545abcd73824bc97f4e72c340e11abea188ba0f1c06f5e0ad776b179"
PKG_LICENSE="BSD-3c"
PKG_SITE="https://www.alsa-project.org/"
PKG_URL="https://www.alsa-project.org/files/pub/lib/alsa-topology-conf-${PKG_VERSION}.tar.bz2"
PKG_LONGDESC="ALSA topology configuration files"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/alsa/
  cp -PR ${PKG_BUILD}/topology ${INSTALL}/usr/share/alsa/
}
