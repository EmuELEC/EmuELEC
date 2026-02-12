# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mali-bifrost"
PKG_VERSION="ad4c28932c3d07c75fc41dd4a3333f9013a25e7f"
PKG_SHA256="8b7bd1f969e778459d79a51e5f58c26eda0b818580966daba16ee2fc08f4c151"
PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/emuelec/libmali"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm mesa"
PKG_LONGDESC="The Mali GPU library used in Rockchip Platform for Odroidgo Advance"
PKG_TOOLCHAIN="manual"

make_target() {
  true
}

pre_configure_target() {

if [ "${DEVICE}" != "RK356x" ] && [ "$DEVICE" != "OdroidM1" ] && [ "$DEVICE" != "X96X6" ]; then
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

else
  # RK356x/OdroidM1/X96X6: Download a newer Mali blob if MALI_BLOB_DDK is set
  # The emuelec/libmali repo only has g2p0 blobs which may not match the kernel DDK
  if [ -n "${MALI_BLOB_DDK}" ] && [ "${MALI_BLOB_DDK}" != "g2p0" ]; then
    if [ "$ARCH" == "arm" ]; then
      MALI_BLOB_ARCH="arm-linux-gnueabihf"
    else
      MALI_BLOB_ARCH="aarch64-linux-gnu"
    fi
    MALI_BLOB_NAME="libmali-bifrost-${MALI_FAMILY}-${MALI_BLOB_DDK}-gbm.so"
    MALI_BLOB_URL="https://github.com/JeffyCN/mirrors/raw/libmali/lib/${MALI_BLOB_ARCH}/${MALI_BLOB_NAME}"
    MALI_BLOB_CACHED="${SOURCES}/${PKG_NAME}/${MALI_BLOB_NAME}"

    if [ ! -e "${MALI_BLOB_CACHED}" ]; then
      echo "Downloading Mali blob ${MALI_BLOB_NAME} from JeffyCN/mirrors..."
      mkdir -p "${SOURCES}/${PKG_NAME}"
      if ! curl -fLo "${MALI_BLOB_CACHED}" "${MALI_BLOB_URL}"; then
        echo "WARNING: Failed to download ${MALI_BLOB_NAME}, will use blob from repo"
        rm -f "${MALI_BLOB_CACHED}"
      else
        echo "Downloaded Mali blob: ${MALI_BLOB_CACHED} ($(stat -c%s "${MALI_BLOB_CACHED}") bytes)"
      fi
    fi
  fi
fi
}

REAL_SYSROOT=${SYSROOT_PREFIX}

makeinstall_target() {
        # remove all the extra blobs, we only need one
        rm -rf ${INSTALL}/usr

if [ "${DEVICE}" != "RK356x" ] && [ "$DEVICE" != "OdroidM1" ] && [ "$DEVICE" != "X96X6" ]; then
        if [ "$ARCH" == "arm" ]; then
                BLOB="libmali.so_rk3326_gbm_arm32_r13p0_with_vulkan_and_cl"
        else
                BLOB="libmali.so_rk3326_gbm_arm64_r13p0_with_vulkan_and_cl"
        fi

    cp -rf --remove-destination "${PKG_BUILD}/${BLOB}" ${INSTALL}/usr/lib/libMali.so
        mkdir -p ${INSTALL}/usr/include/EGL
        cp -rf --remove-destination "${PKG_BUILD}"/include/EGL ${INSTALL}/usr/include/
        mkdir -p ${INSTALL}/usr/include/GLES2
        cp -rf --remove-destination "${PKG_BUILD}"/include/GLES2 ${INSTALL}/usr/include/
        mkdir -p ${INSTALL}/usr/include/GLES3
        cp -rf --remove-destination "${PKG_BUILD}"/include/GLES3 ${INSTALL}/usr/include/
else
        mkdir -p ${INSTALL}/usr/lib
        mkdir -p ${INSTALL}/usr/include/EGL
        mkdir -p ${INSTALL}/usr/include/GLES2
        mkdir -p ${INSTALL}/usr/include/GLES3
        mkdir -p ${INSTALL}/usr/include/KHR
        mkdir -p ${INSTALL}/usr/include/gbm

        # Only copy the correct architecture blob
        if [ "$ARCH" == "arm" ]; then
                MALI_LIB_DIR="${PKG_BUILD}/lib/arm-linux-gnueabihf"
        else
                MALI_LIB_DIR="${PKG_BUILD}/lib/aarch64-linux-gnu"
        fi

        # Find the correct Mali blob for our GPU
        # Priority: 1) Downloaded blob matching MALI_BLOB_DDK  2) Repo blob
        MALI_BLOB=""

        # Check for downloaded blob first (from pre_configure_target)
        if [ -n "${MALI_BLOB_DDK}" ]; then
                MALI_BLOB_CACHED="${SOURCES}/${PKG_NAME}/libmali-bifrost-${MALI_FAMILY}-${MALI_BLOB_DDK}-gbm.so"
                if [ -f "${MALI_BLOB_CACHED}" ]; then
                        MALI_BLOB="${MALI_BLOB_CACHED}"
                        echo "Using downloaded Mali blob (DDK ${MALI_BLOB_DDK}): ${MALI_BLOB}"
                fi
        fi

        # Fall back to repo blob
        if [ -z "${MALI_BLOB}" ]; then
                # Exclude "dummy" blobs - they are for headless/testing only and cause SIGILL
                MALI_BLOB=$(find ${MALI_LIB_DIR} -name "libmali-bifrost-${MALI_FAMILY}*-gbm.so" -not -name "*dummy*" -not -type l | head -1)
        fi

        if [ -z "${MALI_BLOB}" ]; then
                echo "ERROR: Could not find Mali blob for ${MALI_FAMILY}"
                echo "Checked: ${SOURCES}/${PKG_NAME}/libmali-bifrost-${MALI_FAMILY}-${MALI_BLOB_DDK:-g2p0}-gbm.so"
                echo "Available in repo:"
                ls -la ${MALI_LIB_DIR}/libmali-bifrost-${MALI_FAMILY}* 2>/dev/null || true
                exit 1
        fi

        echo "Installing Mali blob: ${MALI_BLOB}"
        cp -f --remove-destination "${MALI_BLOB}" ${INSTALL}/usr/lib/libmali.so

        cp -rf --remove-destination ${PKG_BUILD}/include/EGL ${INSTALL}/usr/include/
        cp -rf --remove-destination ${PKG_BUILD}/include/GLES2 ${INSTALL}/usr/include/
        cp -rf --remove-destination ${PKG_BUILD}/include/GLES3 ${INSTALL}/usr/include/
        cp -rf --remove-destination ${PKG_BUILD}/include/KHR ${INSTALL}/usr/include/
fi
}

