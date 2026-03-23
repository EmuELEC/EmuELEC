# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="TvTextViewer"
PKG_VERSION="f3d2ecd7276a2fb44c0dbbd163b837feb8dc4aa1"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/lethal-guitar/TvTextViewer"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="Full-screen text viewer tool with gamepad controls"
PKG_TOOLCHAIN="manual"

post_unpack() {
# Initialize git submodules
cd ${PKG_BUILD}
git submodule update --init --recursive 2>/dev/null || true
}

make_target() {
cd ${PKG_BUILD}

# Get SDL2 flags from pkg-config
SDL_CFLAGS=$(${TOOLCHAIN}/bin/pkg-config --cflags sdl2)
SDL_LIBS=$(${TOOLCHAIN}/bin/pkg-config --libs sdl2)

# Build object files
IMGUI_DIR="3rd_party/imgui"
CXXOPTS_DIR="3rd_party/cxxopts"

SOURCES="main.cpp imgui_impl_sdl.cpp view.cpp"
SOURCES="${SOURCES} ${IMGUI_DIR}/imgui.cpp ${IMGUI_DIR}/imgui_draw.cpp ${IMGUI_DIR}/imgui_tables.cpp ${IMGUI_DIR}/imgui_widgets.cpp"
SOURCES="${SOURCES} ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp"

COMMON_FLAGS="-I${IMGUI_DIR} -I${IMGUI_DIR}/backends -I${CXXOPTS_DIR}/include"
COMMON_FLAGS="${COMMON_FLAGS} -std=c++17 -O2 -Wall -Wformat -DIMGUI_IMPL_OPENGL_ES2"
COMMON_FLAGS="${COMMON_FLAGS} ${SDL_CFLAGS}"

# Compile each source file
for src in ${SOURCES}; do
  obj=$(basename ${src} .cpp).o
  echo "Compiling ${src}..."
  ${CXX} ${TARGET_CXXFLAGS} ${COMMON_FLAGS} -c ${src} -o ${obj}
done

# Link
echo "Linking text_viewer..."
OBJS=$(for src in ${SOURCES}; do echo -n "$(basename ${src} .cpp).o "; done)
${CXX} ${TARGET_LDFLAGS} -o text_viewer ${OBJS} -lGLESv2 -ldl ${SDL_LIBS}
}

makeinstall_target(){
mkdir -p ${INSTALL}/usr/bin
cp ${PKG_BUILD}/text_viewer ${INSTALL}/usr/bin
}
