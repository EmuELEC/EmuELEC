# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present asakous (https://github.com/asakous)

PKG_NAME="nestopiaCV"
PKG_VERSION="2ef9f54159a3da268545f338842bf8a7bbd5e66c"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/asakous/NestopiaCV"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Libretro implementation of NEStopia. (Nintendo Entertainment System)"
PKG_LONGDESC="This project is a fork of the original Nestopia source code, plus the Linux port. The purpose of the project is to enhance the original, and ensure it continues to work on modern operating systems."
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

pre_configure_target() {
cp -f ${PKG_BUILD}/NstCore.hpp ${PKG_BUILD}/source/core/NstCore.hpp
}

make_target() {
  cd ${PKG_BUILD}
  make -C libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  mkdir -p ${INSTALL}/etc/
  cp ${PKG_BUILD}/skin.png ${INSTALL}/usr/lib/libretro/
  cp ${PKG_BUILD}/skin.png ${INSTALL}/etc/
  cp libretro/nestopiaCV_libretro.so ${INSTALL}/usr/lib/libretro/
echo 'display_name = "Nintendo - NES / Famicom (Nestopia CV)"
authors = "Martin Freij|R. Belmont|R. Danbrook"
supported_extensions = "nes|fds|unf|unif"
corename = "NestopiaCV"
manufacturer = "Nintendo"
categories = "Emulator"
systemname = "Nintendo Entertainment System"
systemid = "nes"
database = "Nintendo - Nintendo Entertainment System|Nintendo - Family Computer Disk System"
license = "GPLv2"
permissions = ""
display_version = "v1.47-WIP"
supports_no_game = "false"
firmware_count = 2
firmware0_desc = "NstDatabase.xml (Nestopia UE Database file)"
firmware0_path = "NstDatabase.xml"
firmware0_opt = "false"
firmware1_desc = "disksys.rom (Family Computer Disk System BIOS)"
firmware1_path = "disksys.rom"
firmware1_opt = "false"
notes = "Get NstDatabase.xml from https://github.com/0ldsk00l/nestopia|(!) disksys.rom (md5): ca30b50f880eb660a320674ed365ef7a|Press Retropad L1 to switch disk side."'>  ${INSTALL}/usr/lib/libretro/nestopiaCV_libretro.info

}
