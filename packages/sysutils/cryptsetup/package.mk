# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020 Jeff Doozan <github@doozan.com>

PKG_NAME="cryptsetup"
PKG_MAJOR="2.3"
PKG_VERSION="$PKG_MAJOR.4"
PKG_LICENSE="GPL"
PKG_URL="https://www.kernel.org/pub/linux/utils/cryptsetup/v$PKG_MAJOR/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_SHA256="9d16eebb96b53b514778e813019b8dd15fea9fec5aafde9fae5febf59df83773"
PKG_LONGDESC="cryptsetup utility for managing LUKS containers"
PKG_DEPENDS_HOST="toolchain ccache:host"
PKG_DEPENDS_TARGET="toolchain popt libdevmapper util-linux json-c openssl"

PKG_CONFIGURE_OPTS_TARGET="
        --disable-cryptsetup-reencrypt \
        --disable-integritysetup \
        --disable-selinux \
        --disable-rpath \
        --disable-veritysetup \
        --disable-udev \
        --enable-blkid"
