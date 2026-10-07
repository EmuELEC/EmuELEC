set(TARGET_NAME fssimplewindow_connection)

add_library(${TARGET_NAME} fssimplewindow_connection.h fssimplewindow_connection.cpp)
# SDL2 backend: link fssimplenowindow (no-op Fs* stubs + FsKeyCode tables)
# instead of fssimplewindow (X11/GLX). Keeps yssimplesound (ALSA) and ysgamepad.
target_link_libraries(${TARGET_NAME} outside_world fssimplenowindow yssimplesound cpputil ysgamepad)
target_include_directories(${TARGET_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

find_package(SDL2 REQUIRED)
if(TARGET SDL2::SDL2)
	target_link_libraries(${TARGET_NAME} SDL2::SDL2)
else()
	target_include_directories(${TARGET_NAME} PUBLIC ${SDL2_INCLUDE_DIRS})
	target_link_libraries(${TARGET_NAME} ${SDL2_LIBRARIES})
endif()

if(UNIX)
	target_link_libraries(${TARGET_NAME} yssimplesound_linux_alsa)
endif()
