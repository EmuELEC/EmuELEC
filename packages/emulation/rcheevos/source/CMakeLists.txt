project(rcheevos)

cmake_minimum_required(VERSION 3.0)

# Disable Lua for now
add_definitions(-DRC_DISABLE_LUA)

include_directories(
  include
)

add_library(${PROJECT_NAME}lib
  src/rcheevos/alloc.c
  src/rcheevos/compat.c
  src/rcheevos/condition.c
  src/rcheevos/condset.c
  src/rcheevos/consoleinfo.c
  src/rcheevos/format.c
  src/rcheevos/lboard.c
  src/rcheevos/memref.c
  src/rcheevos/operand.c
  src/rcheevos/richpresence.c
  src/rcheevos/runtime.c
  src/rcheevos/runtime_progress.c
  src/rcheevos/trigger.c
  src/rcheevos/value.c
  src/rhash/cdreader.c
  src/rhash/hash.c
  src/rhash/md5.c
  src/rurl/url.c
)

#add_dependencies(rcheevos
#  lua # TODO
#)

#target_link_libraries(rcheevos
#  lua
#)

install(TARGETS
  ${PROJECT_NAME}lib
  ARCHIVE DESTINATION
    lib
  DESTINATION
    lib
)

install(
  FILES
    include/rcheevos.h
    include/rconsoles.h
    include/rhash.h
    include/rurl.h
  DESTINATION
    include/${PROJECT_NAME}
)

#install(
#  DIRECTORY
#    include
#  DESTINATION
#    include
#)
