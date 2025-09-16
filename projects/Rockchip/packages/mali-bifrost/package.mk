# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mali-bifrost"
PKG_VERSION="ad4c28932c3d07c75fc41dd4a3333f9013a25e7f"
PKG_SHA256="8b7bd1f969e778459d79a51e5f58c26eda0b818580966daba16ee2fc08f4c151"
PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/emuelec/libmali"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm"
PKG_LONGDESC="The Mali GPU library used in Rockchip Platform for Odroidgo Advance"

#PKG_MESON_OPTS_TARGET+=" -Dplatform=gbm -Dgpu=bifrost-g52 -Dversion=g2p0"

pre_configure_target() {

if [ "${DEVICE}" != "RK356x" ] && [ "$DEVICE" != "OdroidM1" ]; then
# Testing new version, Vulkan in the name means nothing, Vulkan is not working.
BLOB_PKG="rk3326_r13p0_gbm_with_vulkan_and_cl.zip"
BLOB_SUM="ef1a18fabf270d0a6029917d6b0e6237d328613c2f8be4d420ea23e022288dd9"

if [ ! -e "${SOURCES}/${PKG_NAME}/${BLOB_PKG}" ]
  then
    curl -Lo "${SOURCES}/${PKG_NAME}/${BLOB_PKG}" "https://dn.odroid.com/RK3326/ODROID-GO-Advance/${BLOB_PKG}"
  fi
  DLD_SUM=$(sha256sum "${SOURCES}/${PKG_NAME}/${BLOB_PKG}" | awk '{printf $1}')
  if [ ! "${DLD_SUM}" == "${BLOB_SUM}" ]
  then
    echo "Blob package mismatch, exiting."
    exit 1
  fi

  unzip -o "${SOURCES}/${PKG_NAME}/${BLOB_PKG}" -d ${PKG_BUILD}

fi
}

REAL_SYSROOT=${SYSROOT_PREFIX}

makeinstall_target() {
	# remove all the extra blobs, we only need one
	rm -rf ${INSTALL}/usr

if [ "${DEVICE}" != "RK356x" ] && [ "$DEVICE" != "OdroidM1" ]; then
	if [ "$ARCH" == "arm" ]; then
		BLOB="libmali.so_rk3326_gbm_arm32_r13p0_with_vulkan_and_cl"
	else
		BLOB="libmali.so_rk3326_gbm_arm64_r13p0_with_vulkan_and_cl"
	fi
else
	if [ "$ARCH" == "arm" ]; then
		BLOB="lib/arm-linux-gnueabihf/libmali-bifrost-g52-g2p0-gbm.so"
	else
		BLOB="lib/aarch64-linux-gnu/libmali-bifrost-g52-g2p0-gbm.so"
	fi
fi

	mkdir -p ${INSTALL}/usr/lib/
	cp ${PKG_BUILD}/${BLOB} ${INSTALL}/usr/lib/libmali.so

	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libEGL.so
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libEGL.so.1
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libgbm.so	
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libgbm.so.1
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libGLESv2.so
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libGLESv2.so.2
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libGLESv3.so
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libGLESv3.so.3
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libGLESv1_CM.so.1
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libGLES_CM.so.1
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libmali.so.1

	cp ${PKG_BUILD}/.${TARGET_NAME}/meson-private/*.pc ${REAL_SYSROOT}/usr/lib/pkgconfig
	cp -pr ${PKG_BUILD}/include ${REAL_SYSROOT}/usr
	cp ${PKG_BUILD}/include/GBM/gbm.h ${REAL_SYSROOT}/usr/include/gbm.h
	cp ${PKG_BUILD}/include/KHR/mali_khrplatform.h ${REAL_SYSROOT}/usr/include/KHR/khrplatform.h
	
	mkdir -p ${REAL_SYSROOT}/usr/lib
	
	cp ${PKG_BUILD}/${BLOB}  ${REAL_SYSROOT}/usr/lib/libmali.so

	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libEGL.so
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libEGL.so.1
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libgbm.so
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libgbm.so.1
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libGLESv2.so
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libGLESv2.so.2
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libGLESv3.so
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libGLESv3.so.3
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libGLESv1_CM.so.1
	ln -sf ${REAL_SYSROOT}/usr/lib/libmali.so ${REAL_SYSROOT}/usr/lib/libGLES_CM.so.1
	ln -sf /usr/lib/libmali.so ${INSTALL}/usr/lib/libmali.so.1
}
