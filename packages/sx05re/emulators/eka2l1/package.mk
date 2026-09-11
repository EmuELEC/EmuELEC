# SPDX-License-Identifier: GPL-2.0
PKG_NAME="eka2l1"
PKG_VERSION="d2e7abb191bf41ffa1413100154590e0930aebfa"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://github.com/AveyondFly/EKA2L1"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="master"
PKG_GIT_SUBMODULES="yes"
PKG_DEPENDS_TARGET="toolchain SDL2 freetype zlib wayland"
PKG_SECTION="emuelec/emulators"
PKG_SHORTDESC="Symbian OS / N-Gage emulator for aarch64 Linux"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="
  -DCMAKE_BUILD_TYPE=Release
  -DEKA2L1_BUILD_TESTS=OFF
  -DEKA2L1_BUILD_SDL2_FRONTEND=ON
"

pre_configure_target() {
  # Remove Qt frontend (not needed for SDL2 build)
  sed -i '/add_subdirectory(qt)/d' ${PKG_BUILD}/src/emu/CMakeLists.txt
  
  # Remove buildvm include (causes issues with cross-compilation)
  sed -i '/target_include_directories(buildvm/d' ${PKG_BUILD}/src/external/CMakeLists.txt
  
  # Remove mbedtls tests/programs (reduces build time)
  sed -i '/add_subdirectory(programs)/d' ${PKG_BUILD}/src/external/mbedtls/CMakeLists.txt
  sed -i '/add_subdirectory(tests)/d' ${PKG_BUILD}/src/external/mbedtls/CMakeLists.txt
  
  # Stub GLX/Vulkan backends (not available on embedded systems)
  echo "// stub" > ${PKG_BUILD}/src/emu/drivers/src/graphics/backend/context_glx.cpp
  echo "// stub" > ${PKG_BUILD}/src/emu/drivers/src/graphics/backend/vulkan/graphics_vulkan.cpp

  # EGL compatibility: Add _KHR suffix for older EGL headers (LibreELEC/EmuELEC)
  find ${PKG_BUILD}/src/emu/drivers -type f \( -name "*.cpp" -o -name "*.c" -o -name "*.h" \) | while read f; do
    sed -i 's/\bEGL_CONTEXT_MAJOR_VERSION\b/EGL_CONTEXT_MAJOR_VERSION_KHR/g' "$f"
    sed -i 's/\bEGL_CONTEXT_MINOR_VERSION\b/EGL_CONTEXT_MINOR_VERSION_KHR/g' "$f"
  done

  # FFmpeg stub for system FFmpeg
  cat > ${PKG_BUILD}/src/external/ffmpeg/CMakeLists.txt << 'EOF'
if (NOT DEFINED FFMPEG_CORE_NAME)
    set(FFMPEG_CORE_NAME ffmpeg)
endif()
add_library(${FFMPEG_CORE_NAME} INTERFACE)
target_include_directories(${FFMPEG_CORE_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${FFMPEG_CORE_NAME} INTERFACE avformat avcodec avutil swscale swresample z)
EOF
}

make_target() {
  BUILD_DIR="${PKG_BUILD}/.${TARGET_NAME}"
  LUAJIT_SRC="${PKG_BUILD}/src/external/luajit/src"
  LUAJIT_CMAKE_BUILD="${BUILD_DIR}/src/external/luajit-cmake"
  MINILUA_BIN="${LUAJIT_CMAKE_BUILD}/minilua/minilua"
  BUILDVM_BIN="${LUAJIT_CMAKE_BUILD}/buildvm/buildvm"

  cd "${BUILD_DIR}"

  # Build minilua manually (ninja target often missing for cross-compilation)
  ninja minilua 2>/dev/null || true
  gcc "${LUAJIT_SRC}/host/minilua.c" -o "${MINILUA_BIN}" -lm
  ninja -t restat

  # Build buildvm manually (host tool for target code generation)
  ninja buildvm 2>/dev/null || true
  gcc \
    -I"${LUAJIT_SRC}" \
    -I"${LUAJIT_CMAKE_BUILD}" \
    -DLUAJIT_TARGET=LUAJIT_ARCH_arm64 \
    -DLJ_ARCH_HASFPU=1 \
    -DLJ_ABI_SOFTFP=0 \
    -DLUAJIT_NUMMODE=2 \
    "${LUAJIT_SRC}/host/buildvm.c" \
    "${LUAJIT_SRC}/host/buildvm_asm.c" \
    "${LUAJIT_SRC}/host/buildvm_fold.c" \
    "${LUAJIT_SRC}/host/buildvm_lib.c" \
    "${LUAJIT_SRC}/host/buildvm_peobj.c" \
    -o "${BUILDVM_BIN}" -lm
  ninja -t restat

  # Main build
  ninja ${NINJA_OPTS} ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
  BUILD_DIR="${PKG_BUILD}/.${TARGET_NAME}"

  mkdir -p "${INSTALL}/usr/bin/eka2l1"
  cp -a "${BUILD_DIR}/bin/." "${INSTALL}/usr/bin/eka2l1/"
  
  # Only chmod if binary exists
  [ -f "${INSTALL}/usr/bin/eka2l1/eka2l1_sdl2" ] && chmod +x "${INSTALL}/usr/bin/eka2l1/eka2l1_sdl2"

  # Start script
  cp "${PKG_DIR}/scripts/ekastart.sh" "${INSTALL}/usr/bin/ekastart.sh"
  chmod +x "${INSTALL}/usr/bin/ekastart.sh"

  # Gamepad config
  mkdir -p "${INSTALL}/usr/config/emuelec/configs/eka2l1/gptk"
  cp -f "${PKG_DIR}/config/eka.gptk" "${INSTALL}/usr/config/emuelec/configs/eka2l1/gptk/eka.gptk"
}