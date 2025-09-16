PKG_NAME="openjazz"
PKG_VERSION="a34e79dba5756000ad3796efae61a57be4a46496"
PKG_SHA256="fe76aca99a319ee70c1eaeec17a935880c7a73f02e42ac1917e581062ea38e67"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="http://www.alister.eu/jazz/oj/"
PKG_URL="https://github.com/sana2dang/openjazz/archive/${PKG_VERSION}.tar.gz"
PKG_SHORTDESC="OpenJazz for OGA"
PKG_LONGDESC="a free, open-source version of the classic Jazz Jackrabbit™ games."
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_TOOLCHAIN="auto"

pre_configure_target() {
  sed -i "s|sdl2-config|${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" Makefile
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/OpenJazz ${INSTALL}/usr/bin
}
