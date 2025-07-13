# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="kernel-firmware"
PKG_VERSION="20250509"
PKG_SHA256="f2c60d66f226a28130cb5643e6e544d3229673460e127c91ba03f1080cbd703e"
PKG_LICENSE="other"
PKG_SITE="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/"
PKG_URL="https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${PKG_VERSION}.tar.xz"
PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/packages/${PKG_NAME} ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/packages/${PKG_NAME}"
PKG_LONGDESC="kernel-firmware: kernel related firmware"
PKG_TOOLCHAIN="manual"

configure_package() {
  PKG_FW_SOURCE=${PKG_BUILD}/.copied-firmware
}

post_patch() {
  (
    cd ${PKG_BUILD}

    # Do not run check_whence.py against the copied firmware
    echo '#!/usr/bin/python3' > check_whence.py

    mkdir -p "${PKG_FW_SOURCE}"
      ./copy-firmware.sh --verbose "${PKG_FW_SOURCE}"

    # copy extra firmware files (or overwrite upstream ones)
    if [ -d ${PKG_DIR}/extra-firmware ]; then
      cp -r ${PKG_DIR}/extra-firmware/* "${PKG_FW_SOURCE}"
    fi
  )
}

# Install additional miscellaneous drivers
makeinstall_target() {
  FW_TARGET_DIR=${INSTALL}/$(get_full_firmware_dir)

  if find_file_path config/kernel-firmware.dat; then
    FW_LISTS="${FOUND_PATH}"
  else
    FW_LISTS="${PKG_DIR}/firmwares/any.dat ${PKG_DIR}/firmwares/${TARGET_ARCH}.dat"
  fi

  FW_LISTS+=" ${PROJECT_DIR}/${PROJECT}/config/kernel-firmware-any.dat ${PROJECT_DIR}/${PROJECT}/config/kernel-firmware-${TARGET_ARCH}.dat"

  FW_LISTS+=" ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/config/kernel-firmware-any.dat ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/config/kernel-firmware-${TARGET_ARCH}.dat"

  for fwlist in ${FW_LISTS}; do
    [ -f "${fwlist}" ] || continue

    while read -r fwline; do
      [ -z "${fwline}" ] && continue
      [[ ${fwline} =~ ^#.* ]] && continue
      [[ ${fwline} =~ ^[[:space:]] ]] && continue

      eval "(cd ${PKG_FW_SOURCE} && find "${fwline}" >/dev/null)" || die "ERROR: Firmware pattern does not exist: ${fwline}"

      while read -r fwfile; do
        [ -d "${PKG_FW_SOURCE}/${fwfile}" ] && continue

        if [ -f "${PKG_FW_SOURCE}/${fwfile}" ]; then
          mkdir -p "$(dirname "${FW_TARGET_DIR}/${fwfile}")"
            cp -Lv "${PKG_FW_SOURCE}/${fwfile}" "${FW_TARGET_DIR}/${fwfile}"
        else
          echo "ERROR: Firmware file ${fwfile} does not exist - aborting"
          exit 1
        fi
      done <<<"$(cd ${PKG_FW_SOURCE} && eval "find "${fwline}"")"
    done <"${fwlist}"
  done

  PKG_KERNEL_CFG_FILE=$(kernel_config_path) || die

  # The following files are RPi specific and installed by brcmfmac_sdio-firmware-rpi instead.
  # They are also not required at all if the kernel is not suitably configured.
  if listcontains "${FIRMWARE}" "brcmfmac_sdio-firmware-rpi" ||
     ! grep -q "^CONFIG_BRCMFMAC_SDIO=y" ${PKG_KERNEL_CFG_FILE}; then
    rm -fr ${FW_TARGET_DIR}/brcm/brcmfmac43430*-sdio.*
    rm -fr ${FW_TARGET_DIR}/brcm/brcmfmac43455*-sdio.*
  fi

  # brcm pcie firmware is only needed by x86_64
  [ "${TARGET_ARCH}" != "x86_64" ] && rm -fr ${FW_TARGET_DIR}/brcm/*-pcie.*

  # Cleanup - which may be project or device specific
  find_file_path scripts/cleanup.sh && ${FOUND_PATH} ${FW_TARGET_DIR} || true
}
