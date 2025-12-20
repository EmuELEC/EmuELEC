# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="kmscon"
PKG_VERSION="0b3452719992f855b64fa21c9d7fbd6158a8d23a"
PKG_SHA256="6b7efdb4f9b6715208898ee4757364c04d1bb903182bba1667644dd68c11524d"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://github.com/dvdhrm/kmscon"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain libtsm libxkbcommon"
PKG_LONGDESC="Linux KMS/DRM based virtual Console Emulator"
PKG_TOOLCHAIN="autotools"


PKG_CONFIGURE_OPTS_TARGET=" --disable-debug --with-video=fbdev,drm2d,drm3d --disable-multi-seat --with-sessions=dummy,terminal"
