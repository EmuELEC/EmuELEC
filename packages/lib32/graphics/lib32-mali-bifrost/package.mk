# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-mali-bifrost"
PKG_VERSION="$(get_pkg_version mali-bifrost)"
PKG_NEED_UNPACK="$(get_pkg_directory mali-bifrost)"
PKG_ARCH="aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/emuelec/libmali"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-libdrm"
PKG_LONGDESC="The Mali GPU library used in Rockchip Platform for Odroidgo Advance"
PKG_PATCH_DIRS+=" $(get_pkg_directory mali-bifrost)/patches"
PKG_BUILD_FLAGS="lib32"

if [[ "${DEVICE}" =~ ^(OdroidGoAdvance|GameForce)$ ]]; then
  PKG_RK3326="yes"
fi

unpack() {
  ${SCRIPTS}/get mali-bifrost
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/mali-bifrost/mali-bifrost-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
  if [ "${PKG_RK3326}" = "yes" ]; then
    unzip -o "${SOURCES}/mali-bifrost/rk3326_r13p0_gbm_with_vulkan_and_cl.zip" -d ${PKG_BUILD}
  fi
  safe_remove ${PKG_BUILD}/lib/aarch64-linux-gnu
}

makeinstall_target() {
  if [ "${PKG_RK3326}" = "yes" ]; then
    local BLOB="libmali.so_rk3326_gbm_arm32_r13p0_with_vulkan_and_cl"
    local LIBDIR=${INSTALL}/usr/lib32
  else
    local BLOB="lib/arm-linux-gnueabihf/libmali-bifrost-g52-g2p0-gbm.so"
    local LIBDIR=${INSTALL}/usr/lib32/libmali
    mkdir -p ${INSTALL}/etc/profile.d
    # Add it after the existing LD_LIBRARY_PATH, to make sure /emuelec/libs are read before it
    echo 'export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib32/libmali"' > ${INSTALL}/etc/profile.d/99-rk-mali-workaround.conf
  fi

  mkdir -p ${LIBDIR} \
           ${SYSROOT_PREFIX}/usr/lib/pkgconfig \
           ${SYSROOT_PREFIX}/usr/lib/include/KHR

  BLOB=${PKG_BUILD}/${BLOB}
  cp ${BLOB} ${LIBDIR}/libmali.so
  cp ${BLOB} ${SYSROOT_PREFIX}/usr/lib/libmali.so

  local LINK_LIST="libEGL.so \
                   libEGL.so.1 \
                   libgbm.so \
                   libgbm.so.1 \
                   libGLESv2.so \
                   libGLESv2.so.2 \
                   libGLESv3.so \
                   libGLESv3.so.3 \
                   libGLESv1_CM.so.1 \
                   libGLES_CM.so.1 \
                   libmali.so.1"
  local LINK_NAME
  for LINK_NAME in ${LINK_LIST}; do
    ln -sf libmali.so ${LIBDIR}/${LINK_NAME}
    ln -sf libmali.so ${SYSROOT_PREFIX}/usr/lib/${LINK_NAME}
  done
  cp -va ${PKG_BUILD}/.${TARGET_NAME}/meson-private/*.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig/
  cp -rva ${PKG_BUILD}/include/* \
          ${PKG_BUILD}/include/GBM/gbm.h \
          ${SYSROOT_PREFIX}/usr/include/
  cp -va ${PKG_BUILD}/include/KHR/mali_khrplatform.h ${SYSROOT_PREFIX}/usr/include/KHR/khrplatform.h
}
