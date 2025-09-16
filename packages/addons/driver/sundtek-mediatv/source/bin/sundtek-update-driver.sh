#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)

. /etc/profile

SUNDTEK_ADDON_DIR="$HOME/.kodi/addons/driver.dvb.sundtek-mediatv"
SUNDTEK_ADDON_HOME="$HOME/.kodi/userdata/addon_data/driver.dvb.sundtek-mediatv"
SUNDTEK_ADDON_SETTINGS="$SUNDTEK_ADDON_HOME/settings.xml"

trap_exit_install() {
  kodi-send -a "Notification(Sundtek, Something went wrong. Cleaning..., 8000, $SUNDTEK_ADDON_DIR/icon.png)"
  cd "$SUNDTEK_ADDON_DIR"
  rm -fr tmp
  exit 5
}

# kill process
systemctl stop driver.dvb.sundtek-mediatv
killall -9 mediaclient &>/dev/null
killall -9 mediasrv &>/dev/null

# remove the entry
BUILD_DATE="#"
sed -i "s|\(id=\"BUILD_DATE\" .* values=\)\"[^\"]*\"|\1\"$BUILD_DATE\"|" $SUNDTEK_ADDON_DIR/resources/settings.xml

# exit on errors
set -e

trap trap_exit_install EXIT

cd "$SUNDTEK_ADDON_DIR"
rm -fr tmp
mkdir tmp
cd tmp

logger -t Sundtek "### Starting updating driver ###"
kodi-send -a "Notification(Sundtek, Starting updating driver, 3000, $SUNDTEK_ADDON_DIR/icon.png)"

wget -O ../version.used http://sundtek.de/media/latest.phtml
if [ $? -ne 0 ]; then
  logger -t Sundtek "### Can't get latest version ###"
  kodi-send -a "Notification(Sundtek, Cant get latest version, 8000, $SUNDTEK_ADDON_DIR/icon.png)"
  cd ..
  rm -fr tmp/
  exit 1
fi

ARCH=$(sed -n 's|[^.]*\.\([^-]*\)-.*|\1|p' /etc/release | tr -d '\n')
if [ "$ARCH" = "x86_64" ]; then
  INSTALLER_URL="http://sundtek.de/media/netinst/64bit/installer.tar.gz"
elif [ "$ARCH" = "arm" ]; then
  INSTALLER_URL="http://sundtek.de/media/netinst/armsysvhf/installer.tar.gz"
elif [ "$ARCH" = "aarch64" ]; then
  INSTALLER_URL="http://sundtek.de/media/netinst/arm64/installer.tar.gz"
else
  logger -t Sundtek "### Unsupported architecture ###"
  kodi-send -a "Notification(Sundtek, Unsupported architecture, 8000, $SUNDTEK_ADDON_DIR/icon.png)"
  cd ..
  rm -fr tmp
  exit 2
fi

logger -t Sundtek "### Downloading driver archive for $ARCH ###"
kodi-send -a "Notification(Sundtek, Downloading driver archive for $ARCH, 3000, $SUNDTEK_ADDON_DIR/icon.png)"
wget -O installer.tar.gz $INSTALLER_URL
if [ $? -ne 0 ]; then
  logger -t Sundtek "### Archive damaged ###"
  kodi-send -a "Notification(Sundtek, Download failed, 8000, $SUNDTEK_ADDON_DIR/icon.png)"
  cd ..
  rm -fr tmp/
  exit 3
fi

logger -t Sundtek "### Extracting archive ###"
kodi-send -a "Notification(Sundtek, Extracting archive, 3000, $SUNDTEK_ADDON_DIR/icon.png)"
tar -xzf installer.tar.gz
if [ $? -ne 0 ]; then
  logger -t Sundtek "### Archive damaged ###"
  kodi-send -a "Notification(Sundtek, Archive damaged, 8000, $SUNDTEK_ADDON_DIR/icon.png)"
  cd ..
  rm -fr tmp/
  exit 4
fi

# fix permissions
chmod -R 755 opt/ etc/

rm -f  opt/bin/getinput.sh
rm -f  opt/bin/lirc.sh
rm -fr opt/lib/pm/

cp -Pa opt/bin/* ../bin/
cp -Pa opt/lib/* ../lib/

cd ..
rm -fr tmp

logger -t Sundtek "### Driver update finished ###"
kodi-send -a "Notification(Sundtek, Driver update finished, 5000, $SUNDTEK_ADDON_DIR/icon.png)"
kodi-send -a "Notification(Sundtek, Please reboot, 5000, $SUNDTEK_ADDON_DIR/icon.png)"

trap - EXIT

systemctl start driver.dvb.sundtek-mediatv

exit 0
