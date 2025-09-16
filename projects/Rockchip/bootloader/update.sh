# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

[ -z "${SYSTEM_ROOT}" ] && SYSTEM_ROOT=""
[ -z "${BOOT_ROOT}" ] && BOOT_ROOT="/flash"
[ -z "${BOOT_PART}" ] && BOOT_PART=$(df "${BOOT_ROOT}" | tail -1 | awk {' print $1 '})
if [ -z "${BOOT_DISK}" ]; then
  case ${BOOT_PART} in
    /dev/sd[a-z][0-9]*)
      BOOT_DISK=$(echo ${BOOT_PART} | sed -e "s,[0-9]*,,g")
      ;;
    /dev/mmcblk*)
      BOOT_DISK=$(echo ${BOOT_PART} | sed -e "s,p[0-9]*,,g")
      ;;
  esac
fi

# mount ${BOOT_ROOT} r/w
  mount -o remount,rw ${BOOT_ROOT}

# update device tree
  for all_dtb in ${BOOT_ROOT}/*.dtb; do
    dtb=$(basename ${all_dtb})

    # device tree mappings for update from vendor to mainline kernel
    case "${dtb}" in
      rk3288-miniarm.dtb)
        new_dtb=rk3288-tinker-s.dtb
        ;;
      rk3328-box.dtb|rk3328-box-trn9.dtb|rk3328-box-z28.dtb|rk3328-rockbox.dtb)
        new_dtb=rk3328-a1.dtb
        ;;
      rk3399-rock-pi-4.dtb)
        new_dtb=rk3399-rock-pi-4b.dtb
        ;;
      *)
        new_dtb="${dtb}"
        ;;
    esac

    if [ "${dtb}" != "${new_dtb}" -a -f ${SYSTEM_ROOT}/usr/share/bootloader/${new_dtb} ]; then
      echo -n "Replacing ${dtb} with ${new_dtb} ... "
      cp -p ${SYSTEM_ROOT}/usr/share/bootloader/${new_dtb} ${BOOT_ROOT} && \
      sed -e "s/FDT \/${dtb}/FDT \/${new_dtb}/g" \
          -i ${BOOT_ROOT}/extlinux/extlinux.conf && \
      rm -f ${BOOT_ROOT}/${dtb}
      echo "done"
    else
      if [ -f ${SYSTEM_ROOT}/usr/share/bootloader/${dtb} ]; then
        echo -n "Updating ${dtb}... "
        cp -p ${SYSTEM_ROOT}/usr/share/bootloader/${dtb} ${BOOT_ROOT}
        echo "done"
      elif [ "$(grep -c "FDT /${dtb}" ${BOOT_ROOT}/extlinux/extlinux.conf)" -ne 0 ]; then
	 non_existend_dtb="${dtb}"
      fi
    fi
  done

# update bootloader
 if [ -f ${SYSTEM_ROOT}/usr/share/bootloader/u-boot-rockchip.bin ]; then
    echo -n "Updating fit image u-boot-rockchip.bin ... "
    dd if=${SYSTEM_ROOT}/usr/share/bootloader/u-boot-rockchip.bin of=${BOOT_DISK} bs=32k seek=1 conv=fsync,notrunc &>/dev/null
    echo "done"
  fi

# mount ${BOOT_ROOT} r/o
  sync
  mount -o remount,ro ${BOOT_ROOT}

# warning if device tree was not updated
  if [ -n "${non_existend_dtb}" ]; then
    echo "The device tree ${non_existend_dtb} your installation uses does not exist in this update package."
    echo "The updated system will continue to use the device tree from the previous system and your installation might be broken."
    echo "Please check documentation to find out which boards are supported by this package."
    sleep 10
  fi

