# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mesen2"
PKG_VERSION="fabc9a62174f8734a113df6d244f5539ef6b8fcf"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/SourMesen/Mesen2"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer SDL2_net"
PKG_LONGDESC="ECWolf is a port of the Wolfenstein 3D engine based of Wolf4SDL. It combines the original Wolfenstein 3D engine with the user experience of ZDoom to create the most user and mod author friendly Wolf3D source port."
PKG_TOOLCHAIN="make"

make_target() {
export PUBLISHFLAGS="-r linux-arm64 --no-self-contained false -p:PublishSingleFile=true -p:PublishReadyToRun=true"
USE_GCC=true MESENPLATFORM=linux-arm64 make
}
