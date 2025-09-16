# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rsync"
PKG_VERSION="3.2.7"
PKG_SHA256="4e7d9d3f6ed10878c58c5fb724a67dacf4b6aac7340b13e488fb2dc41346f2bb"
PKG_LICENSE="GPLv3"
PKG_SITE="https://rsync.samba.org"
PKG_URL="https://download.samba.org/pub/rsync/src/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="autotools:host zlib:host"
PKG_DEPENDS_TARGET="toolchain zlib openssl"
PKG_LONGDESC="A very fast method for bringing remote files into sync."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_HOST="--disable-md2man \
                         --disable-ipv6 \
                         --disable-openssl \
                         --disable-xxhash \
                         --disable-zstd \
                         --disable-lz4 \
                         --disable-iconv \
                         --with-included-popt \
                         --without-included-zlib"

PKG_CONFIGURE_OPTS_TARGET="--disable-acl-support \
                           --disable-md5-asm \
                           --enable-openssl \
                           --disable-lz4 \
                           --disable-md2man \
                           --disable-roll-simd \
                           --disable-xattr-support \
                           --disable-xxhash \
                           --disable-zstd \
                           --with-included-popt \
                           --without-included-zlib"

pre_configure_host() {
  HOST_CONFIGURE_OPTS=$(echo ${HOST_CONFIGURE_OPTS} | sed -e "s|--disable-static||" -e "s|--enable-shared||")
}

pre_configure_target() {
  TARGET_CONFIGURE_OPTS=$(echo ${TARGET_CONFIGURE_OPTS} | sed -e "s|--disable-static||" -e "s|--enable-shared||")
}

pre_make_host() {
  # do not detect LE git version
  echo "#define RSYNC_GITVER \"${PKG_VERSION}\"" >git-version.h
}

pre_make_target() {
  pre_make_host
}
