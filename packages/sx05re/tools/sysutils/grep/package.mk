# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="grep"
PKG_VERSION="3.11"
PKG_SHA256="1f31014953e71c3cddcedb97692ad7620cb9d6d04fbdc19e0d8dd836f87622bb"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://ftp.gnu.org/gnu/${PKG_NAME}"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Grep"
PKG_TOOLCHAIN="configure"
PKG_NEED_UNPACK="$(get_pkg_directory busybox)"

pre_configure_target() {
PKG_CONFIGURE_OPTS_TARGET="--enable-perl-regexp=yes"
}
