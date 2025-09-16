# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="linux"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kernel.org"
PKG_DEPENDS_HOST="ccache:host rsync:host openssl:host"
PKG_DEPENDS_TARGET="toolchain linux:host kmod:host xz:host keyutils aml-dtbtools:host aml-dtbtools $KERNEL_EXTRA_DEPENDS_TARGET"
PKG_NEED_UNPACK="$LINUX_DEPENDS $(get_pkg_directory initramfs) $(get_pkg_variable initramfs PKG_NEED_UNPACK)"
PKG_LONGDESC="This package contains a precompiled kernel image and the modules."
PKG_IS_KERNEL_PKG="yes"
PKG_STAMP="$KERNEL_TARGET $KERNEL_MAKE_EXTRACMD $KERNEL_UBOOT_EXTRA_TARGET"

PKG_PATCH_DIRS="$LINUX"

case "$LINUX" in
  amlogic-3.14)
    PKG_VERSION="07d26b4ce91cf934d65a64e2da7ab3bc75e59fcc"
    PKG_SHA256="682f93c0bb8ad888a681e93882bc169007bacb880714b980af00ca34fb5b8365"
    PKG_URL="https://github.com/CoreELEC/linux-amlogic/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET aml-dtbtools:host"
    PKG_BUILD_PERF="no"
    ;;
  amlogic-4.9)
    PKG_VERSION="ab03043a776354e02be86d06007751f652680c00"
    PKG_SHA256="c75bbd36d0dc92b21d75ce82dd8e0a4fefac9cf4b62f5d21c33eb7d12ca5bc2a"
    PKG_URL="https://github.com/CoreELEC/linux-amlogic/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET aml-dtbtools:host"
    PKG_BUILD_PERF="no"
    PKG_GIT_BRANCH="amlogic-4.9-20"
    ;;
esac

PKG_KERNEL_CFG_FILE=$(kernel_config_path) || die

if [ -n "$KERNEL_TOOLCHAIN" ]; then
  PKG_DEPENDS_HOST="$PKG_DEPENDS_HOST gcc-$KERNEL_TOOLCHAIN:host"
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET gcc-$KERNEL_TOOLCHAIN:host"
  HEADERS_ARCH=$TARGET_ARCH
fi

if [ "$PKG_BUILD_PERF" != "no" ] && grep -q ^CONFIG_PERF_EVENTS= $PKG_KERNEL_CFG_FILE ; then
  PKG_BUILD_PERF="yes"
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET binutils elfutils libunwind zlib openssl"
fi

