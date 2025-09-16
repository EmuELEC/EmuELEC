cmake_minimum_required(VERSION 3.7)

project(xmp-lite VERSION 4.5.0 LANGUAGES C)

add_library(xmp-lite
	include/libxmp-lite/xmp.h
	src/virtual.c
	src/format.c
	src/period.c
	src/player.c
	src/read_event.c
	src/dataio.c
	src/lfo.c
	src/scan.c
	src/control.c
	src/filter.c
	src/effects.c
	src/mixer.c
	src/mix_all.c
	src/load_helpers.c
	src/load.c
	src/hio.c
	src/smix.c
	src/memio.c
	src/md5.c
	src/misc.c
	src/loaders/common.c
	src/loaders/itsex.c
	src/loaders/sample.c
	src/loaders/xm_load.c
	src/loaders/mod_load.c
	src/loaders/s3m_load.c
	src/loaders/it_load.c)

target_include_directories(xmp-lite PUBLIC
	$<BUILD_INTERFACE:include/libxmp-lite src>
	$<INSTALL_INTERFACE:include/libxmp-lite>)

target_compile_definitions(xmp-lite PRIVATE
	LIBXMP_CORE_PLAYER=1
	LIBXMP_NO_DEPACKERS=1)

# pkg-config
set(PACKAGE_TARNAME ${PROJECT_NAME})
set(prefix "${CMAKE_INSTALL_PREFIX}")
set(exec_prefix "\${prefix}")
set(libdir "\${exec_prefix}/lib")
set(includedir "\${prefix}/include")
configure_file(lib${PROJECT_NAME}.pc.in libxmp.pc @ONLY)

# install
install(
	TARGETS xmp-lite
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin)

install(
	FILES include/libxmp-lite/xmp.h
	DESTINATION include/libxmp-lite)

install(
	FILES ${CMAKE_CURRENT_BINARY_DIR}/libxmp.pc
	DESTINATION lib/pkgconfig
)
