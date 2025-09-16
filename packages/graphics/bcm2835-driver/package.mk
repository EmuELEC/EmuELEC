# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bcm2835-driver"
PKG_VERSION="fdb9eafae4b83e553593937eae8e77b0193903c3"
PKG_SHA256="ae590baa29a507fa50b5beae46643519a2d2e012945668cfc7393f9275793c78"
PKG_LICENSE="nonfree"
PKG_SITE="http://www.broadcom.com"
PKG_URL="${DISTRO_SRC}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain dtc"
PKG_LONGDESC="OpenMAX-bcm2835: OpenGL-ES and OpenMAX driver for BCM2835"
PKG_TOOLCHAIN="manual"

# Set SoftFP ABI or HardFP ABI
if [ "${TARGET_FLOAT}" = "soft" ]; then
  PKG_FLOAT="softfp"
else
  PKG_FLOAT="hardfp"
fi

makeinstall_target() {
  # Install vendor header files except proprietary GL headers
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    for f in $(cd ${PKG_FLOAT}/opt/vc/include; ls | grep -v "GL"); do
      cp -PRv ${PKG_FLOAT}/opt/vc/include/${f} ${SYSROOT_PREFIX}/usr/include
    done

  # Install vendor libs & pkgconfigs except proprietary GL libs
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    for f in $(cd ${PKG_FLOAT}/opt/vc/lib; ls *.so *.a | grep -Ev "^lib(EGL|GL)"); do
      cp -PRv ${PKG_FLOAT}/opt/vc/lib/${f}              ${SYSROOT_PREFIX}/usr/lib
    done
    mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
      for f in $(cd ${PKG_FLOAT}/opt/vc/lib/pkgconfig; ls | grep -v "gl"); do
        cp -PRv ${PKG_FLOAT}/opt/vc/lib/pkgconfig/${f}  ${SYSROOT_PREFIX}/usr/lib/pkgconfig
      done

  # Update prefix in vendor pkgconfig files
  for PKG_CONFIGS in $(find "${SYSROOT_PREFIX}/usr/lib" -type f -name "*.pc" 2>/dev/null); do
    sed -e "s#prefix=/opt/vc#prefix=/usr#g" -i "${PKG_CONFIGS}"
  done

  # Create symlinks to /opt/vc to satisfy hardcoded include & lib paths
  mkdir -p ${SYSROOT_PREFIX}/opt/vc
    ln -sf ${SYSROOT_PREFIX}/usr/lib     ${SYSROOT_PREFIX}/opt/vc/lib
    ln -sf ${SYSROOT_PREFIX}/usr/include ${SYSROOT_PREFIX}/opt/vc/include

  # Install vendor libs except proprietary GL
  mkdir -p ${INSTALL}/usr/lib
    for f in $(cd ${PKG_FLOAT}/opt/vc/lib; ls *.so | grep -Ev "^lib(EGL|GL)"); do
      cp -PRv ${PKG_FLOAT}/opt/vc/lib/${f} ${INSTALL}/usr/lib
    done

  # Install useful tools
  mkdir -p ${INSTALL}/usr/bin
    cp -PRv ${PKG_FLOAT}/opt/vc/bin/dtoverlay  ${INSTALL}/usr/bin
    ln -s dtoverlay                            ${INSTALL}/usr/bin/dtparam
    cp -PRv ${PKG_FLOAT}/opt/vc/bin/vcdbg      ${INSTALL}/usr/bin
    cp -PRv ${PKG_FLOAT}/opt/vc/bin/vcgencmd   ${INSTALL}/usr/bin
    cp -PRv ${PKG_FLOAT}/opt/vc/bin/vcmailbox  ${INSTALL}/usr/bin
    cp -PRv ${PKG_FLOAT}/opt/vc/bin/tvservice  ${INSTALL}/usr/bin
    cp -PRv ${PKG_FLOAT}/opt/vc/bin/edidparser ${INSTALL}/usr/bin

  # Create symlinks to /opt/vc to satisfy hardcoded lib paths
  mkdir -p ${INSTALL}/opt/vc
    ln -sf /usr/bin ${INSTALL}/opt/vc/bin
    ln -sf /usr/lib ${INSTALL}/opt/vc/lib
}

