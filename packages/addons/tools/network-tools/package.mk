# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="network-tools"
PKG_VERSION="1.0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="virtual"
PKG_SHORTDESC="A bundle of network tools and programs"
PKG_LONGDESC="This bundle currently includes bwm-ng, iftop, iperf, irssi, lftp, ncftp, ngrep, nmap, rar2fs, rsync, sshfs, sshpass, tcpdump, udpxy and wireless_tools."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Network Tools"
PKG_ADDON_TYPE="xbmc.python.script"

PKG_DEPENDS_TARGET="toolchain \
                    bwm-ng \
                    iftop \
                    iperf \
                    irssi \
                    lftp \
                    ncftp \
                    ngrep \
                    nmap \
                    rar2fs \
                    rsync \
                    sshfs \
                    sshpass \
                    tcpdump \
                    udpxy \
                    wireless_tools"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/{bin,lib}
    # bwm-ng
    cp -P $(get_install_dir bwm-ng)/usr/bin/bwm-ng ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # fuse
    cp -P $(get_install_dir fuse)/usr/bin/{fusermount,ulockmgr_server} ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir fuse)/usr/sbin/mount.fuse ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir fuse)/usr/lib/{libfuse.so*,libulockmgr.so*} ${ADDON_BUILD}/${PKG_ADDON_ID}/lib

    # fuse3
    cp -P $(get_install_dir fuse3)/usr/bin/fusermount3 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir fuse3)/usr/sbin/mount.fuse3  ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir fuse3)/usr/lib/libfuse3.so* ${ADDON_BUILD}/${PKG_ADDON_ID}/lib

    # iftop
    cp -P $(get_install_dir iftop)/usr/sbin/iftop ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # iperf
    cp -P $(get_install_dir iperf)/usr/bin/iperf3 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    ln -s iperf3 ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/iperf

    # irssi
    cp -P $(get_install_dir irssi)/usr/bin/irssi ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # lftp
    cp -P $(get_install_dir lftp)/usr/bin/lftp ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # ncftp
    cp -P $(get_install_dir ncftp)/usr/bin/ncftp ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir ncftp)/usr/bin/ncftpbatch ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir ncftp)/usr/bin/ncftpget ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir ncftp)/usr/bin/ncftpls ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir ncftp)/usr/bin/ncftpput ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # ngrep
    cp -P $(get_install_dir ngrep)/usr/bin/ngrep ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # nmap
    cp -P $(get_install_dir nmap)/usr/bin/nmap ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # rar2fs
    cp -P $(get_install_dir rar2fs)/usr/bin/mkr2i ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    cp -P $(get_install_dir rar2fs)/usr/bin/rar2fs ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # rsync
    cp -P $(get_install_dir rsync)/usr/bin/rsync ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # sshfs
    cp -P $(get_install_dir sshfs)/usr/bin/sshfs ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # sshpass
    cp -P $(get_install_dir sshpass)/usr/bin/sshpass ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # tcpdump
    cp -P $(get_install_dir tcpdump)/usr/bin/tcpdump ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # udpxy
    cp -P $(get_install_dir udpxy)/usr/bin/udpxy ${ADDON_BUILD}/${PKG_ADDON_ID}/bin

    # wireless_tools
    cp -P $(get_install_dir wireless_tools)/usr/sbin/iwconfig ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
    ln -s iwconfig ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/iwgetid
    ln -s iwconfig ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/iwlist
    ln -s iwconfig ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/iwspy
    ln -s iwconfig ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/iwpriv
}
