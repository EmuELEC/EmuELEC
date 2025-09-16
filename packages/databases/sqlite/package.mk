# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="sqlite"
PKG_VERSION="3.40.1"
PKG_VERSION_SQLITE="${PKG_VERSION/./}00"
PKG_SHA256="2c5dea207fa508d765af1ef620b637dcb06572afa6f01f0815bd5bbf864b33d9"
PKG_LICENSE="PublicDomain"
PKG_SITE="https://www.sqlite.org/"
PKG_URL="https://www.sqlite.org/2022/${PKG_NAME}-autoconf-${PKG_VERSION_SQLITE/./0}.tar.gz"
PKG_DEPENDS_HOST="ccache:host autoconf:host automake:host"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_LONGDESC="An Embeddable SQL Database Engine."
# libsqlite3.a(sqlite3.o): requires dynamic R_X86_64_PC32 reloc against 'sqlite3_stricmp' which may overflow at runtime
PKG_BUILD_FLAGS="+pic +pic:host -parallel"

PKG_CONFIGURE_OPTS_TARGET="--disable-static \
                           --enable-shared \
                           --disable-readline \
                           --enable-threadsafe \
                           --enable-dynamic-extensions \
                           --with-gnu-ld"

pre_configure_target() {
# sqlite fails to compile with fast-math link time optimization.
  CFLAGS=$(echo ${CFLAGS} | sed -e "s|-Ofast|-O3|g")
  CFLAGS=$(echo ${CFLAGS} | sed -e "s|-ffast-math||g")

# This option adds additional logic to the ANALYZE command and to the query planner
# that can help SQLite to chose a better query plan under certain situations. The
# ANALYZE command is enhanced to collect histogram data from each index and store
# that data in the sqlite_stat4 table. The query planner will then use the histogram
# data to help it make better index choices.
  CFLAGS+=" -DSQLITE_ENABLE_STAT4"

# When this C-preprocessor macro is defined, SQLite includes some additional APIs
# that provide convenient access to meta-data about tables and queries. The APIs that
# are enabled by this option are:
#  - sqlite3_column_database_name()
#  - sqlite3_column_database_name16()
#  - sqlite3_column_table_name()
#  - sqlite3_column_table_name16()
#  - sqlite3_column_origin_name()
#  - sqlite3_column_origin_name16()
#  - sqlite3_table_column_metadata()
  CFLAGS+=" -DSQLITE_ENABLE_COLUMN_METADATA=1"

# This macro sets the default limit on the amount of memory that will be used for
# memory-mapped I/O for each open database file. If the N is zero, then memory
# mapped I/O is disabled by default. This compile-time limit and the
# SQLITE_MAX_MMAP_SIZE can be modified at start-time using the
# sqlite3_config(SQLITE_CONFIG_MMAP_SIZE) call, or at run-time using the
# mmap_size pragma.
  CFLAGS+=" -DSQLITE_TEMP_STORE=3 -DSQLITE_DEFAULT_MMAP_SIZE=268435456"
}
