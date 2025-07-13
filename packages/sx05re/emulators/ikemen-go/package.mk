# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present DiegroSan github
# 
# Thank you very much, leonkasovan, for the Port (aarch64/arm64 port) SDL ikemen-go
#

PKG_NAME="ikemen-go"
PKG_VERSION="dda76beac02a884de867bf48e67b9ba24fe766f3"
PKG_REV="1"
PKG_ARCH="any" 
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/leonkasovan/Ikemen-GO"
PKG_URL="https://github.com/leonkasovan/Ikemen-GO.git"
PKG_DEPENDS_TARGET="toolchain go:host go SDL2 ${OPENGLES}"
PKG_TOOLCHAIN="manual"
PKG_SHORTDESC="Open-source fighting game engine"
PKG_LONGDESC="Ikemen GO is an open-source fighting game engine."
PKG_IS_TARGET=y

pre_configure_target() {
   
    export GOOS=linux 
    export GOARCH=arm64 
    export CGO_ENABLED=1
    
    export CGO_CFLAGS="$CFLAGS -w -DGL_GLEXT_PROTOTYPES $(pkg-config --cflags sdl2)"
    export CGO_CXXFLAGS="$CXXFLAGS -w -DGL_GLEXT_PROTOTYPES"
    export CGO_LDFLAGS="$LDFLAGS -lGLESv2 -lEGL $(pkg-config --libs sdl2)"
    
    export GOPATH="$PKG_BUILD/.gopath"
    export GOROOT="$(get_build_dir go)"
    export PATH="$GOROOT/bin:$PATH"
    
    export PKG_CONFIG_PATH="$SYSROOT_PREFIX/usr/lib/pkgconfig:$SYSROOT_PREFIX/usr/share/pkgconfig"
}

pre_make_target() {
    # Garantir que as dependências estejam atualizadas / Ensure dependencies are up to date
    go mod tidy
    chmod -R 775 "${PKG_BUILD}/.gopath"
}

make_target() {
    cd "$PKG_BUILD"
    chmod a+x build/build.sh
    cd ./build && ./build.sh pi4
    chmod -R 775 "${PKG_BUILD}/.gopath"
}

makeinstall_target() {
    
    mkdir -p "$INSTALL/usr/bin"
    mkdir -p "$INSTALL/usr/share/ikemen_go"

    cp -f "$PKG_DIR/src/Ikemen_Go.sh" "$INSTALL/usr/bin/Ikemen_Go.sh"
    cp "$PKG_BUILD/bin/Ikemen_Go_"* "$INSTALL/usr/bin/Ikemen_Go"
    
    # Copiar recursos / Copy resources
    cp -rf "$PKG_BUILD/data" "$INSTALL/usr/share/ikemen_go"
    cp -rf "$PKG_BUILD/external" "$INSTALL/usr/share/ikemen_go"
    cp -rf "$PKG_BUILD/font" "$INSTALL/usr/share/ikemen_go"

    chmod +x "$INSTALL/usr/bin/Ikemen_Go.sh"
    chmod +x "$INSTALL/usr/bin/Ikemen_Go"
    
}

