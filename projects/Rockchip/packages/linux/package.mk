# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="linux"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kernel.org"
PKG_DEPENDS_HOST="ccache:host rsync:host openssl:host"
PKG_DEPENDS_TARGET="toolchain linux:host kmod:host xz:host keyutils ${KERNEL_EXTRA_DEPENDS_TARGET}"
PKG_NEED_UNPACK="${LINUX_DEPENDS} $(get_pkg_directory initramfs) $(get_pkg_variable initramfs PKG_NEED_UNPACK)"
PKG_LONGDESC="This package contains a precompiled kernel image and the modules."
PKG_IS_KERNEL_PKG="yes"
PKG_STAMP="${KERNEL_TARGET} ${KERNEL_MAKE_EXTRACMD}"

PKG_PATCH_DIRS="${LINUX}"

case "$LINUX" in
  rockchip-4.4)
    PKG_VERSION="aa8bacf821e5c8ae6dd8cae8d64011c741659945"
    PKG_SHA256="a2760fe89a15aa7be142fd25fb08ebd357c5d855c41f1612cf47c6e89de39bb3"
    PKG_URL="https://github.com/rockchip-linux/kernel/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    ;;
  rk356x-4.19)
    PKG_VERSION="c0c173e0214eeaa0d057599d2f1c6a83213483b1"
    PKG_SHA256="d748bc0f272373ed219a9bfd242566871dafd0437f88d0212780b8469ea89e5e"
    PKG_URL="https://gitlab.com/firefly-linux/kernel/-/archive/$PKG_VERSION/kernel-$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    PKG_PATCH_DIRS="RK356x"
    ;;
  OdroidM1-4.19)
    PKG_VERSION="e45b118834e1395eeacbed77e8b8f35e8105663e"
    PKG_SHA256="3c4f1bea0b8c26d9951c8b46c6c93127fc0929ff9947c5eb8e479fbaf05fa1f4"
    PKG_URL="https://github.com/hardkernel/linux/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    PKG_PATCH_DIRS="RK356x"
    ;;
  odroid-go-a-4.4)
    PKG_VERSION="faeb665a41b53ebb386e69fe737ccf0707aaf07b"
    PKG_SHA256="bef15386f296b282e1e75ed78f14c7c0762058806da37854d09af642a15594ae"
    PKG_URL="https://github.com/hardkernel/linux/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    PKG_PATCH_DIRS="OdroidGoAdvance base"
    ;;
  gameforce-4.4)
    PKG_VERSION="8eddb294dcb1a1b0cf63bdf04ea5cdc41a9bd601"
    PKG_SHA256="ad2f6fee44dfb19c8a43722ca02601f6742af39129f0c79c990ed582709f63cf"
    PKG_URL="https://github.com/shantigilbert/hardkernel-linux/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    PKG_PATCH_DIRS="GameForce base"
    ;;
  raspberrypi)
    PKG_VERSION="3c235dcfe80a7c7ba360219e4a3ecb256f294376" # 4.19.83
    PKG_SHA256="23a222d8864107b296b3bf580106421899964af879bb7f1c440e875e565fd6f3"
    PKG_URL="https://github.com/raspberrypi/linux/archive/$PKG_VERSION.tar.gz"
    PKG_SOURCE_NAME="linux-$LINUX-$PKG_VERSION.tar.gz"
    ;;
  *)
    PKG_VERSION="5.1.16"
    PKG_SHA256="8a3e55be3e788700836db6f75875b4d3b824a581d1eacfc2fcd29ed4e727ba3e"
    PKG_URL="https://www.kernel.org/pub/linux/kernel/v5.x/$PKG_NAME-$PKG_VERSION.tar.xz"
    PKG_PATCH_DIRS="default"
    ;;
esac

PKG_KERNEL_CFG_FILE=$(kernel_config_path) || die

if [ -n "${KERNEL_TOOLCHAIN}" ]; then
  PKG_DEPENDS_HOST+=" gcc-${KERNEL_TOOLCHAIN}:host"
  PKG_DEPENDS_TARGET+=" gcc-${KERNEL_TOOLCHAIN}:host"
  HEADERS_ARCH=${TARGET_ARCH}
fi

if [ "${PKG_BUILD_PERF}" != "no" ] && grep -q ^CONFIG_PERF_EVENTS= ${PKG_KERNEL_CFG_FILE}; then
  PKG_BUILD_PERF="yes"
  PKG_DEPENDS_TARGET+=" binutils elfutils libunwind zlib openssl"
fi

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" elfutils:host pciutils"
  PKG_DEPENDS_UNPACK+=" intel-ucode kernel-firmware"
elif [ "${TARGET_ARCH}" = "arm" -a "${DEVICE}" = "iMX6" ]; then
  PKG_DEPENDS_UNPACK+=" firmware-imx"
