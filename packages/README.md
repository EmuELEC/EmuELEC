# Structure of package.mk files

## Introduction

The package.mk file defines variables and functions to build a package.

## Variables
To control the build behaviour of your package, use variables in the top-down order listed here.

#### Base

| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_NAME    | -       | yes | Name of the packaged software application. Should be lowercase |
| PKG_VERSION | -       | yes | Version of the packaged software application. If the version is a githash, please use the full githash, not the abbreviated form. |
| PKG_SHA256  | -       | yes | SHA256 hashsum of the application download file |
| PKG_ARCH    | any     | no  | Architectures for which the package builds. `any` or a space separated list of `aarch64`, `arm` or `x86_64` |
| PKG_LICENSE | -       | yes | License of the software application. [Reference](https://github.com/LibreELEC/LibreELEC.tv/tree/master/licenses) |
| PKG_SITE    | -       | yes | Site of the software application |
| PKG_URL     | -       | yes | Address at which the source of the software application can be retrieved |
| PKG_MAINTAINER | -    | no  | Your name |
| PKG_DEPENDS_BOOTSTRAP<br>PKG_DEPENDS_HOST   PKG_DEPENDS_INIT   PKG_DEPENDS_TARGET | - | no | A space separated list of name of packages required to build the software application |
| PKG_SECTION | -       | no  | virtual if the package only defines dependencies |
| PKG_SHORTDESC | -     | no<br>yes&nbsp;for&nbsp;addons | Short description of the software package |
| PKG_LONGDESC | -      | yes | Long description of the package including purpose or function within LibreELEC or Kodi |

#### Universal Build Option
| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_SOURCE_DIR | -    | no  | Force the folder name that application sources are unpacked to. Used when sources do not automatically unpack to a folder with the `PKG_NAME-PKG_VERSION` naming convention. |
| PKG_TAR_STRIP_COMPONENTS | -   | no  | When this option is set the top level directory is not get stripped off while extracting an archive. |
| PKG_SOURCE_NAME | -   | no  | Force the filename of the application sources. Used when the filename is not the basename of `PKG_URL` |
| PKG_PATCH_DIRS | -    | no  | Patches in `./patches` are automatically applied after package unpack. Use this option to include patches from an additional folder, e.g. `./patches/$PKG_PATCH_DIRS` |
| PKG_NEED_UNPACK | -   | no  | Space separated list of files or folders to include in package stamp calculation. If the stamp is invalidated through changes to package files or dependent files/folders the package is cleaned and rebuilt. e.g. `PKG_NEED_UNPACK="$(get_pkg_directory linux)"` will trigger clean/rebuild of a Linux kernel driver package when a change to the `linux` kernel package is detected. |
| PKG_TOOLCHAIN | auto  | no  | Control which build toolchain is used. For detailed information, see [reference](#toolchain-options). |
| PKG_BUILD_FLAGS | -   | no  | A space separated list of flags with which to fine-tune the build process. Flags can be enabled or disabled with a `+` or `-` prefix. For detailed information, see the [Reference](#build_flags-options). |
| PKG_PYTHON_VERSION | python3.8 | no | Define the Python version to be used. |
| PKG_IS_KERNEL_PKG | - | no  | Set to `yes` for packages that include Linux kernel modules |
| PKG_DEPENDS_CONFIG | - | no  | Space separated list of packages to add to PKG_CONFIG_PATH. Use this to build with support for `-sysroot` packages (See [reference](BUILD_FLAGS options). |

#### Meson Options
| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_MESON_SCRIPT | $PKG_BUILD/meson.build | no | Meson build file to use |
| PKG_MESON_OPTS_TARGET | - | no   | Options directly passed to meson |

#### CMAKE Options
| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_CMAKE_SCRIPT | $PKG_BUILD/CMakeLists.txt | no | CMake build file to use |
| PKG_CMAKE_OPTS_HOST<br>PKG_CMAKE_OPTS_TARGET | - | no | Options directly passed to cmake |

#### Configure Options
| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_CONFIGURE_SCRIPT | $PKG_BUILD/configure | no | configure script to use |
| PKG_CONFIGURE_OPTS<br>PKG_CONFIGURE_OPTS_BOOTSTRAP<br>PKG_CONFIGURE_OPTS_HOST<br>PKG_CONFIGURE_OPTS_INIT<br>PKG_CONFIGURE_OPTS_TARGET | - | no | Options directly passed to configure |

#### Make Options
| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_MAKE_OPTS<br>PKG_MAKE_OPTS_BOOTSTRP<br>PKG_MAKE_OPTS_HOST<br>PKG_MAKE_OPTS_INIT<br> PKG_MAKE_OPTS_TARGET | - | no | Options directly passed to make in the build step
| PKG_MAKEINSTALL_OPTS_HOST<br>PKG_MAKEINSTALL_OPTS_TARGET | - | no | Options directly passed to make in the install step

#### Addons
Additional options used when the package builds an addon.

| Variable    | Default | Required |Description |
|-------------|---------|----------|------------|
| PKG_REV     | -       | yes      | The revision number of the addon (starts at 100). Must be placed after `PKG_VERSION`. Must be incremented for each new version else Kodi clients will not detect version change and download the updated addon. |
| PKG_IS_ADDON | no     | yes      | Must be set to `yes` <br>or to `embedded` when this addon is part of the image |
| PKG_ADDON_NAME | -    | yes      | Proper name of the addon that is shown at the repo |
| PKG_ADDON_TYPE | -    | yes      | See LE/config/addon/ for other possibilities |
| PKG_ADDON_VERSION | - | no       | The version of the addon, used in addon.xml |
| PKG_ADDON_PROVIDES | - | no      | [Provides](http://kodi.wiki/view/addon.xml#.3Cprovides.3E_element) in addon-xml |
| PKG_ADDON_REQUIRES | - | no      | [Requires](http://kodi.wiki/view/addon.xml#.3Crequires.3E) used in addon.xml |
| PKG_ADDON_PROJECTS | @PROJECTS@ | no | for available projects or devices, see projects subdirectory (note: Use RPi for RPi project, and RPi1 for RPi device) |
| PKG_DISCLAIMER | -    | no       | [Disclaimer](https://kodi.wiki/view/Addon.xml#.3Cdisclaimer.3E) in addon-xml |
| PKG_ADDON_IS_STANDALONE | - | no | Defines if an addon depends on Kodi (on) or is standalone (yes) |
| PKG_ADDON_BROKEN | -  | no       | Marks an addon as broken for the user |

#### Detailed Information for Options

##### TOOLCHAIN options

Application/packages needs different toolchains for build.
For instance `cmake` or the classic `./configure` or same very different.

For the most application/packages, the auto-detection of the toolchain works proper.
But not always. To select a specific toolchain, you only need to set the `PKG_TOOLCHAIN` variable.

| Toolchain   | Description (if needed) |
|-----------  |-------------------------|
| meson       | [Meson Build System](http://mesonbuild.com/) |
| cmake       | [CMake](https://cmake.org/) with Ninja |
| cmake-make  | [CMake](https://cmake.org/) with Make |
| autotools   | [GNU Build System](https://en.wikipedia.org/wiki/GNU_Build_System)
| configure   | preconfigured [GNU Build System](https://en.wikipedia.org/wiki/GNU_Build_System) |
| ninja       | [Ninja Build](https://ninja-build.org/) |
| make        | [Makefile Based](https://www.gnu.org/software/make/) |
| manual      | only runs self writen build steps, see [Functions](#functions) |

###### Auto-Detection
The auto-detections looks for specific files in the source path.

1. `meson.build` (PKG_MESON_SCRIPT) => meson toolchain
2. `CMakeLists.txt` (PKG_CMAKE_SCRIPT) => cmake toolchain
3. `configure` (PKG_CONFIGURE_SCRIPT) => configure toolchain
4. `Makefile` => make toolchain

When none of these was found, the build abort and you have to set the toolchain via `PKG_TOOLCHAIN`

##### BUILD_FLAGS options

Build flags implement often used build options. Normally these are activated be default, but single applications/packages has problems to compile/run with these.

Set the variable `PKG_BUILD_FLAGS` in the `package.mk` to enable/disable the single flags. It is a space separated list. The flags can enabled with a `+` prefix, and disabled with a `-`.

| flag     | default  | affected stage(s) | description |
|----------|----------|-------------------|-------------|
| pic      | disabled | target, init      | [Position Independent Code](https://en.wikipedia.org/wiki/Position-independent_code) |
| pic:host | disabled | host, bootstrap   | see above |
| speed    | disabled | target, init      | replaces default `-O2` compiler optimization with `-O3` (can only enable; overrules size) |
| size     | disabled | target, init      | replaces default `-O2` compiler optimization with `-Os` (can only enable) |
| lto      | disabled | target, init      | enable LTO (Link Time optimization) in the compiler and linker unless disabled via `LTO_SUPPORT`. Compiles non-fat LTO objects (only bytecode) and performs single-threaded optimization at link stage |
| lto-parallel | disabled | target, init  | same as `lto` but enables parallel optimization at link stage. Only enable this if the package build doesn't run multiple linkers in parallel otherwise this can result in lots of parallel processes! |
| lto-fat  | disabled | target, init      | same as `lto` but compile fat LTO objects (bytecode plus optimized assembly). This increases compile time but can be useful to create static libraries suitable both for LTO and non-LTO linking |
| lto-off  | disabled | target, init      | explicitly disable LTO in the compiler and linker |
| bfd      | - | target, init | `+bfd` prefers bfd linker over default linker, `-bfd` disables using bfd |
| gold     | - | target, init | `+gold` prefers gold linker over default linker, `-gold` disables using gold |
| mold     | - | target, init | `+mold` prefers mold linker over default linker, `-mold` disables using gold |
| parallel | enabled  | all | `make` or `ninja` builds with multiple threads/processes (or not) |
| strip    | enabled  | target | strips executables (or not) |
| sysroot  | enabled  | target | installs the package to the sysroot folder (or not) |
| local-cc | disabled | host | use compiler from buildhost instead of host-gcc/g++ in toolchain |

###### Example
```
PKG_BUILD_FLAGS="+pic -gold"
PKG_BUILD_FLAGS="-parallel"
```

## Functions
All build steps in the LibreELEC build system are done by shell function.
These functions can be overwritten in the `package.mk`. However, this raises problems when the build system is updated. To reduce the impact, most functions are extended by `pre_` and `post_` scripts to use instead.

When it is nesseary to replace configure, make and makeinstall, please use `PKG_TOOLCHAIN="manual"`.

Some of the build steps needs to be run once, like `unpack`. Other steps needs to be run multiple times, to create the toolchain (stage bootstrap & host) or to create the LE image (stage init & target). These stage specific functions have the stage as suffix, like `make_target`.

Full list of overwrittable functions.

| function                | stages specific | description |
|-------------------------|--------|-------------|
| configure_package | - | Optional function to implement late binding variable assignment (see below) |
| unpack<br>pre_unpack<br>post_unpack | - | Extract the source from the downloaded file |
| pre_patch<br>post_patch | -      | Apply the patches to the source, after extraction. The patch function it self is not allowed to overwritten |
| pre_build_\[stage]      | yes    | Runs before of the start of the build |
| pre_configure<br>pre_configure_\[stage]<br>configure_\[stage]<br>post_configure_\[stage] | yes | Configure the package for the compile. This is only relevant for toolchain, that supports it (e.g. meson, cmake, configure, manual) |
| make_\[stage]<br>pre_make_\[stage]<br>post_make_\[stage] | yes | Build of the package |
| makeinstall_\[stage]<br>pre_makeinstall_\[stage]<br>post_makeinstall_\[stage] | yes | Installation of the files in the correct pathes<br>host: TOOLCHAIN<br>target: SYSROOT and IMAGE<br>bootstrap and init: temporary destination
| addon                   | -      | Copy all files together for addon creation. This is requiered for addons |
| post_install_addon      | -      | Post processing of installed addon files in `${INSTALL}` directory |

## Directory structure
Every package has its own set of build and install directories. The sources are extracted and built in the former, and build artifacts are installed to the latter.
Usually an install target provided by the package build system will populate the install directory automatically, but it's important that you use the standard `usr/lib/`, `usr/bin/` etc. structure when doing so manually, because the contents of the install directory will be part of the final image (with the exception of top level hidden directories).

Sometimes it's necessary to access build artifacts from different packages - like an addon collecting files of various other packages. In that case you need to access the files using the package's install directories (and not their build directories since they might not exist anymore). If you need additional files which should not be part of the final image, you can use a hidden directory for those - grep for `.noinstall` for some examples.

## Late Binding variable assignment

A package will be loaded only once, by the call to `config/options`. During this process, additional package specific variables will be initialised, such as:

* `PKG_BUILD` - path to the build folder
* `PKG_SOURCE_NAME` - if not already specified, generated from `PKG_URL`, `PKG_NAME` and` PKG_VERSION`

Since these variables will not exist at the time the package is loaded, they can only be referenced **after** package has loaded. This can be accomplished by referencing these variables in the `configure_package()` function which is executed once the additional variables have been assigned.

If necessary, the following variables would be configured in `configure_package()` as they are normally relative to `${PKG_BUILD}`:
```
  PKG_CONFIGURE_SCRIPT
  PKG_CMAKE_SCRIPT
  PKG_MESON_SCRIPT
```

Further to this, toolchain variables that are defined in `setup_toolchain()` must not be referenced "globally" in the package as they will only be configured reliably after `setup_toolchain()` has been called during `scripts/build`. Any variable in the following list must instead be referenced in a package function such as `pre_build_*`, `pre_configure_*`, `pre_make_*` etc.:
```
  TARGET_CFLAGS TARGET_CXXFLAGS TARGET_LDFLAGS
  NINJA_OPTS MAKEFLAGS
  DESTIMAGE
  CC CXX CPP LD
  AS AR NM RANLIB
  OBJCOPY OBJDUMP
  STRIP
  CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
  PKG_CONFIG
  PKG_CONFIG_PATH
  PKG_CONFIG_LIBDIR
  PKG_CONFIG_SYSROOT_DIR
  PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
  PKG_CONFIG_ALLOW_SYSTEM_LIBS
  CMAKE_CONF CMAKE
  HOST_CC HOST_CXX HOSTCC HOSTCXX
  CC_FOR_BUILD CXX_FOR_BUILD BUILD_CC BUILD_CXX
  _python_sysroot _python_prefix _python_exec_prefix
```

Lastly, the following variables are assigned during `scripts/build` but some packages may need to use alternative values for these variables. To do so, the package must assign alternative values in `pre_build_*`/`pre_configure_*`/`pre_make_*` etc. functions as these functions will be called after the variables are initialised with default values in `scripts/build` but before they are used by `scripts/build`.
```
  CMAKE_GENERATOR_NINJA

  TARGET_CONFIGURE_OPTS
  TARGET_CMAKE_OPTS
  TARGET_MESON_OPTS

  HOST_CONFIGURE_OPTS
  HOST_CMAKE_OPTS
  HOST_MESON_OPTS

  INIT_CONFIGURE_OPTS
  INIT_CMAKE_OPTS
  INIT_MESON_OPTS

  BOOTSTRAP_CONFIGURE_OPTS
  BOOTSTRAP_CMAKE_OPTS
  BOOTSTRAP_MESON_OPTS
```

#### Example
```
configure_package() {
  # now we know where we're building, assign a value
  PKG_CONFIGURE_SCRIPT="${PKG_BUILD}/gettext-tools/configure"
}

post_patch() {
  # replace hardcoded stuff
  sed -i ${PKG_CONFIGURE_SCRIPT} 's|hardcoded stuff|variable stuff|'
}

pre_configure_target() {
  # add extra flag to toolchain default
  CFLAGS="$CFLAGS -DEXTRA_FLAG=yeah"
}

post_makeinstall_target() {
  # remove unused executable, install what remains
  rm $INSTALL/usr/bin/bigexecutable
}
```

#### tools/pkgcheck

Use `tools/pkgcheck` to verify packages. It detects the following issues:

Issue | Level | Meaning |
| :--- | :----: | ---- |
| late&nbsp;binding&nbsp;violation | FAIL | Late binding variables referenced outside of a function - see [late binding](https://github.com/LibreELEC/LibreELEC.tv/blob/master/packages/readme.md#late-binding-variable-assignment) |
| duplicate&nbsp;function&nbsp;def | FAIL | Function defined multiple times, only last definition will be used |
| bad&nbsp;func&nbsp;-&nbsp;missing&nbsp;brace | FAIL | Opening brace (`{`) for function definition should be on same line as the function def, ie. `pre_configure_target() {` |
| intertwined&nbsp;vars&nbsp;&&nbsp;funcs | WARN | Variable assignments and logic is intertwined with functions - this is cosmetic, but variables and logic should be specified before all functions |
| unknown&nbsp;function | WARN | Could be a misspelled function, ie. `per_configure_target() {` which might fail silently.|
| ignored&nbsp;depends&nbsp;assign | WARN | Values assigned to `PKG_DEPENDS_*` outside of the global section or `configure_package()` will be ignored. |


## Add a new package to the Image
1. Think about, why you need it in the image.
    * new multimedia tool
    * add a new network tool
    * new kernel driver
    * ...
2. Find a place in the packages tree
    * look into the package tree structure, which is generally self explaind.
    * do not place it in an existing package (directory that includes a `package.mk`)
    * when you found a place, create a directory with the name of your package (use same value for `PKG_NAME`!!)
3. Create an initial `package.mk`
    * you can find a template under `packages/package.mk.template`. Copy the template into the new directory and call it `package.mk`
    * apply any required changes to your new `package.mk`
4. Find a place in the dependency tree
    * when it extend an existing package, add it there to the `PKG_DEPENDS_TARGET`/`PKG_DEPENDS_HOST` etc.
    * take a look into the path `packages/virtual`, there you should find a virtual packages, that match your new package (misc-packages should be the last option)
5. Now you can build your image
    * after the build, inside the `BUILD_DIR` (normally build.*) folder you should find a directory with your package name and -version, eg. `widget-1.2.3`.

## Example
```
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mariadb-connector-c"
PKG_VERSION="3.0.2"
PKG_SHA256="f44f436fc35e081db3a56516de9e3bb11ae96838e75d58910be28ddd2bc56d88"
PKG_LICENSE="LGPL"
PKG_SITE="https://mariadb.org/"
PKG_URL="https://github.com/MariaDB/mariadb-connector-c/archive/v$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib openssl"
PKG_LONGDESC="mariadb-connector: library to conntect to mariadb/mysql database server"
PKG_BUILD_FLAGS="-gold"

PKG_CMAKE_OPTS_TARGET="-DWITH_EXTERNAL_ZLIB=ON \
                       -DAUTH_CLEARTEXT=STATIC \
                       -DAUTH_DIALOG=STATIC \
                       -DAUTH_OLDPASSWORD=STATIC \
                       -DREMOTEIO=OFF"

post_makeinstall_target() {
  # drop all unneeded
  rm -rf $INSTALL/usr
}
```
