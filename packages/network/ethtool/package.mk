# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ethtool"
PKG_LICENSE="GPL"
PKG_SITE="https://www.kernel.org/pub/software/network/ethtool/"
PKG_DEPENDS_TARGET="toolchain libmnl"
PKG_LONGDESC="Ethtool is used for querying settings of an ethernet device and changing them."

case "$LINUX" in
  rockchip-4.4|odroid-go-a-4.4|gameforce-4.4)
    PKG_VERSION="6.0"
    PKG_SHA256="d5446c93de570ce68f3b1ea69dbfa12fcfd67fc19897f655d3f18231e2b818d6"
    PKG_URL="https://www.kernel.org/pub/software/network/ethtool/${PKG_NAME}-${PKG_VERSION}.tar.xz"
    ;;
  *)
    PKG_VERSION="6.1"
    PKG_SHA256="c41fc881ffa5a40432d2dd829eb44c64a49dee482e716baacf9262c64daa8f90"
    PKG_URL="https://www.kernel.org/pub/software/network/ethtool/${PKG_NAME}-${PKG_VERSION}.tar.xz"
    ;;
esac
