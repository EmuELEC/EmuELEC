# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="media_tree_cc"
PKG_LICENSE="GPL"
PKG_SITE="https://bitbucket.org/CrazyCat/media_build/downloads/"
PKG_DEPENDS_TARGET="toolchain"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="Source of Linux Kernel media_tree subsystem to build with media_build."
PKG_TOOLCHAIN="manual"

case "$LINUX" in
  amlogic-4.9)
    PKG_VERSION="b78d5d591d2f1cd21a2a9f5ec157abbbf688bcb6"
    PKG_SHA256="cae8286b7f3ef59964c7cc20baf4d86f3103177f0a0559864e20cf77d718b1bc"
    PKG_URL="https://github.com/CoreELEC/media_tree_cc/archive/${PKG_VERSION}.tar.gz"
    ;;
  amlogic-5.4)
    PKG_VERSION="d12e1a94ddeab40f2b22555f2e1267be048acfa1"
    PKG_SHA256="d9c96939d716790cc5bdaa662fb58b12fede7ac9f8dc953c25bb6e235fad8297"
    PKG_URL="https://github.com/CoreELEC/media_tree_cc/archive/${PKG_VERSION}.tar.gz"
    ;;
esac

post_unpack() {
  # hack/workaround for borked upstream kernel/media_build
  # without removing atomisp there a lot additional includes that
  # slowdown build process after modpost from 3min to 6min
  # even if atomisp is disabled via kernel.conf
  rm -rf $PKG_BUILD/drivers/staging/media/atomisp
  sed -i 's|^.*drivers/staging/media/atomisp.*$||' \
    $PKG_BUILD/drivers/staging/media/Kconfig
}
