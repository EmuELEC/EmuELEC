# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="systemd"
PKG_VERSION="242"
PKG_SHA256="ec22be9a5dd94c9640e6348ed8391d1499af8ca2c2f01109198a414cff6c6cba"
PKG_LICENSE="LGPL2.1+"
PKG_SITE="http://www.freedesktop.org/wiki/Software/systemd"
PKG_URL="https://github.com/systemd/systemd/archive/v$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain libcap kmod util-linux entropy libidn2"
PKG_LONGDESC="A system and session manager for Linux, compatible with SysV and LSB init scripts."

if [ "${DEVICE}" = "Amlogic-old" ]; then
  PKG_PATCH_DIRS="amlogic"
fi

if [ "$DEVICE" != "OdroidGoAdvance" ] && [ "$DEVICE" != "GameForce" ]; then
	PKG_DEPENDS_TARGET+=" wait-time-sync"
fi

PKG_MESON_OPTS_TARGET="--libdir=/usr/lib \
                       -Drootprefix=/usr \
                       -Dsplit-usr=false \
                       -Dsplit-bin=true \
                       -Ddefault-hierarchy=hybrid \
                       -Dtty-gid=5 \
                       -Dtests=false \
                       -Dseccomp=false \
                       -Dselinux=false \
                       -Dapparmor=false \
                       -Dpolkit=false \
                       -Dacl=false \
                       -Daudit=false \
                       -Dblkid=true \
                       -Dkmod=true \
                       -Dpam=false \
                       -Dmicrohttpd=false \
                       -Dlibcryptsetup=false \
                       -Dlibcurl=false \
                       -Dlibidn=false \
                       -Dlibidn2=true \
                       -Dlibiptc=false \
                       -Dqrencode=false \
                       -Dgcrypt=false \
                       -Dgnutls=false \
                       -Dopenssl=false \
                       -Delfutils=false \
                       -Dzlib=false \
                       -Dbzip2=false \
                       -Dxz=false \
                       -Dlz4=false \
                       -Dxkbcommon=false \
                       -Dpcre2=false \
                       -Dglib=false \
                       -Ddbus=false \
                       -Ddefault-dnssec=no \
                       -Dimportd=false \
                       -Dremote=false \
                       -Dutmp=false \
                       -Dhibernate=false \
                       -Denvironment-d=false \
                       -Dbinfmt=false \
                       -Dcoredump=false \
                       -Dresolve=false \
                       -Dlogind=true \
                       -Dhostnamed=true \
                       -Dlocaled=false \
                       -Dmachined=false \
                       -Dnetworkd=false \
                       -Dtimedated=false \
                       -Dtimesyncd=true \
                       -Dfirstboot=false \
                       -Drandomseed=false \
                       -Dbacklight=false \
                       -Dvconsole=false \
                       -Dquotacheck=false \
                       -Dsysusers=false \
                       -Dtmpfiles=true \
                       -Dhwdb=true \
                       -Drfkill=false \
                       -Dldconfig=false \
                       -Defi=false \
                       -Dtpm=false \
                       -Dima=false \
                       -Dsmack=false \
                       -Dgshadow=false \
                       -Didn=false \
                       -Dnss-myhostname=false \
                       -Dnss-mymachines=false \
                       -Dnss-resolve=false \
                       -Dnss-systemd=false \
                       -Dman=false \
                       -Dhtml=false \
                       -Dbashcompletiondir=no \
                       -Dzshcompletiondir=no \
                       -Dkmod-path=/usr/bin/kmod \
                       -Dmount-path=/usr/bin/mount \
                       -Dumount-path=/usr/bin/umount \
                       -Ddebug-tty=$DEBUG_TTY \
                       -Dversion-tag=${PKG_VERSION}"

pre_configure_target() {
  export CFLAGS="$CFLAGS -fno-schedule-insns -fno-schedule-insns2 -Wno-format-truncation"
  export LC_ALL=en_US.UTF-8
}

