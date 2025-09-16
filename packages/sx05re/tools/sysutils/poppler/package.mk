# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023-present Guoxin "7Ji" Pu (https://github.com/7Ji)

PKG_NAME="poppler"
PKG_VERSION="23.04.0"
_PKG_TAG="${PKG_NAME}-${PKG_VERSION}"
PKG_SHA256="61ab8a8da0ae2bd6f8e7e6f60d5970f7f87cd790c1620f0fe6fbcbdc095c7571"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.freedesktop.org/poppler/poppler"
PKG_URL="${PKG_SITE}/-/archive/${_PKG_TAG}/${PKG_NAME}-${_PKG_TAG}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib libpng libjpeg-turbo boost freetype fontconfig glib glib:host"
PKG_LONGDESC="The poppler pdf rendering library "
PKG_TOOLCHAIN="cmake"


pre_configure_target() { 
    PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=release \
                        -DENABLE_LIBOPENJPEG=none \
                        -DENABLE_GLIB=ON \
                        -DENABLE_QT5=off \
                        -DENABLE_CPP=off"
                        
    # Disable "gobject-introspection"
    sed -i "s|set(HAVE_INTROSPECTION \${INTROSPECTION_FOUND})|set(HAVE_INTROSPECTION "NO")|g" ${PKG_BUILD}/CMakeLists.txt
}

post_makeinstall_target() {
    mkdir -p ${INSTALL}/usr/bin/batocera
    ln -sf /usr/bin/pdftoppm ${INSTALL}/usr/bin/batocera/pdftoppm
    ln -sf /usr/bin/pdfinfo ${INSTALL}/usr/bin/batocera/pdfinfo
}
