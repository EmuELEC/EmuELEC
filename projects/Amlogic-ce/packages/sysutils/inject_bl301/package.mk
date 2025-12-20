# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="inject_bl301"
PKG_VERSION="cdaff43a6dc6b44381959bab27b687d6c922b1a0"
case ${ARCH} in 
  'arm')
    PKG_SHA256="65c3c86fe0068c195de6b0afd2791a479ebd4f563317b553cbeaa9326189f3ec"
    ;;
  'aarch64')
    PKG_SHA256="607be0ec8e0d931803a3c452bae6beccaedb443a1f51177981e14d792c435778"
    ;;
  *)
    PKG_SHA256=''
    ;;
esac
PKG_ARCH="aarch64 arm"
PKG_SOURCE_NAME="$PKG_NAME-$ARCH-$PKG_VERSION.tar.xz"
PKG_LICENSE="proprietary"
PKG_SITE="https://coreelec.org"
PKG_URL="https://sources.coreelec.org/$PKG_SOURCE_NAME"
PKG_DEPENDS_TARGET="toolchain bl301_xxxxxx bl301_221119 bl301_091020"
PKG_LONGDESC="Tool to inject bootloader blob BL301.bin on internal eMMC"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  cp -av ${PKG_DIR}/config/bl301.conf ${PKG_BUILD}/bl301.conf
  for PKG_DEPEND_TARGET in ${PKG_DEPENDS_TARGET}; do
    case ${PKG_DEPEND_TARGET} in "bl301_"*)
      for f in $(find $(get_build_dir ${PKG_DEPEND_TARGET}) -mindepth 1 -name 'coreelec_config.c'); do
        cat ${f} | awk -F'[(),"]' '/.config_id_a\s*=\s*HASH/ {printf("%s %s\n", $2, $3)}' | \
          while read id name; do
            if ! grep -Fwq "${id}" ${PKG_BUILD}/bl301.conf; then
              echo -e '\n['${id}']' >> ${PKG_BUILD}/bl301.conf;
              cat ${f%.*}.h | awk -v id="HASHSTR_${id} " '$0 ~ id {printf("config_id=%s\n", $3)}' >> ${PKG_BUILD}/bl301.conf;
              echo -e "config_name=${name}" >> ${PKG_BUILD}/bl301.conf;
            fi
          done
      done
    esac
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
  mkdir -p ${INSTALL}/usr/lib/coreelec
  mkdir -p ${INSTALL}/etc/inject_bl301
    install -m 0755 inject_bl301 ${INSTALL}/usr/sbin/inject_bl301
    install -m 0755 ${PKG_DIR}/scripts/check-bl301.sh ${INSTALL}/usr/lib/coreelec/check-bl301
    install -m 0755 ${PKG_DIR}/scripts/update-bl301.sh ${INSTALL}/usr/lib/coreelec/update-bl301
    install -m 0644 ${PKG_BUILD}/bl301.conf ${INSTALL}/etc/inject_bl301/bl301.conf
}

post_install() {
  enable_service update-bl301.service
}
