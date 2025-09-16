# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ctop"
PKG_VERSION="0.7.7"
PKG_SHA256="0db439f2030af73ad5345884b08a33a762c3b41b30604223dd0ebddde72d2741"
PKG_LICENSE="MIT"
PKG_SITE="https://ctop.sh"
PKG_URL="https://github.com/bcicen/ctop/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain go:host"
PKG_LONGDESC="Top-like interface for container metrics"
PKG_TOOLCHAIN="manual"

# Git commit of the matching release https://github.com/bcicen/ctop/releases
PKG_GIT_COMMIT="11a1cb10f416b4ca5e36c22c1acc2d11dbb24fb4"

pre_make_target() {
  go_configure

  export CTOP_VERSION="${PKG_VERSION}"
  export CTOP_REVISION="${PKG_GIT_COMMIT}"
  export CTOP_PKG="github.com/bcicen/ctop"
  export LDFLAGS="-w -extldflags -static -X main.version=${CTOP_VERSION} -X main.build=${CTOP_REVISION} -extld ${CC}"

  mkdir -p ${GOPATH}/src/github.com/bcicen
  ln -fs ${PKG_BUILD} ${GOPATH}/src/${CTOP_PKG}
}

make_target() {
  mkdir -p bin
  ${GOLANG} build -v -o bin/ctop -a -tags "static_build release" -ldflags "${LDFLAGS}"
}
