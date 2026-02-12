# SPDX-License-Identifier: GPL-2.0-or-later
# RK3566 uses mali-bifrost blob driver
# Mesa provides only EGL/GBM infrastructure without rendering drivers
# mali-bifrost blob (libmali.so) provides actual GL/GLES implementation

PKG_NAME="mesa"
PKG_VERSION="23.3.6"
PKG_SHA256="cd3d6c60121dea73abbae99d399dc2facaecde1a8c6bd647e6d85410ff4b577b"
PKG_LICENSE="OSS"
PKG_SITE="http://www.mesa3d.org/"
PKG_URL="https://archive.mesa3d.org/mesa-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain expat libdrm Mako:host wayland wayland-protocols"
PKG_LONGDESC="Mesa is a 3-D graphics library with an API."
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET="-Dgallium-drivers=swrast \
                       -Dvulkan-drivers= \
                       -Dplatforms=wayland \
                       -Dgbm=enabled \
                       -Degl=enabled \
                       -Dgles1=disabled \
                       -Dgles2=enabled \
                       -Dopengl=false \
                       -Dglx=disabled \
                       -Ddri3=disabled \
                       -Dshared-glapi=enabled \
                       -Dllvm=disabled \
                       -Dgallium-extra-hud=false \
                       -Dgallium-omx=disabled \
                       -Dgallium-nine=false \
                       -Dgallium-opencl=disabled \
                       -Dshader-cache=enabled \
                       -Dvalgrind=disabled \
                       -Dlibunwind=disabled \
                       -Dlmsensors=disabled \
                       -Dbuild-tests=false \
                       -Dselinux=false \
                       -Dosmesa=false \
                       -Dgallium-vdpau=disabled \
                       -Dgallium-va=disabled \
                       -Dgallium-xa=disabled \
                       -Dglvnd=false"

