# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

# with 1.0.0 repeat delay is broken. test on upgrade

PKG_NAME="v4l-utils"
PKG_VERSION="1.22.1"
PKG_SHA256="65c6fbe830a44ca105c443b027182c1b2c9053a91d1e72ad849dfab388b94e31"
PKG_LICENSE="GPL"
PKG_SITE="http://linuxtv.org/"
PKG_URL="http://linuxtv.org/downloads/v4l-utils/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
[[ "${DEVICE}" != "Amlogic-old" ]] && PKG_DEPENDS_TARGET="libbpf"
PKG_DEPENDS_TARGET="toolchain alsa-lib elfutils gcc-bpf:host ${PKG_DEPENDS_TARGET} systemd zlib"
PKG_LONGDESC="Linux V4L2 and DVB API utilities and v4l libraries (libv4l)."
PKG_STAMP_VAR="$IR_REMOTE_KEYMAPS"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--without-jpeg \
                           --enable-bpf \
                           --enable-static \
													 --with-udevdir=/usr/lib/udev/ \
                           --disable-shared \
                           --disable-doxygen-doc"

pre_configure_target() {
  # cec-ctl fails to build in subdirs
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}
}

make_target() {
  make -C utils/keytable CFLAGS="${TARGET_CFLAGS}"
  make -C utils/ir-ctl CFLAGS="${TARGET_CFLAGS}"
  if [ "${CEC_FRAMEWORK_SUPPORT}" = "yes" ]; then
    make -C utils/libcecutil CFLAGS="${TARGET_CFLAGS}"
    make -C utils/cec-ctl CFLAGS="${TARGET_CFLAGS}"
  fi
  make -C lib CFLAGS="${TARGET_CFLAGS}"
  make -C utils/dvb CFLAGS="${TARGET_CFLAGS}"
  make -C utils/v4l2-ctl CFLAGS="${TARGET_CFLAGS}"

  if [ "${LIBREELEC_VERSION}" == "devel" ]; then
    make -C utils/v4l2-compliance CFLAGS="${TARGET_CFLAGS}"
  fi
}

makeinstall_target() {
  make install DESTDIR=${INSTALL} PREFIX=/usr -C utils/keytable
  make install DESTDIR=${INSTALL} PREFIX=/usr -C utils/ir-ctl
  if [ "${CEC_FRAMEWORK_SUPPORT}" = "yes" ]; then
    make install DESTDIR=${INSTALL} PREFIX=/usr -C utils/cec-ctl
  fi
  make install DESTDIR=${INSTALL} PREFIX=/usr -C utils/dvb
  make install DESTDIR=${INSTALL} PREFIX=/usr -C utils/v4l2-ctl

  if [ "${LIBREELEC_VERSION}" == "devel" ]; then
    make install DESTDIR=${INSTALL} PREFIX=/usr -C utils/v4l2-compliance
  fi

  cp ${PKG_BUILD}/contrib/lircd2toml.py ${INSTALL}/usr/bin/
}

create_multi_keymap() {
  local f name map
  name="${1}"
  shift 1
  (
    for f in "$@"; do
      map="${INSTALL}/usr/lib/udev/rc_keymaps/${f}.toml"
      [ -e "${map}" ] && cat "${map}"
    done
  ) > ${INSTALL}/usr/lib/udev/rc_keymaps/${name}.toml
}

post_makeinstall_target() {
  local f keymap

  rm -rf ${INSTALL}/etc/rc_keymaps
    ln -sf /storage/.config/rc_keymaps ${INSTALL}/etc/rc_keymaps

  mkdir -p ${INSTALL}/usr/config
    cp -PR ${PKG_DIR}/config/* ${INSTALL}/usr/config

  rm -rf ${INSTALL}/usr/lib/udev/rules.d
    mkdir -p ${INSTALL}/usr/lib/udev/rules.d
    cp -PR ${PKG_DIR}/udev.d/*.rules ${INSTALL}/usr/lib/udev/rules.d

  # install additional keymaps without overwriting upstream maps
  (
    set -C
    for f in ${PKG_DIR}/keymaps/*; do
      if [ -e ${f} ]; then
        keymap=$(basename ${f})
        cat ${f} > ${INSTALL}/usr/lib/udev/rc_keymaps/${keymap}
      fi
    done
  )

  # create multi keymap to support several remotes OOTB
  if [ -n "${IR_REMOTE_KEYMAPS}" ]; then
    create_multi_keymap libreelec_multi ${IR_REMOTE_KEYMAPS}

    # use multi-keymap instead of default one
    sed -i '/^\*\s*rc-rc6-mce\s*rc6_mce/d' ${INSTALL}/etc/rc_maps.cfg

    cat << EOF >> ${INSTALL}/etc/rc_maps.cfg
#
# Custom LibreELEC configuration starts here
#
# use combined multi-table on MCE receivers
# *		rc-rc6-mce	rc6_mce.toml
*		rc-rc6-mce	libreelec_multi.toml
# multi-table for amlogic devices
meson-ir	rc-empty	libreelec_multi.toml
EOF

  fi
}
