# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-essential"
PKG_VERSION=""
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://emuelec.org"
PKG_DEPENDS_TARGET="lib32-toolchain lib32-binutils lib32-gcc lib32-ldconfig lib32-nold"
# lib32-binutils adds multilib support (/etc/ld.so.conf, and a link under /usr/lib to point to the ld-linux-armhf.so.3 under /usr/lib32)
# lib32-gcc adds stdc++ library, and lib32 config (/etc/ld.so.conf.d/lib32-gcc.conf, so /usr/lib32 will be searched by ld)
# lib32-ldconfig adds ldconfig binary, and ldconfig systemd units
# lib32-nold removes the LD_LIBRARY_PATH set by busybox and pulseaudio
PKG_SECTION="virtual"
PKG_LONGDESC="Root package used to build and create complete image"