post_makeinstall_target() {
  # remove unneeded stuff
  safe_remove $INSTALL/etc/init.d
  safe_remove $INSTALL/etc/pam.d
  safe_remove $INSTALL/etc/systemd/system
  safe_remove $INSTALL/etc/xdg
  safe_remove $INSTALL/etc/X11
  safe_remove $INSTALL/usr/bin/kernel-install
  safe_remove $INSTALL/usr/lib/kernel/install.d
  safe_remove $INSTALL/usr/lib/rpm
  safe_remove $INSTALL/usr/lib/systemd/user
  safe_remove $INSTALL/usr/lib/tmpfiles.d/etc.conf
  safe_remove $INSTALL/usr/lib/tmpfiles.d/home.conf
  safe_remove $INSTALL/usr/share/factory

  # clean up hwdb
  safe_remove $INSTALL/usr/lib/udev/hwdb.d/20-OUI.hwdb
  safe_remove $INSTALL/usr/lib/udev/hwdb.d/20-acpi-vendor.hwdb
  safe_remove $INSTALL/usr/lib/udev/hwdb.d/20-bluetooth-vendor-product.hwdb
  safe_remove $INSTALL/usr/lib/udev/hwdb.d/20-net-ifname.hwdb
  safe_remove $INSTALL/usr/lib/udev/hwdb.d/20-sdio-classes.hwdb
  safe_remove $INSTALL/usr/lib/udev/hwdb.d/20-sdio-vendor-model.hwdb

  # remove Network adaper renaming rule, this is confusing
  safe_remove $INSTALL/usr/lib/udev/rules.d/80-net-setup-link.rules

  # remove the uaccess rules as we don't build systemd with ACL (see https://github.com/systemd/systemd/issues/4107)
  safe_remove $INSTALL/usr/lib/udev/rules.d/71-seat.rules
  safe_remove $INSTALL/usr/lib/udev/rules.d/73-seat-late.rules

  # remove getty units, we dont want a console
  safe_remove $INSTALL/usr/lib/systemd/system/autovt@.service
  safe_remove $INSTALL/usr/lib/systemd/system/console-getty.service
  safe_remove $INSTALL/usr/lib/systemd/system/container-getty@.service
  safe_remove $INSTALL/usr/lib/systemd/system/getty.target
  safe_remove $INSTALL/usr/lib/systemd/system/getty@.service
  safe_remove $INSTALL/usr/lib/systemd/system/serial-getty@.service
  safe_remove $INSTALL/usr/lib/systemd/system/*.target.wants/getty.target

  # remove other notused or nonsense stuff (our /etc is ro)
  safe_remove $INSTALL/usr/lib/systemd/systemd-update-done
  safe_remove $INSTALL/usr/lib/systemd/system/systemd-update-done.service
  safe_remove $INSTALL/usr/lib/systemd/system/*.target.wants/systemd-update-done.service

  # remove nspawn
  safe_remove $INSTALL/usr/bin/systemd-nspawn
  safe_remove $INSTALL/usr/lib/systemd/system/systemd-nspawn@.service

  # remove unneeded generators
  for gen in $INSTALL/usr/lib/systemd/system-generators/*; do
    case "$gen" in
      */systemd-debug-generator)
        # keep it
        ;;
      *)
        safe_remove "$gen"
        ;;
    esac
  done

  # remove catalog
  safe_remove $INSTALL/usr/lib/systemd/catalog

  # remove partition
  safe_remove $INSTALL/usr/lib/systemd/systemd-growfs
  safe_remove $INSTALL/usr/lib/systemd/systemd-makefs

  # distro preset policy
  safe_remove $INSTALL/usr/lib/systemd/system-preset/*
  echo "disable *" > $INSTALL/usr/lib/systemd/system-preset/99-default.preset

  safe_remove $INSTALL/usr/lib/systemd/user-preset/*
  echo "disable *" > $INSTALL/usr/lib/systemd/user-preset/90-systemd.preset

  # remove networkd
  safe_remove $INSTALL/usr/lib/systemd/network

  # remove systemd-time-wait-sync (not detecting slew time updates, using package wait-time-sync)
  safe_remove $INSTALL/usr/lib/systemd/system/systemd-time-wait-sync.service
  safe_remove $INSTALL/usr/lib/systemd/systemd-time-wait-sync

  # tune journald.conf
  sed -e "s,^.*Compress=.*$,Compress=no,g" -i $INSTALL/etc/systemd/journald.conf
  sed -e "s,^.*SplitMode=.*$,SplitMode=none,g" -i $INSTALL/etc/systemd/journald.conf
  sed -e "s,^.*RuntimeMaxUse=.*$,RuntimeMaxUse=2M,g" -i $INSTALL/etc/systemd/journald.conf
  sed -e "s,^.*RuntimeMaxFileSize=.*$,RuntimeMaxFileSize=128K,g" -i $INSTALL/etc/systemd/journald.conf
  sed -e "s,^.*SystemMaxUse=.*$,SystemMaxUse=10M,g" -i $INSTALL/etc/systemd/journald.conf

  # tune logind.conf
  sed -e "s,^.*HandleLidSwitch=.*$,HandleLidSwitch=ignore,g" -i $INSTALL/etc/systemd/logind.conf
  sed -e "s,^.*HandlePowerKey=.*$,HandlePowerKey=ignore,g" -i $INSTALL/etc/systemd/logind.conf

  # replace systemd-machine-id-setup with ours
  safe_remove $INSTALL/usr/lib/systemd/system/systemd-machine-id-commit.service
  safe_remove $INSTALL/usr/lib/systemd/system/*.target.wants/systemd-machine-id-commit.service
  safe_remove $INSTALL/usr/bin/systemd-machine-id-setup
  mkdir -p $INSTALL/usr/bin
  cp $PKG_DIR/scripts/systemd-machine-id-setup $INSTALL/usr/bin
  cp $PKG_DIR/scripts/userconfig-setup $INSTALL/usr/bin
  cp $PKG_DIR/scripts/usercache-setup $INSTALL/usr/bin

  mkdir -p $INSTALL/usr/sbin
  cp $PKG_DIR/scripts/kernel-overlays-setup $INSTALL/usr/sbin
  cp $PKG_DIR/scripts/network-base-setup $INSTALL/usr/sbin
  cp $PKG_DIR/scripts/systemd-timesyncd-setup $INSTALL/usr/sbin

  # /etc/resolv.conf and /etc/hosts must be writable
  ln -sf /run/libreelec/resolv.conf $INSTALL/etc/resolv.conf
  ln -sf /run/libreelec/hosts $INSTALL/etc/hosts

  # provide 'halt', 'shutdown', 'reboot' & co.
  ln -sf /usr/bin/systemctl $INSTALL/usr/sbin/halt
  ln -sf /usr/bin/systemctl $INSTALL/usr/sbin/poweroff
  ln -sf /usr/bin/systemctl $INSTALL/usr/sbin/reboot
  ln -sf /usr/bin/systemctl $INSTALL/usr/sbin/runlevel
  ln -sf /usr/bin/systemctl $INSTALL/usr/sbin/shutdown
  ln -sf /usr/bin/systemctl $INSTALL/usr/sbin/telinit

  # strip
  debug_strip $INSTALL/usr

  # defaults
  mkdir -p $INSTALL/usr/config
  cp -PR $PKG_DIR/config/* $INSTALL/usr/config

  safe_remove $INSTALL/etc/modules-load.d
  ln -sf /storage/.config/modules-load.d $INSTALL/etc/modules-load.d
  ln -sf /storage/.config/logind.conf.d $INSTALL/etc/systemd/logind.conf.d
  ln -sf /storage/.config/sleep.conf.d $INSTALL/etc/systemd/sleep.conf.d
  ln -sf /storage/.config/timesyncd.conf.d $INSTALL/etc/systemd/timesyncd.conf.d
  safe_remove $INSTALL/etc/sysctl.d
  ln -sf /storage/.config/sysctl.d $INSTALL/etc/sysctl.d
  safe_remove $INSTALL/etc/tmpfiles.d
  ln -sf /storage/.config/tmpfiles.d $INSTALL/etc/tmpfiles.d
  safe_remove $INSTALL/etc/udev/hwdb.d
  ln -sf /storage/.config/hwdb.d $INSTALL/etc/udev/hwdb.d
  safe_remove $INSTALL/etc/udev/rules.d
  ln -sf /storage/.config/udev.rules.d $INSTALL/etc/udev/rules.d
}

post_install() {
  add_group systemd-journal 190

  add_group systemd-timesync 191
  add_user systemd-timesync x 191 191 "systemd-timesync" "/" "/bin/false"

  add_group systemd-network 193
  add_user systemd-network x 193 193 "systemd-network" "/" "/bin/sh"

  add_group audio 63
  add_group cdrom 11
  add_group dialout 18
  add_group disk 6
  add_group floppy 19
  add_group kmem 9
  add_group lp 7
  add_group tape 33
  add_group tty 5
  add_group video 39
  add_group utmp 22
  add_group input 199

  enable_service machine-id.service
  enable_service debugconfig.service
  enable_service userconfig.service
  enable_service usercache.service
  enable_service kernel-overlays.service
  enable_service hwdb.service
  enable_service network-base.service
  enable_service systemd-timesyncd.service
  enable_service systemd-timesyncd-setup.service
  enable_service debug-shell.service
}
