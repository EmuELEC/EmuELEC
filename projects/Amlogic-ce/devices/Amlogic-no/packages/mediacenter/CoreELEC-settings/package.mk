# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="CoreELEC-settings"
PKG_VERSION="33a40f356ecaec7d4cfd0e9f8e7791114eea65eb"
PKG_SHA256="906542ded836e912098b71548c1c842b7175f4168376820ddfcaa80634c89bd8"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/service.coreelec.settings/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 connman pygobject dbus-python bkeymaps"
PKG_LONGDESC="CoreELEC-settings: is a settings dialog for CoreELEC"

PKG_MAKE_OPTS_TARGET="DISTRONAME=${DISTRONAME} \
                      ADDON_VERSION=${ADDON_VERSION} \
                      ROOT_PASSWORD=${ROOT_PASSWORD}"

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/coreelec
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/lib/coreelec

  ADDON_INSTALL_DIR=${INSTALL}/usr/share/kodi/addons/service.coreelec.settings
  python_compile ${ADDON_INSTALL_DIR}/resources/lib/
  python_compile ${ADDON_INSTALL_DIR}/oe.py
}

post_install() {
  enable_service backup-restore.service
  enable_service factory-reset.service
}