fi

if [[ "${KERNEL_TARGET}" = uImage* ]]; then
  PKG_DEPENDS_TARGET+=" u-boot-tools:host"
fi

# Ensure that the dependencies of initramfs:target are built correctly, but
# we don't want to add initramfs:target as a direct dependency as we install
# this "manually" from within linux:target
for pkg in $(get_pkg_variable initramfs PKG_DEPENDS_TARGET); do
  ! listcontains "${PKG_DEPENDS_TARGET}" "${pkg}" && PKG_DEPENDS_TARGET+=" ${pkg}" || true
done

post_patch() {
  # linux was already built and its build dir autoremoved - prepare it again for kernel packages
  if [ -d ${PKG_INSTALL}/.image ]; then
    cp -p ${PKG_INSTALL}/.image/.config ${PKG_BUILD}
    kernel_make -C ${PKG_BUILD} prepare

    # restore the required Module.symvers from an earlier build
    cp -p ${PKG_INSTALL}/.image/Module.symvers ${PKG_BUILD}
  fi
}

post_unpack() {
  # Add exFAT
  ${SCRIPTS}/get exfat-linux
  local PKG_BUILD_EXFAT="${PKG_BUILD}/fs/exfat"
  [ -e "$PKG_BUILD_EXFAT" ] && rm -rf "$PKG_BUILD_EXFAT"
  mkdir -p "$PKG_BUILD_EXFAT"
  tar --strip-components=1 -xf "${SOURCES}/exfat-linux/exfat-linux-$(get_pkg_version exfat-linux).tar.gz" -C "$PKG_BUILD_EXFAT"
  sed -i '/source "fs\/fat\/Kconfig"/a source "fs\/exfat\/Kconfig"' "${PKG_BUILD}/fs/Kconfig"
  sed -i '/obj-$(CONFIG_FAT_FS).*+= fat\//a obj-$(CONFIG_EXFAT_FS)\t\t+= exfat\/' "${PKG_BUILD}/fs/Makefile"
}

make_host() {
  :
}

