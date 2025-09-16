# EmuELEC multilib packages
## Introduction
These packages and the updated EmuELEC build system provides real **aarch64** + **aarch32** multilib support to the build system and the image. It brings the ``ld.so.conf`` and ``/usr/lib32`` style multilib support to the target system just like standard Linux distros, and there's no more need to do tedious ``LD_LIBRARY_PATH`` hacks! ``ldconfig`` binary and systemd units will index the libs and make multilib applications load much faster

## Inclusion in build
To get a multilib target image, the package ``lib32-essential`` must be added, in EmuELEC we achive this by including it in ``emuelec`` meta package's dependencies. Ideally this pacakge should be included first before other lib32 packages, but it can still work even it's added last.

## Library search order

On the EmuELEC target system, the libraries will be searched in the following order:
 - Any path defined in ``LD_LIBRARY_PATH``. Most of them come from /etc/profile. Not indexed in ``ld.so.cache`` (slow)
   - /etc/profile.d
     - 99-emuelec.conf
       - ``/emuelec/lib32`` => ``/storage/.config/emuelec/lib32``, writable
       - ``/emuelec/lib`` => ``/storage/.config/emuelec/lib``, writable
     - 99-rk-mali-workaround.conf (only on OdroidM1 and RK356x)
       - ``/usr/lib32/libmali``, read-only
 - Any path defined in ``ld.so.conf`` and ``ld.so.conf.d/*.conf``, *.conf files indexed in alphabetical order. Indexed in ``ld.so.cache`` (fast)
   - gcc-lib32.conf
     - ``/usr/lib32``, read-only
   - pulseaudio.conf
     - ``/usr/lib32/pulseaudio``, read-only
     - ``/usr/lib/pulseaudio``, read-only
 - Built-in path. Indexed in ``ld.so.cache`` (fast)
   - ``/usr/lib``, read-only

If user wants to overwrite a certain library or provide additional libraries, they can achieve this in one of the following way:
 - Place it under ``/emuelec/lib32`` or ``/emuelec/lib``. **The libraries will be applied system-wide, not only for your user session(SSH/service)**
 - Place it anywhere else, and add the path to ``LD_LIBRARY_PATH``, this is suggested if the path is not indexed by ``ld.so.cache``, and you only want to use these libraries for a specific program/user session. Do note this is slow to lookup so don't add too many libraries.
 - **Do not add the paths that's already indexed by ``ld.so.cache`` to ``LD_LIBRARY_PATH``, unless you want to re-write the lookup order, as this will significantly slows down the lookup speed**
   - Bad practice: (most paths in the following ``LD_LIBRARY_PATH`` is already indexed by ``ld.so.cache`` and this just adds meaningless search time) ``LD_LIBRARY_PATH=/emuelec/lib32:/emuelec/lib:/usr/lib32/pulseaudio:/usr/lib/pulseaudio:/usr/lib32:/usr/lib``
## Daemons
The systemd unit ``ldconfig.service`` is what made it possible to drop ``LD_LIBRARY_PATH`` for the system-wide "static" libraries stored under ``/usr/lib`` and ``/usr/lib32`` (note it is still supported for out-of-tree paths like when you load ports, and the LD_LIBRARY_PATH is still used for ``/emuelec/libs``). 

The ``ldconfig.service`` will refresh ``ld.so.cache`` every time EmuELEC boots, you can also manually run it with ``systemctl restart ldconfig`` or ``ldconfig -vX`` to refresh the cache.


## Image layout
The following part is different from non-multilib images, if ``lib32-essential`` is installed
- ``/etc/``
  - ``ld.so.conf``
    ````
    include /etc/ld.so.conf.d/*.conf
    ````
  - ``ld.so.conf.d/``
    - ``lib32-glibc.conf``
      ````
      /usr/lib32
      ````
    - ``pulseaudio.conf``
      ````
      /usr/lib32/pulseaudio
      /usr/lib/pulseaudio
      ````
- ``/usr/``
  - ``bin/``
    - ``ldconfig`` The binary to create ld cache
  - ``lib/systemd/system``
    - ``ldconfig.service`` The systemd unit to rebuild ld cache on boot
- ``/storage/.cache/ld.so.cache`` Actual ld cache

The ``ld.so.conf`` and ``ld.so.conf.d`` are very similar to those you will find on standard Linux distros like ArchLinux, Debian, Ubuntu, etc, even they will have some differences. A Big difference is that we keep ``ld.so.cache`` at ``/storage/.cache/`` instead of ``/etc/`` since on EmuELEC ``/etc/`` is read-only.

## Package requirement
To add packages here, the following requirement must be met:
### Variables
***Variable scope***
 - Since the **lib32** flag is checked before setup_toolchian() and any package-specific functions are called, and after the package is read, outside of functions the variables ``TARGET_NAME``, ``SYSROOT_PREFIX``, etc will still be the same as generic 64, since ``use_32_options()`` is not called yet. 
   - Outside of functions, LIB32_ prefixed variables should be used to get 32bit target infos, and no prefix variables should be used to get 64bit target infos
   - Inside of functions, LIB64_ prefixed variables hould be used to get 64bit target infos, and no prefix/Lib32_ prefixed variables should be used to get 32bit target infos

**PKG_NAME**
 - Packages should use a **lib32-** prefixed name, even it will still work without, this will help to distinguish the package from other generic pacakges

**PKG_VERSION** 
- If the package has a corresponding generic version, the lib32 one must have the same version as the generic one, this can be set with ``PKG_VERSION=$(get_pkg_version generic-pkg)``
 - Otherwise, use the actual one.

**PKG_NEED_UNPACK**
- If the package relies on another package (e.g. it uses ``PKG_VERSION=$(get_pkg_version generic-pkg)``) then PKG_NEED_UNPACK must be set as well in order for it to update when doing dirty builds, this can be set with ``PKG_NEED_UNPACK="$(get_pkg_directory generic-pkg)``

**PKG_ARCH** 
 - The arch **must** be **aarch64**, to avoid building it in singlelib 32-bit builds.

**PKG_URL** 
 - If a corresponding generic package exists, then the package should **not** have its own source and URL should be **empty** (explicitly set it empty with ``PKG_URL=""``)
 - If so, it should use the **same source** as the generic version and a custom ``unpack()`` function should extract it from the corresponding generic package's source. This saves time and disk space.

**PKG_DEPENDS** 
 - ``lib32-toolchain`` must be depended on for target packages, other libraries, if lib32, should also be adapted, be careful of these special packages:
    - systemd -> lib32-systemd-libs (since we only build ``libudev.so`` and ``libsystemd.so``)
    - pulseaudio -> lib32-libpulse (since we only build libraries)
    - linux:host -> lib32-linux-headers (no host) (since we only install headers to toolchain)
    
    The corresponding generic package should be depended on if the lib32 version does not provide configs/binaries where the generic version would.

    E.g. lib32-retroarch depends on retroarch, as lib32-retroarch only provides binary ``/usr/bin/retroarch32`` and expects configs/libraries installed by retroarch.

**PKG_PATCH_DIRS** 
- At least ``$(get_pkg_directory generic-pkg)/patches`` should be added so the lib32 version can also be patched if the generic version is patched

**PKG_BUILD_FLAGS** 
- Unless it's a bootstrap package, the ``lib32`` or ``lib32:[target]`` flag must be set in ``PKG_BUILD_FLAGS``. Usually install-only packages don't need this flag, such as ``lib32-nold``, ``lib32-ldconfig``, etc

### Functions
**unpack()** 
- Unless there's no corresponding generic version, the lib32-pkg should extract source from the generic version with a custom function like this:    
  Archive
  ````
  unpack() {
    ${SCRIPTS}/get generic-pkg
    mkdir -p ${PKG_BUILD}
    tar --strip-components=1 -xf ${SOURCES}/generic-pkg/generic-pkg-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
  }
  ````
  Git
  ````
  unpack() {
    ${SCRIPTS}/get generic-pkg
    mkdir -p ${PKG_BUILD}
    tar cf - -C ${SOURCES}/generic-pkg/generic-pkg-${PKG_VERSION} ${PKG_TAR_COPY_OPTS} . | tar xf - -C ${PKG_BUILD}
  }
  ````
  The reason we don't use ``{SCRIPTS}/unpack generic-pkg ${PKG_BUILD}`` is that it will also apply patches from generic-pkg, which is not always what we want, and this may introduce recursive patches. And I want to keep the changes made to the build system as minumum as possible.

**makeinstall_target()** 
- Since we use ``/usr/lib32`` as actual multilib path, manual tweaks are needed when installing the package
- For SYSROOT installation, libraries still go to ``/usr/lib``, this is for the ease of toolchain lookup

- For target image installation, libraries should go to ``/usr/lib32``. If this is not possible, then it can still go to ``/usr/lib``, and you can mv it to ``/usr/lib32`` in ``post_makeinstall_target()``. The exception is 32bit libretro cores, they should go to ``/usr/lib/libretro``, with **32b** in their name

**post_makeinstall_target()** 
- For most packages, since we only need the libraries, everything outside of ``/usr/lib``(if makeinstall_target() can't be manipulated) or ``/usr/lib32`` (if makeinstall_target() can be manipulated) should be removed, these remove should be done with ``safe_remove``, and then ``/usr/lib`` should be moved to ``/usr/lib32`` if needed

## Structure
All pacakges under this folder should have the similiar parent folders as the outer packages folder, especially the same as their corresponding universal pacakge, these are the examples:
  - toolchain (virual/toolchain) => lib32-toolchain (lib32/virtual/toolchain)
  - gcc (lang) => lib32-gcc (lib32/lang/lib32-gcc)
  - box86 (sx05re/emulators/box86) => lib32-box86 (lib32/sx05re/emulators/lib32-box86)

But there's still exceptions that're allowed here:
 - If its corresponding generic version is placed deeply in ``sx05re``, it can be moved to to ``emuelec``, or other corresponding greater types. For the ease of looking up. E.g.
   - ``sx05re/tools/SDL2/SDL2_mixer`` => ``lib32/audio/lib32-SDL2_mixer``
   - ``sx05re/libretro/mupen64plus`` => ``lib32/emuelec/libretro/lib32-mupen64plus``
 - If it's a project/device-specific package, it can be moved to meaningful greater types. E.g.
   - ``projects/Amlogic-ce/devices/Amlogic-ng/packages/opengl-meson`` => ``lib32/graphics/lib32-opengl-meson``. Note this package also combines the ``opengl-meson`` from ``Amlogic-old`` device
   - ``projects/Rockchip/packages/libgo2`` => ``lib32/sysutils/lib32-libgo2``

## Contribution
When copying/moving existing packages under this package, you should use either of the following command to keep the commit history:
  - ``git mv parent/package lib32/parent/lib32-package``
  - ``git cp parent/package lib32/parent/lib32-package`` (provided by git-extras, although it seems broken for me)

In the header, please keep the older contributors and then add your name like the others

# Port to other projects
## Dependency

If you just copy/paste these packages to other projects blindly, **they won't build!!!** They'll most likely corrupt your build folder and toolchain which can only be rescued by ``make clean``

These packages will only work with a build system that recognizes the PKG_BUILD_FLAGS ``lib32`` and/or ``lib32:[target]``, if you come from other distros and want to port these packages, the following part in the build system must also be ported, i.e. these are also what made it possible to build them in EmuELEC itself:
- ``config/options32`` adds a series of ``LIB32_`` and ``LIB64_`` prefixed variables
- ``config/options`` adds a check to invoke ``config/options32`` for ``aarch64`` build
- ``config/functions`` adds a function ``use_32_options()`` to replace key variables to 32-bit versions
- ``scripts/build`` adds a check before ``setup_toolchain()`` that'll call ``use_32_options()`` if a flag ``lib32`` or ``lib32:[target]`` is detected
- ``scripts/install`` adds two more folders to exclude when installing packages (not essential)
- ``glibc`` should be patched to use ``/storage/.cache/ld.so.cache`` instead of ``/etc/ld.so.cache`` for ``LD_SO_CACHE``

Additionally, these changes expect a build system that has the changes introduced in [the PR](https://github.com/LibreELEC/LibreELEC.tv/pull/4042) that's merged in upstream LibreELEC in 2019, and EmuELEC's build system didn't have these changes until Oct, 2021. I haven't tested if this will work with an older build system, so you should pay attention if you want to make these changes work in your project's build system.
