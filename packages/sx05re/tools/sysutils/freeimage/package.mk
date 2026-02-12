# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="freeimage"
PKG_VERSION="3180"
PKG_SHA256="f41379682f9ada94ea7b34fe86bf9ee00935a3147be41b6569c9605a53e438fd"
PKG_LICENSE="GPLv3"
PKG_SITE="http://freeimage.sourceforge.net/"
PKG_URL="${SOURCEFORGE_SRC}/${PKG_NAME}/FreeImage${PKG_VERSION}.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_SOURCE_DIR="FreeImage"
PKG_LONGDESC="FreeImage library"

pre_make_target() {
  # FreeImage Makefile.gnu uses CFLAGS/CXXFLAGS ?= (conditional set) with
  # defaults like -fPIC -fexceptions -fvisibility=hidden.  Since the build
  # system exports CFLAGS/CXXFLAGS, those defaults are completely lost.
  # The Makefile also only adds -fPIC for x86_64 hosts (uname -m check),
  # so aarch64 build hosts never get it.  Re-add the required flags here.
  #
  # -DDISABLE_PERF_MEASUREMENT must be in CXXFLAGS too: LibJXR perfTimer.h
  # contains x86 RDTSC inline asm guarded only by this define.  The Makefile
  # only adds it to CFLAGS, so any C++ file that transitively includes JXR
  # headers compiles the x86 asm on aarch64 -> SIGILL at load time.
  export CFLAGS="${CFLAGS} -fPIC -fexceptions -fvisibility=hidden -DPNG_ARM_NEON_OPT=0"
  export CXXFLAGS="${CXXFLAGS} -fPIC -fexceptions -fvisibility=hidden -Wno-narrowing -std=c++11 -DDISABLE_PERF_MEASUREMENT"
}
