# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="glm"
PKG_VERSION="0.9.9.8"
PKG_SHA256="37e2a3d62ea3322e43593c34bae29f57e3e251ea89f4067506c94043769ade4c"
PKG_LICENSE="MIT"
PKG_SITE="https://glm.g-truc.net/"
PKG_URL="https://github.com/g-truc/glm/releases/download/${PKG_VERSION}/glm-${PKG_VERSION}.zip"
PKG_SOURCE_DIR="glm"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="OpenGL Mathematics (GLM)"

# Not needed by GLM itself, but users will need it. So instead of adding this
# to every user, put it here once.
if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

# Hack install solution until cmake install restored in upstream package
makeinstall_target() {
  target_has_feature 32bit && PKG_VOID_SIZE=4 || PKG_VOID_SIZE=8

  for _dir in ${SYSROOT_PREFIX} ${INSTALL}; do
    mkdir -p ${_dir}/usr/include ${_dir}/usr/lib/pkgconfig ${_dir}/usr/lib/cmake/glm
      cp -r ${PKG_BUILD}/glm ${_dir}/usr/include
      cp ${PKG_DIR}/config/glm.pc ${_dir}/usr/lib/pkgconfig
      cp ${PKG_DIR}/config/*.cmake ${_dir}/usr/lib/cmake/glm

      sed -e "s/@@VERSION@@/${PKG_VERSION}/g" \
          -e "s/@@VOID_SIZE@@/${PKG_VOID_SIZE}/g" \
          -i ${_dir}/usr/lib/pkgconfig/glm.pc ${_dir}/usr/lib/cmake/glm/*.cmake
  done
}
