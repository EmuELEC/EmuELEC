# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vdr-plugin-xmltv2vdr"
PKG_VERSION="ec7bd920d94e55f2d21bfa076b7e900b7b2b7537"
PKG_SHA256="eacc91062095563d8adc93873b373ddb34b076a8c0a9e5a86f6220d1d5d892e9"
PKG_LICENSE="GPL"
PKG_SITE="http://projects.vdr-developer.org/projects/plg-xmltv2vdr"
PKG_URL="https://github.com/vdr-projects/vdr-plugin-xmltv2vdr/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain vdr sqlite openssl curl libzip libxml2 libxslt enca pcre"
PKG_NEED_UNPACK="$(get_pkg_directory vdr)"
PKG_LONGDESC="xmltv2vdr imports data in xmltv format"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+pic"

pre_configure_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing"
  export LIBS="-L${SYSROOT_PREFIX}/usr/lib/iconv -lpcre -lpcrecpp -lssl -lcrypto -lbz2"
}

make_target() {
  VDR_DIR=$(get_build_dir vdr)
  make VDRDIR=${VDR_DIR} \
    LIBDIR="." \
    LOCALEDIR="./locale"
}

post_make_target() {
  cd dist/epgdata2xmltv
  make -j1
  cd -
  ${STRIP} dist/epgdata2xmltv/epgdata2xmltv
}
