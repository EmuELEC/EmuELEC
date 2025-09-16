# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="media_tree"
PKG_LICENSE="GPL"
PKG_SITE="https://git.linuxtv.org/media_tree.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Source of Linux Kernel media_tree subsystem to build with media_build."
PKG_TOOLCHAIN="manual"
PKG_PATCH_DIRS="${LINUX}"

case "${LINUX}" in
  amlogic-4.9)
    PKG_VERSION="2019-07-11-22be8233b34f"
    PKG_SHA256="14363b1aacfe59805a1fe93739caed53036879e7b871f1d8d7061527c3cb9eb8"
    PKG_URL="http://linuxtv.org/downloads/drivers/linux-media-${PKG_VERSION}.tar.bz2"
    PKG_TAR_STRIP_COMPONENTS="yes"
    ;;
  amlogic-5.4)
    PKG_VERSION="d8675998dc4a902a4d01a6d4b85e83ef76d3374b"
    PKG_SHA256="2687f2fedebbee222e56da85d90f0b8bb446f148b63604272b6782ade87da1b9"
    PKG_URL="https://github.com/CoreELEC/media_tree/archive/${PKG_VERSION}.tar.gz"
    ;;
esac

post_unpack() {
  # hack/workaround for borked upstream kernel/media_build
  # without removing atomisp there a lot additional includes that
  # slowdown build process after modpost from 3min to 6min
  # even if atomisp is disabled via kernel.conf
  rm -rf ${PKG_BUILD}/drivers/staging/media/atomisp

  if [ -f ${PKG_BUILD}/drivers/staging/media/Kconfig ]; then
    sed -i 's|^.*drivers/staging/media/atomisp.*$||' \
      ${PKG_BUILD}/drivers/staging/media/Kconfig
  fi
}
