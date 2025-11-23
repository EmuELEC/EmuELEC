PKG_NAME="lib32-vktests"
PKG_LICENSE="Public Domain"
PKG_SITE=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Various AI generated test programs"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="lib32"

make_target() {
    ${CC} sdltest.c -o sdltest -lSDL2 
    ${CC} sdl2_gles_info.c -o sdl2_gles_info -lSDL2 -lGLESv2 -lEGL -lstdc++
    ${CC} gbm_format_test.c -o gbm_format_test -lgbm -lEGL -lGLESv2 -ldl -lstdc++
    ${CC} vulkan_test.c -o vulkan_test -lSDL2 -lvulkan
    ${CC} vulkan_cube_debug.c -o vulkan_test2 -lSDL2 -lvulkan -lm
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp vulkan_test ${INSTALL}/usr/bin/vulkan_test_32
    cp vulkan_test2 ${INSTALL}/usr/bin/vulkan_test2_32
    cp sdltest ${INSTALL}/usr/bin/sdltest_32
    cp sdl2_gles_info ${INSTALL}/usr/bin/sdl2_gles_info_32
    cp gbm_format_test ${INSTALL}/usr/bin/gbm_format_test_32
}