makeinstall_host() {
  make \
    ARCH=${HEADERS_ARCH:-${TARGET_KERNEL_ARCH}} \
    HOSTCC="${TOOLCHAIN}/bin/host-gcc" \
    HOSTCXX="${TOOLCHAIN}/bin/host-g++" \
    HOSTCFLAGS="${HOST_CFLAGS}" \
    HOSTCXXFLAGS="${HOST_CXXFLAGS}" \
    HOSTLDFLAGS="${HOST_LDFLAGS}" \
    INSTALL_HDR_PATH=dest \
    headers_install
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp -R dest/include/* ${SYSROOT_PREFIX}/usr/include
}

pre_make_target() {
  ( cd ${ROOT}
    rm -rf ${BUILD}/initramfs
    rm -f ${STAMPS_INSTALL}/initramfs/install_target ${STAMPS_INSTALL}/*/install_init
    ${SCRIPTS}/install initramfs
  )
  pkg_lock_status "ACTIVE" "linux:target" "build"

  cp ${PKG_KERNEL_CFG_FILE} ${PKG_BUILD}/.config

  # set initramfs source
  ${PKG_BUILD}/scripts/config --set-str CONFIG_INITRAMFS_SOURCE "$(kernel_initramfs_confs) ${BUILD}/initramfs"

  # set default hostname based on ${DISTRONAME}
  ${PKG_BUILD}/scripts/config --set-str CONFIG_DEFAULT_HOSTNAME "${DISTRONAME}"

  # disable swap support if not enabled
  if [ ! "${SWAP_SUPPORT}" = yes ]; then
    ${PKG_BUILD}/scripts/config --disable CONFIG_SWAP
  fi

  # disable nfs support if not enabled
  if [ ! "${NFS_SUPPORT}" = yes ]; then
    ${PKG_BUILD}/scripts/config --disable CONFIG_NFS_FS
  fi

  # disable cifs support if not enabled
  if [ ! "${SAMBA_SUPPORT}" = yes ]; then
    ${PKG_BUILD}/scripts/config --disable CONFIG_CIFS
  fi

  # disable iscsi support if not enabled
  if [ ! "${ISCSI_SUPPORT}" = yes ]; then
    ${PKG_BUILD}/scripts/config --disable CONFIG_SCSI_ISCSI_ATTRS
    ${PKG_BUILD}/scripts/config --disable CONFIG_ISCSI_TCP
    ${PKG_BUILD}/scripts/config --disable CONFIG_ISCSI_BOOT_SYSFS
    ${PKG_BUILD}/scripts/config --disable CONFIG_ISCSI_IBFT_FIND
    ${PKG_BUILD}/scripts/config --disable CONFIG_ISCSI_IBFT
  fi

  # disable lima/panfrost if libmali is configured
  if [ "${OPENGLES}" = "libmali" ]; then
    ${PKG_BUILD}/scripts/config --disable CONFIG_DRM_LIMA
    ${PKG_BUILD}/scripts/config --disable CONFIG_DRM_PANFROST
  fi

  # disable wireguard support if not enabled
  if [ ! "${WIREGUARD_SUPPORT}" = yes ]; then
    ${PKG_BUILD}/scripts/config --disable CONFIG_WIREGUARD
  fi

  if [ "${TARGET_ARCH}" = "x86_64" ]; then
    # copy some extra firmware to linux tree
    mkdir -p ${PKG_BUILD}/external-firmware
      cp -a $(get_build_dir kernel-firmware)/.copied-firmware/{amdgpu,amd-ucode,i915,radeon,e100,rtl_nic} ${PKG_BUILD}/external-firmware

    cp -a $(get_build_dir intel-ucode)/intel-ucode ${PKG_BUILD}/external-firmware

    FW_LIST="$(find ${PKG_BUILD}/external-firmware \( -type f -o -type l \) \( -iname '*.bin' -o -iname '*.fw' -o -path '*/intel-ucode/*' \) | sed 's|.*external-firmware/||' | sort | xargs)"

    ${PKG_BUILD}/scripts/config --set-str CONFIG_EXTRA_FIRMWARE "${FW_LIST}"
    ${PKG_BUILD}/scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR "external-firmware"

  elif [ "${TARGET_ARCH}" = "arm" -a "${DEVICE}" = "iMX6" ]; then
    mkdir -p ${PKG_BUILD}/external-firmware/imx/sdma
      cp -a $(get_build_dir firmware-imx)/firmware/sdma/*imx6*.bin ${PKG_BUILD}/external-firmware/imx/sdma
      cp -a $(get_build_dir firmware-imx)/firmware/vpu/*imx6*.bin ${PKG_BUILD}/external-firmware

    FW_LIST="$(find ${PKG_BUILD}/external-firmware -type f | sed 's|.*external-firmware/||' | sort | xargs)"

    ${PKG_BUILD}/scripts/config --set-str CONFIG_EXTRA_FIRMWARE "${FW_LIST}"
    ${PKG_BUILD}/scripts/config --set-str CONFIG_EXTRA_FIRMWARE_DIR "external-firmware"
  fi
  
  kernel_make oldconfig

  if [ -f "${DISTRO_DIR}/${DISTRO}/kernel_options" ]; then
    while read OPTION; do
      [ -z "${OPTION}" -o -n "$(echo "${OPTION}" | grep '^#')" ] && continue

      if [ "${OPTION##*=}" == "n" -a "$(${PKG_BUILD}/scripts/config --state ${OPTION%%=*})" == "undef" ]; then
        continue
      fi

      if [ "$(${PKG_BUILD}/scripts/config --state ${OPTION%%=*})" != "$(echo ${OPTION##*=} | tr -d '"')" ]; then
        MISSING_KERNEL_OPTIONS+="\t${OPTION}\n"
      fi
    done < ${DISTRO_DIR}/${DISTRO}/kernel_options

    if [ -n "${MISSING_KERNEL_OPTIONS}" ]; then
      print_color CLR_WARNING "LINUX: kernel options not correct: \n${MISSING_KERNEL_OPTIONS%%}\nPlease run ./tools/check_kernel_config\n"
    fi
  fi
}

make_target() {

export KCFLAGS="-Wno-deprecated-declarations -Wno-stringop-overflow -Wno-array-bounds -Wno-misleading-indentation -Wno-array-compare -Wno-address -Wno-dangling-pointer -Wno-stringop-overread"

  # arm64 target does not support creating uImage.
  # Build Image first, then wrap it using u-boot's mkimage.
  if [[ "${TARGET_KERNEL_ARCH}" = "arm64" && "${KERNEL_TARGET}" = uImage* ]]; then
    if [ -z "${KERNEL_UIMAGE_LOADADDR}" -o -z "${KERNEL_UIMAGE_ENTRYADDR}" ]; then
      die "ERROR: KERNEL_UIMAGE_LOADADDR and KERNEL_UIMAGE_ENTRYADDR have to be set to build uImage - aborting"
    fi
    KERNEL_UIMAGE_TARGET="${KERNEL_TARGET}"
    KERNEL_TARGET="${KERNEL_TARGET/uImage/Image}"
  fi

  DTC_FLAGS=-@ kernel_make ${KERNEL_TARGET} ${KERNEL_MAKE_EXTRACMD} modules

  if [ "${PKG_BUILD_PERF}" = "yes" ]; then
    ( cd tools/perf

      # arch specific perf build args
      case "${TARGET_ARCH}" in
        x86_64)
          PERF_BUILD_ARGS="ARCH=x86"
          ;;
        aarch64)
          PERF_BUILD_ARGS="ARCH=arm64"
          ;;
        *)
          PERF_BUILD_ARGS="ARCH=${TARGET_ARCH}"
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
      CROSS_COMPILE="${TARGET_PREFIX}" \
      JOBS="${CONCURRENCY_MAKE_LEVEL}" \
        make ${PERF_BUILD_ARGS}
      mkdir -p ${INSTALL}/usr/bin
        cp perf ${INSTALL}/usr/bin
    )
  fi

  if [ -n "${KERNEL_UIMAGE_TARGET}" ]; then
    # determine compression used for kernel image
    KERNEL_UIMAGE_COMP=${KERNEL_UIMAGE_TARGET:7}
    KERNEL_UIMAGE_COMP=$(echo ${KERNEL_UIMAGE_COMP:-none} | sed 's/gz/gzip/; s/bz2/bzip2/')

    # calculate new load address to make kernel Image unpack to memory area after compressed image
    if [ "${KERNEL_UIMAGE_COMP}" != "none" ]; then
      COMPRESSED_SIZE=$(stat -t "arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET}" | awk '{print $2}')
      # align to 1 MiB
      COMPRESSED_SIZE=$(( ((${COMPRESSED_SIZE} - 1 >> 20) + 1) << 20 ))
      PKG_KERNEL_UIMAGE_LOADADDR=$(printf '%X' "$(( ${KERNEL_UIMAGE_LOADADDR} + ${COMPRESSED_SIZE} ))")
      PKG_KERNEL_UIMAGE_ENTRYADDR=$(printf '%X' "$(( ${KERNEL_UIMAGE_ENTRYADDR} + ${COMPRESSED_SIZE} ))")
    else
      PKG_KERNEL_UIMAGE_LOADADDR=${KERNEL_UIMAGE_LOADADDR}
      PKG_KERNEL_UIMAGE_ENTRYADDR=${KERNEL_UIMAGE_ENTRYADDR}
    fi

    mkimage -A ${TARGET_KERNEL_ARCH} \
            -O linux \
            -T kernel \
            -C ${KERNEL_UIMAGE_COMP} \
            -a ${PKG_KERNEL_UIMAGE_LOADADDR} \
            -e ${PKG_KERNEL_UIMAGE_ENTRYADDR} \
            -d arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET} \
               arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_UIMAGE_TARGET}

    KERNEL_TARGET="${KERNEL_UIMAGE_TARGET}"
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/.image
  cp -p arch/${TARGET_KERNEL_ARCH}/boot/${KERNEL_TARGET} System.map .config Module.symvers ${INSTALL}/.image/

  kernel_make INSTALL_MOD_PATH=${INSTALL}/$(get_kernel_overlay_dir) modules_install
  rm -f ${INSTALL}/$(get_kernel_overlay_dir)/lib/modules/*/build
  rm -f ${INSTALL}/$(get_kernel_overlay_dir)/lib/modules/*/source

  if [ "${BOOTLOADER}" = "u-boot" ]; then
    mkdir -p ${INSTALL}/usr/share/bootloader
    for dtb in arch/${TARGET_KERNEL_ARCH}/boot/dts/*.dtb arch/${TARGET_KERNEL_ARCH}/boot/dts/*/*.dtb; do
      if [ -f ${dtb} ]; then
        cp -v ${dtb} ${INSTALL}/usr/share/bootloader
      fi
    done
  elif [ "${BOOTLOADER}" = "bcm2835-bootloader" ]; then
    mkdir -p ${INSTALL}/usr/share/bootloader/overlays

    # install platform dtbs, but remove upstream kernel dtbs (i.e. without downstream
    # drivers and decent USB support) as these are not required by LibreELEC
    for dtb in arch/${TARGET_KERNEL_ARCH}/boot/dts/*.dtb arch/${TARGET_KERNEL_ARCH}/boot/dts/*/*.dtb; do
      if [ -f ${dtb} ]; then
        cp -v ${dtb} ${INSTALL}/usr/share/bootloader
      fi
    done
    rm -f ${INSTALL}/usr/share/bootloader/bcm283*.dtb
    # duplicated in overlays below
    safe_remove ${INSTALL}/usr/share/bootloader/overlay_map.dtb

    # install overlay dtbs
    for dtb in arch/arm/boot/dts/overlays/*.dtb \
               arch/arm/boot/dts/overlays/*.dtbo; do
      cp ${dtb} ${INSTALL}/usr/share/bootloader/overlays 2>/dev/null || :
    done
    cp -p arch/${TARGET_KERNEL_ARCH}/boot/dts/overlays/README ${INSTALL}/usr/share/bootloader/overlays
  fi
}
