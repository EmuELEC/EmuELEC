# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-tools"
PKG_VERSION=""
PKG_LICENSE="various"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain busybox wget coreutils grep bash"
PKG_SHORTDESC="EmuELEC tools metapackage"
PKG_NEED_UNPACK="$(get_pkg_directory busybox) $(get_pkg_directory wget) $(get_pkg_directory grep) $(get_pkg_directory coreutils) $(get_pkg_directory bash)"
PKG_TOOLCHAIN="manual"

PKG_DEPENDS_TARGET+=" ffmpeg \
                      libjpeg-turbo \
                      curl \
                      common-shaders \
                      Skyscraper \
                      MC \
                      libretro-bash-launcher \
                      SDL_GameControllerDB \
                      util-linux \
                      xmlstarlet \
                      sixaxis \
                      jslisten \
                      evtest \
                      mpv \
                      poppler \
                      bluetool \
                      patchelf \
                      fbgrab \
                      sdljoytest \
                      bash \
                      pyudev \
                      dialog \
                      six \
                      git \
                      dbus-python \
                      pygobject \
                      coreutils \
                      wget \
                      TvTextViewer \
                      imagemagick \
                      htop \
                      libevdev \
                      gptokeyb \
                      exfat \
                      351Files \
                      box64 \
                      iotop \
                      usb-modeswitch \
                      vim \
                      rclone \
                      grep \
                      eemount \
                      dasbus \
                      diffutils \
                      fbfix \
                      munt \
                      munt_alsadrv \
                      python-uinput \
                      python-evdev \
                      xow \
                      progressor \
                      timidity \
                      sdlterm \
                      btop"

if [ "${PROJECT}" == "Amlogic-ce" ]; then
                      PKG_DEPENDS_TARGET+=" CoreELEC-Debug-Scripts"
fi

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	  
  #we disable some tools that are not working HH
	for discore in xow; do
		PKG_DEPENDS_TARGET=$(echo ${PKG_DEPENDS_TARGET} | sed "s|${discore} | |")
	done
fi


post_install() {
  rm -f ${INSTALL}/usr/bin/{sort,wget,grep}
  cp $(get_install_dir wget)/usr/bin/wget ${INSTALL}/usr/bin
  cp $(get_install_dir coreutils)/usr/bin/sort ${INSTALL}/usr/bin
  cp $(get_install_dir grep)/usr/bin/grep ${INSTALL}/usr/bin
  ln -sf /usr/bin/bash ${INSTALL}/usr/bin/sh
  find ${INSTALL}/usr/ -type f -iname "*.sh" -exec chmod +x {} \;
}


