# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="rkbin"
if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
PKG_VERSION="5e54e6c0bbc0141985aca17adcebf3692cdc7f78"
PKG_SHA256="39289966b39c7bd5b2e5031d12f071e1aa80b80dc83c74b8658b3c119b6d5fd5"
else
PKG_VERSION="b0c100f1a260d807df450019774993c761beb79d"
PKG_SHA256="c6ebf8ab556e071e3b067540e95aecff650143f0c97e129cd40c837a4f11a881"
fi
PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/rockchip-linux/rkbin"
PKG_URL="https://github.com/rockchip-linux/rkbin/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="rkbin: Rockchip Firmware and Tool Binaries"
PKG_TOOLCHAIN="manual"
