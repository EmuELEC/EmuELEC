# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="image"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_DEPENDS_TARGET="toolchain squashfs-tools:host dosfstools:host fakeroot:host kmod:host mtools:host populatefs:host libc gcc linux linux-drivers linux-firmware ${BOOTLOADER} busybox util-linux corefonts network misc-packages debug exfatprogs"
PKG_SECTION="virtual"
PKG_LONGDESC="Root package used to build and create complete image"

# Bash is default shell
PKG_DEPENDS_TARGET+=" bash"

# Graphic support
[ ! "${DISPLAYSERVER}" = "no" ] && PKG_DEPENDS_TARGET+=" ${DISPLAYSERVER}"

# Multimedia support
[ ! "${MEDIACENTER}" = "no" ] && PKG_DEPENDS_TARGET+=" mediacenter"

# Sound support
[ "${ALSA_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" alsa"

[ "${PULSEAUDIO_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" pulseaudio"

[ "${PIPEWIRE_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" pipewire wireplumber"

if [ "${PULSEAUDIO_SUPPORT}" = "yes" -a "${PIPEWIRE_SUPPORT}" = "yes" ]; then
  die "PULSEAUDIO_SUPPORT and PIPEWIRE_SUPPORT cannot be enabled together"
fi

# Automounter support
[ "${UDEVIL}" = "yes" ] && PKG_DEPENDS_TARGET+=" udevil"

# EXFAT support
[ "$EXFAT" = "yes" ] && PKG_DEPENDS_TARGET+=" exfat"

# HFS filesystem tools
[ "${HFSTOOLS}" = "yes" ] && PKG_DEPENDS_TARGET+=" diskdev_cmds"

# NTFS 3G support
[ "${NTFS3G}" = "yes" ] && PKG_DEPENDS_TARGET+=" ntfs-3g_ntfsprogs"

# Remote support
[ "${REMOTE_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" remote"

# Virtual image creation support
[ "${PROJECT}" = "Generic" ] && PKG_DEPENDS_TARGET+=" virtual"

# Installer support
[ "${INSTALLER_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" installer"

# Devtools... (not for Release)
[ "${TESTING}" = "yes" ] && PKG_DEPENDS_TARGET+=" testing"

# OEM packages
[ "${OEM_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" oem"

true