if [ "$TARGET_ARCH" = "x86_64" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET elfutils:host"
  PKG_DEPENDS_UNPACK+=" intel-ucode kernel-firmware"
fi

if [[ "$KERNEL_TARGET" = uImage* ]]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET u-boot-tools:host"
fi

if [ "$BUILD_ANDROID_BOOTIMG" = "yes" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET mkbootimg:host"
fi

# Ensure that the dependencies of initramfs:target are built correctly, but
# we don't want to add initramfs:target as a direct dependency as we install
# this "manually" from within linux:target
for pkg in $(get_pkg_variable initramfs PKG_DEPENDS_TARGET); do
  ! listcontains "${PKG_DEPENDS_TARGET}" "${pkg}" && PKG_DEPENDS_TARGET+=" ${pkg}" || true
done

post_patch() {
  # linux was already built and its build dir autoremoved - prepare it again for kernel packages
  if [ -d $PKG_INSTALL/.image ]; then
    cp -p $PKG_INSTALL/.image/.config $PKG_BUILD
    kernel_make -C $PKG_BUILD prepare

    # restore the required Module.symvers from an earlier build
    cp -p $PKG_INSTALL/.image/Module.symvers $PKG_BUILD
  else
    cp $PKG_KERNEL_CFG_FILE $PKG_BUILD/.config

    sed -i -e "s|@INITRAMFS_SOURCE@|$(kernel_initramfs_confs) $BUILD/initramfs|" $PKG_BUILD/.config

    # set default hostname based on $DISTRONAME
      sed -i -e "s|@DISTRONAME@|$DISTRONAME|g" $PKG_BUILD/.config

    # disable swap support if not enabled
    if [ ! "$SWAP_SUPPORT" = yes ]; then
      sed -i -e "s|^CONFIG_SWAP=.*$|# CONFIG_SWAP is not set|" $PKG_BUILD/.config
    fi

    # disable nfs support if not enabled
    if [ ! "$NFS_SUPPORT" = yes ]; then
      sed -i -e "s|^CONFIG_NFS_FS=.*$|# CONFIG_NFS_FS is not set|" $PKG_BUILD/.config
    fi

    # disable cifs support if not enabled
    if [ ! "$SAMBA_SUPPORT" = yes ]; then
      sed -i -e "s|^CONFIG_CIFS=.*$|# CONFIG_CIFS is not set|" $PKG_BUILD/.config
    fi

    # disable iscsi support if not enabled
    if [ ! "$ISCSI_SUPPORT" = yes ]; then
      sed -i -e "s|^CONFIG_SCSI_ISCSI_ATTRS=.*$|# CONFIG_SCSI_ISCSI_ATTRS is not set|" $PKG_BUILD/.config
      sed -i -e "s|^CONFIG_ISCSI_TCP=.*$|# CONFIG_ISCSI_TCP is not set|" $PKG_BUILD/.config
      sed -i -e "s|^CONFIG_ISCSI_BOOT_SYSFS=.*$|# CONFIG_ISCSI_BOOT_SYSFS is not set|" $PKG_BUILD/.config
      sed -i -e "s|^CONFIG_ISCSI_IBFT_FIND=.*$|# CONFIG_ISCSI_IBFT_FIND is not set|" $PKG_BUILD/.config
      sed -i -e "s|^CONFIG_ISCSI_IBFT=.*$|# CONFIG_ISCSI_IBFT is not set|" $PKG_BUILD/.config
    fi

    # disable lima/panfrost if libmali is configured
    if [ "$OPENGLES" = "libmali" ]; then
      sed -e "s|^CONFIG_DRM_LIMA=.*$|# CONFIG_DRM_LIMA is not set|" -i $PKG_BUILD/.config
      sed -e "s|^CONFIG_DRM_PANFROST=.*$|# CONFIG_DRM_PANFROST is not set|" -i $PKG_BUILD/.config
    fi

    # disable wireguard support if not enabled
    if [ ! "$WIREGUARD_SUPPORT" = yes ]; then
      sed -e "s|^CONFIG_WIREGUARD=.*$|# CONFIG_WIREGUARD is not set|" -i $PKG_BUILD/.config
    fi
  fi
}

post_unpack() {
  # Add exFAT
  ${SCRIPTS}/get exfat-linux
  local PKG_BUILD_EXFAT="${PKG_BUILD}/fs/exfat"
  [ -e "$PKG_BUILD_EXFAT" ] && rm -rf "$PKG_BUILD_EXFAT"
  mkdir -p "$PKG_BUILD_EXFAT"
  tar --strip-components=1 -xf "${SOURCES}/exfat-linux/exfat-linux-$(get_pkg_version exfat-linux).tar.gz" -C "$PKG_BUILD_EXFAT"
}

make_host() {
  make \
    ARCH=${HEADERS_ARCH:-$TARGET_KERNEL_ARCH} \
    HOSTCC="$TOOLCHAIN/bin/host-gcc" \
    HOSTCXX="$TOOLCHAIN/bin/host-g++" \
    HOSTCFLAGS="$HOST_CFLAGS" \
    HOSTCXXFLAGS="$HOST_CXXFLAGS" \
    HOSTLDFLAGS="$HOST_LDFLAGS" \
    headers_check
}

makeinstall_host() {
  make \
    ARCH=${HEADERS_ARCH:-$TARGET_KERNEL_ARCH} \
    HOSTCC="$TOOLCHAIN/bin/host-gcc" \
    HOSTCXX="$TOOLCHAIN/bin/host-g++" \
    HOSTCFLAGS="$HOST_CFLAGS" \
    HOSTCXXFLAGS="$HOST_CXXFLAGS" \
    HOSTLDFLAGS="$HOST_LDFLAGS" \
    INSTALL_HDR_PATH=dest \
    headers_install
  mkdir -p $SYSROOT_PREFIX/usr/include
    cp -R dest/include/* $SYSROOT_PREFIX/usr/include
}

pre_make_target() {
  pkg_lock_status "ACTIVE" "linux:target" "build"

  if [ "$TARGET_ARCH" = "x86_64" ]; then
    # copy some extra firmware to linux tree
    mkdir -p $PKG_BUILD/external-firmware
      cp -a $(get_build_dir kernel-firmware)/.copied-firmware/{amdgpu,amd-ucode,i915,radeon,e100,rtl_nic} $PKG_BUILD/external-firmware

    cp -a $(get_build_dir intel-ucode)/intel-ucode $PKG_BUILD/external-firmware

    FW_LIST="$(find $PKG_BUILD/external-firmware \( -type f -o -type l \) \( -iname '*.bin' -o -iname '*.fw' -o -path '*/intel-ucode/*' \) | sed 's|.*external-firmware/||' | sort | xargs)"
    sed -i "s|CONFIG_EXTRA_FIRMWARE=.*|CONFIG_EXTRA_FIRMWARE=\"${FW_LIST}\"|" $PKG_BUILD/.config
  fi

  kernel_make oldconfig
}

make_target() {
  # arm64 target does not support creating uImage.
  # Build Image first, then wrap it using u-boot's mkimage.
  if [[ "$TARGET_KERNEL_ARCH" = "arm64" && "$KERNEL_TARGET" = uImage* ]]; then
    if [ -z "$KERNEL_UIMAGE_LOADADDR" -o -z "$KERNEL_UIMAGE_ENTRYADDR" ]; then
      die "ERROR: KERNEL_UIMAGE_LOADADDR and KERNEL_UIMAGE_ENTRYADDR have to be set to build uImage - aborting"
    fi
    KERNEL_UIMAGE_TARGET="$KERNEL_TARGET"
    KERNEL_TARGET="${KERNEL_TARGET/uImage/Image}"
  fi

  kernel_make modules
  kernel_make INSTALL_MOD_PATH=$INSTALL/$(get_kernel_overlay_dir) modules_install
  rm -f $INSTALL/$(get_kernel_overlay_dir)/lib/modules/*/build
  rm -f $INSTALL/$(get_kernel_overlay_dir)/lib/modules/*/source

  rm -rf $BUILD/initramfs
  rm -f ${STAMPS_INSTALL}/initramfs/install_target ${STAMPS_INSTALL}/*/install_init

  if [ -n "$INITRAMFS_MODULES" ]; then
    mkdir -p $BUILD/initramfs/etc
    mkdir -p $BUILD/initramfs/usr/lib/modules

    for i in $INITRAMFS_MODULES; do
      module=$(find $INSTALL/$(get_full_module_dir)/kernel -name $i.ko)
      if [ -n "$module" ]; then
        echo $i >> $BUILD/initramfs/etc/modules
        cp $module $BUILD/initramfs/usr/lib/modules
      fi
    done
  fi

  # create initramfs.cpio needed by Android boot image
  (
    cd $ROOT
    $SCRIPTS/install initramfs
  )

  # the modules target is required to get a proper Module.symvers
  # file with symbols from built-in and external modules.
  # Without that it'll contain only the symbols from the kernel
  kernel_make $KERNEL_TARGET $KERNEL_MAKE_EXTRACMD modules

  # collect all device tree in 'coreelec' subfolders
  DTB_PATH="arch/$TARGET_KERNEL_ARCH/boot/dts/amlogic"
  cp ${DTB_PATH}/coreelec-*/*.dtb $DTB_PATH 2>/dev/null || :

  # combine Amlogic multidtb by dtb.conf
  find_file_path bootloader/dtb.conf
  MULTIDTB_CONF="${FOUND_PATH}"
  if [ -f $MULTIDTB_CONF ]; then
    multidtb_cnt=$(xmlstarlet sel -t -c "count(//dtb/multidtb)" $MULTIDTB_CONF)
    cnt_m=1
    while [ $cnt_m -le $multidtb_cnt ]; do
      multidtb=$(xmlstarlet sel -t -v "//dtb/multidtb[$cnt_m]/@name" $MULTIDTB_CONF)
      echo
      echo "Making multidtb $multidtb"
      rm -fr "$DTB_PATH/dtbtool_input"
      mkdir $DTB_PATH/dtbtool_input

      files_cnt=$(xmlstarlet sel -t -c "count(//dtb/multidtb[$cnt_m]/file)" $MULTIDTB_CONF)
      cnt_f=1
      while [ $cnt_f -le $files_cnt ]; do
        file=$(xmlstarlet sel -t -v "//dtb/multidtb[$cnt_m]/file[$cnt_f]" $MULTIDTB_CONF)
        cnt_f=$((cnt_f+1))
        mv $DTB_PATH/$file $DTB_PATH/dtbtool_input
      done

      dtbTool -c -o $DTB_PATH/$multidtb $DTB_PATH/dtbtool_input
      rm -fr "$DTB_PATH/dtbtool_input"
      cnt_m=$((cnt_m+1))
    done
    mkdir -p $INSTALL/usr/share/bootloader
    install -m 0644 $MULTIDTB_CONF $INSTALL/usr/share/bootloader
  fi

  if [ "$BUILD_ANDROID_BOOTIMG" = "yes" ]; then
    find_file_path bootloader/mkbootimg && source ${FOUND_PATH}
    mv -f arch/$TARGET_KERNEL_ARCH/boot/boot.img arch/$TARGET_KERNEL_ARCH/boot/$KERNEL_TARGET
  fi

  if [ "$PKG_BUILD_PERF" = "yes" ] ; then
    ( cd tools/perf

      # arch specific perf build args
      case "$TARGET_ARCH" in
        x86_64)
          PERF_BUILD_ARGS="ARCH=x86"
          ;;
        aarch64)
          PERF_BUILD_ARGS="ARCH=arm64"
          ;;
        *)
          PERF_BUILD_ARGS="ARCH=$TARGET_ARCH"
          ;;
      esac

      WERROR=0 \
      NO_LIBPERL=1 \
      NO_LIBPYTHON=1 \
      NO_SLANG=1 \
      NO_GTK2=1 \
      NO_LIBNUMA=1 \
      NO_LIBAUDIT=1 \
      NO_LZMA=1 \
      NO_SDT=1 \
      CROSS_COMPILE="$TARGET_PREFIX" \
      JOBS="$CONCURRENCY_MAKE_LEVEL" \
        make $PERF_BUILD_ARGS
      mkdir -p $INSTALL/usr/bin
        cp perf $INSTALL/usr/bin
    )
  fi

  if [ -n "$KERNEL_UIMAGE_TARGET" ] ; then
    # determine compression used for kernel image
    KERNEL_UIMAGE_COMP=${KERNEL_UIMAGE_TARGET:7}
    KERNEL_UIMAGE_COMP=$(echo ${KERNEL_UIMAGE_COMP:-none} | sed 's/gz/gzip/; s/bz2/bzip2/')

    # calculate new load address to make kernel Image unpack to memory area after compressed image
    if [ "$KERNEL_UIMAGE_COMP" != "none" ] ; then
      COMPRESSED_SIZE=$(stat -t "arch/$TARGET_KERNEL_ARCH/boot/$KERNEL_TARGET" | awk '{print $2}')
      # align to 1 MiB
      COMPRESSED_SIZE=$(( (($COMPRESSED_SIZE - 1 >> 20) + 1) << 20 ))
      PKG_KERNEL_UIMAGE_LOADADDR=$(printf '%X' "$(( $KERNEL_UIMAGE_LOADADDR + $COMPRESSED_SIZE ))")
      PKG_KERNEL_UIMAGE_ENTRYADDR=$(printf '%X' "$(( $KERNEL_UIMAGE_ENTRYADDR + $COMPRESSED_SIZE ))")
    else
      PKG_KERNEL_UIMAGE_LOADADDR=${KERNEL_UIMAGE_LOADADDR}
      PKG_KERNEL_UIMAGE_ENTRYADDR=${KERNEL_UIMAGE_ENTRYADDR}
    fi

    mkimage -A $TARGET_KERNEL_ARCH \
            -O linux \
            -T kernel \
            -C $KERNEL_UIMAGE_COMP \
            -a $PKG_KERNEL_UIMAGE_LOADADDR \
            -e $PKG_KERNEL_UIMAGE_ENTRYADDR \
            -d arch/$TARGET_KERNEL_ARCH/boot/$KERNEL_TARGET \
               arch/$TARGET_KERNEL_ARCH/boot/$KERNEL_UIMAGE_TARGET

    KERNEL_TARGET="${KERNEL_UIMAGE_TARGET}"
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/.image
  cp -p arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET} System.map .config Module.symvers $INSTALL/.image/

  if [ "$BOOTLOADER" = "u-boot" ]; then
    mkdir -p $INSTALL/usr/share/bootloader/device_trees
    if [ -d arch/$TARGET_KERNEL_ARCH/boot/dts/amlogic ]; then
      cp arch/$TARGET_KERNEL_ARCH/boot/*dtb.img $INSTALL/usr/share/bootloader/ 2>/dev/null || :
      cp arch/$TARGET_KERNEL_ARCH/boot/dts/amlogic/*.dtb $INSTALL/usr/share/bootloader/device_trees 2>/dev/null || :
    fi
  elif [ "$BOOTLOADER" = "bcm2835-bootloader" ]; then
    mkdir -p $INSTALL/usr/share/bootloader/overlays

    # install platform dtbs, but remove upstream kernel dtbs (i.e. without downstream
    # drivers and decent USB support) as these are not required by LibreELEC
    cp -p arch/$TARGET_KERNEL_ARCH/boot/dts/*.dtb $INSTALL/usr/share/bootloader
    rm -f $INSTALL/usr/share/bootloader/bcm283*.dtb

    # install overlay dtbs
    for dtb in arch/$TARGET_KERNEL_ARCH/boot/dts/overlays/*.dtb \
               arch/$TARGET_KERNEL_ARCH/boot/dts/overlays/*.dtbo; do
      cp $dtb $INSTALL/usr/share/bootloader/overlays 2>/dev/null || :
    done
    cp -p arch/$TARGET_KERNEL_ARCH/boot/dts/overlays/README $INSTALL/usr/share/bootloader/overlays
  fi
}
