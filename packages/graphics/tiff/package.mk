# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tiff"
PKG_VERSION="4.5.0"
PKG_SHA256="c7a1d9296649233979fa3eacffef3fa024d73d05d589cb622727b5b08c423464"
PKG_LICENSE="OSS"
PKG_SITE="http://www.remotesensing.org/libtiff/"
PKG_URL="http://download.osgeo.org/libtiff/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libjpeg-turbo zlib"
PKG_LONGDESC="libtiff is a library for reading and writing TIFF files."
PKG_BUILD_FLAGS="+pic -gold"

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=OFF \
                       -Dtiff-tools=OFF \
                       -Dtiff-tests=OFF \
                       -Dtiff-contrib=OFF \
                       -Dtiff-docs=OFF \
                       -Dmdi=OFF \
                       -Djbig=OFF \
                       -Dlzma=OFF \
                       -Dzstd=OFF \
                       -Dwebp=ON \
                       -Dcxx=ON \
                       -Djpeg=ON"