post_makeinstall_target() {
  # Create symlinks for standard OpenGL ES library names
  # libmali.so.1 (lowercase) is the SONAME embedded in the blob — this MUST exist
  # for the dynamic linker to find the 64-bit version instead of the 32-bit one
  # in /usr/lib32/libmali/ from lib32-mali-bifrost
  ln -sf libmali.so ${INSTALL}/usr/lib/libmali.so.1
  ln -sf libmali.so ${INSTALL}/usr/lib/libMali.so.1
  ln -sf libMali.so.1 ${INSTALL}/usr/lib/libMali.so
  ln -sf libMali.so ${INSTALL}/usr/lib/libEGL.so.1
  ln -sf libEGL.so.1 ${INSTALL}/usr/lib/libEGL.so
  ln -sf libMali.so ${INSTALL}/usr/lib/libGLESv2.so.2
  ln -sf libGLESv2.so.2 ${INSTALL}/usr/lib/libGLESv2.so
  ln -sf libMali.so ${INSTALL}/usr/lib/libgbm.so.1
  ln -sf libgbm.so.1 ${INSTALL}/usr/lib/libgbm.so
  
  # Create pkg-config files
  mkdir -p ${INSTALL}/usr/lib/pkgconfig
  
  cat > ${INSTALL}/usr/lib/pkgconfig/glesv2.pc << EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: glesv2
Description: Mali OpenGL ES 2.0 library
Version: 2.0
Libs: -L\${libdir} -lGLESv2
Cflags: -I\${includedir}
EOF

  cat > ${INSTALL}/usr/lib/pkgconfig/egl.pc << EOF
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: egl
Description: Mali EGL library
Version: 1.5
Libs: -L\${libdir} -lEGL
Cflags: -I\${includedir}
EOF

  # Install to sysroot for other packages to find
  cp -PR ${INSTALL}/usr/include/* ${SYSROOT_PREFIX}/usr/include/
  cp -PR ${INSTALL}/usr/lib/pkgconfig/* ${SYSROOT_PREFIX}/usr/lib/pkgconfig/

  # Install libraries and symlinks to sysroot for linking
  cp -PR ${INSTALL}/usr/lib/libmali.so ${SYSROOT_PREFIX}/usr/lib/
  cp -PR ${INSTALL}/usr/lib/libMali.so* ${SYSROOT_PREFIX}/usr/lib/
  cp -PR ${INSTALL}/usr/lib/libEGL.so* ${SYSROOT_PREFIX}/usr/lib/
  cp -PR ${INSTALL}/usr/lib/libGLESv2.so* ${SYSROOT_PREFIX}/usr/lib/
  cp -PR ${INSTALL}/usr/lib/libgbm.so* ${SYSROOT_PREFIX}/usr/lib/
}
