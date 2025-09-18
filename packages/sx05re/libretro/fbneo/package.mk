# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbneo"
PKG_VERSION="9c4ab57b1aa0bd910364f381a7fda149cd5df181"
PKG_SHA256="102fc0a1b1e03d61abc37a60657a0858fd6d06ef4bee27168428fb06fb77c100"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/FBNeo"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of Final Burn Neo to Libretro (v0.2.97.38)."
PKG_LONGDESC="Currently, FB neo supports games on Capcom CPS-1 and CPS-2 hardware, SNK Neo-Geo hardware, Toaplan hardware, Cave hardware, and various games on miscellaneous hardware. "
PKG_TOOLCHAIN="make"


pre_configure_target() {
sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|"  ./src/burner/libretro/Makefile

PKG_MAKE_OPTS_TARGET=" -C ./src/burner/libretro USE_CYCLONE=0 profile=performance"

if [[ "${TARGET_FPU}" =~ "neon" ]]; then
	PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
fi

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	if [ "${ARCH}" == "arm" ]; then
	PKG_MAKE_OPTS_TARGET+=" platform=classic_armv8_a35"
	fi
fi

}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/src/burner/libretro/fbneo_libretro.so ${INSTALL}/usr/lib/libretro/
}
