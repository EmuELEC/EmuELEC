# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="prometheus-node-exporter"
PKG_VERSION="1.5.0"
PKG_SHA256="67c6d59359d8c484e1e28d0a52a971eebe687f083c5fbb35c5e651543e5d0ea4"
PKG_REV="0"
PKG_LICENSE="Apache License 2.0"
PKG_SITE="https://github.com/prometheus/node_exporter"
PKG_URL="https://github.com/prometheus/node_exporter/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain go:host systemd"
PKG_SECTION="service"
PKG_SHORTDESC="Prometheus exporter for machine metrics."
PKG_LONGDESC="Prometheus exporter for hardware and OS metrics exposed by the kernel."
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Prometheus Node Exporter"
PKG_ADDON_TYPE="xbmc.service"

configure_target() {
  go_configure

  export LDFLAGS="-w -linkmode external -extldflags -Wl,--unresolved-symbols=ignore-in-shared-libs -extld ${CC} \
                  -X github.com/prometheus/common/version.Version=${PKG_VERSION} \
                  -X github.com/prometheus/common/version.Revision=${PKG_REV} \
                  -X github.com/prometheus/common/version.Branch=master \
                  -X github.com/prometheus/common/version.BuildUser=root@libreelec \
                  -X github.com/prometheus/common/version.BuildDate=$(date '+%Y%m%d-%H:%M:%S')"
}

make_target() {
  ${GOLANG} build -a -ldflags "${LDFLAGS}" -o bin/prometheus-node-exporter -v
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
  cp -P ${PKG_BUILD}/bin/prometheus-node-exporter ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
}

