# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-nold"
PKG_ARCH="aarch64"
PKG_VERSION="1"
PKG_URL=""
PKG_DEPENDS_TARGET="busybox pulseaudio"
PKG_LONGDESC="Remove LD_LIBRARY_PATH since we don't need them"
PKG_TOOLCHAIN="manual"

post_install() {
  DIR_PROFILE=${BUILD}/image/system/etc/profile.d
  safe_remove ${DIR_PROFILE}/99-pulseaudio.conf
  sed -i "/^export LD_LIBRARY_PATH/d" ${DIR_PROFILE}/98-busybox.conf
}