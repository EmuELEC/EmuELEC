# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.tv)

PKG_NAME="kodi"
PKG_VERSION="513bcee15b79c4b75dabaf054f89f1aacd256248"
PKG_SHA256="343f3b132903ed1c4057380592029639ac556f20a576a91b06b7a654d54e7a28"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kodi.tv"
PKG_URL="https://github.com/CoreELEC/xbmc/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain JsonSchemaBuilder:host TexturePacker:host Python3 zlib systemd lzo pcre swig:host libass curl fontconfig fribidi tinyxml libjpeg-turbo freetype libcdio taglib libxml2 libxslt rapidjson sqlite ffmpeg crossguid libfmt lirc libfstrcmp flatbuffers:host flatbuffers libudfread spdlog obu_util"
PKG_DEPENDS_HOST="toolchain"
PKG_LONGDESC="A free and open source cross-platform media player."
PKG_BUILD_FLAGS="+speed"

post_unpack() {
  if [ -f ${DISTRO_DIR}/${DISTRO}/splash/${DEVICE}/splash-1080.png ]; then
    rm -rf $(get_build_dir ${PKG_NAME})/media/splash.*
    cp -PR ${DISTRO_DIR}/${DISTRO}/splash/${DEVICE}/splash-1080.png $(get_build_dir ${PKG_NAME})/media/splash.png
  fi

  sed -e "s|@ADDON_REPO_ID@|${ADDON_REPO_ID}|g" -i $(get_build_dir ${PKG_NAME})/version.txt
  sed -e "s|@ADDON_SERVER_URL@|${ADDON_SERVER_URL}|g" -i $(get_build_dir ${PKG_NAME})/version.txt

  # don't build internal TexturePacker
  sed -i 's|set(INTERNAL_TEXTUREPACKER_INSTALLABLE TRUE|set(INTERNAL_TEXTUREPACKER_INSTALLABLE FALSE|' \
    $(get_build_dir ${PKG_NAME})/cmake/modules/buildtools/FindTexturePacker.cmake
}

configure_package() {
  # Single threaded LTO is very slow so rely on Kodi for parallel LTO support
  if [ "${LTO_SUPPORT}" = "yes" ] && ! build_with_debug; then
    PKG_KODI_USE_LTO="-DUSE_LTO=${CONCURRENCY_MAKE_LEVEL}"
  fi

  # Set linker options
  case $(get_target_linker) in
    gold)
      PKG_KODI_LINKER="-DENABLE_GOLD=ON \
                       -DENABLE_MOLD=OFF"
      ;;
    mold)
      PKG_KODI_LINKER="-DENABLE_GOLD=OFF \
                       -DENABLE_MOLD=ON \
                       -DMOLD_EXECUTABLE=${TOOLCHAIN}/${TARGET_NAME}/bin/mold"
      ;;
    *)
      PKG_KODI_LINKER="-DENABLE_GOLD=OFF \
                       -DENABLE_MOLD=OFF"
      ;;
  esac

  get_graphicdrivers

  PKG_DEPENDS_TARGET+=" dbus"

  if [ "${DEVICE}" = "Amlogic-ng-dv" ]; then
    PKG_DEPENDS_TARGET+=" libdovi"
    PKG_CMAKE_OPTS_TARGET+=" -DENABLE_LIBDOVI=ON"
  fi

  if [ "${DISPLAYSERVER}" = "x11" ]; then
    PKG_DEPENDS_TARGET+=" libX11 libXext libdrm libXrandr"
    KODI_PLATFORM="-DCORE_PLATFORM_NAME=x11 \
                   -DAPP_RENDER_SYSTEM=gl"
  elif [ "${DISPLAYSERVER}" = "wl" ]; then
    PKG_DEPENDS_TARGET+=" wayland waylandpp"
    PKG_PATCH_DIRS+=" wayland"
    CFLAGS+=" -DEGL_NO_X11"
    CXXFLAGS+=" -DEGL_NO_X11"
    KODI_PLATFORM="-DCORE_PLATFORM_NAME=wayland \
                   -DAPP_RENDER_SYSTEM=gles \
                   -DWAYLANDPP_SCANNER=${TOOLCHAIN}/bin/wayland-scanner++ \
                   -DWAYLANDPP_PROTOCOLS_DIR=${SYSROOT_PREFIX}/usr/share/waylandpp/protocols"
  fi

  if [ ! "${OPENGL}" = "no" ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
  fi

  if [ "${OPENGLES_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  fi

  if [ "${KODI_ALSA_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" alsa-lib"
    KODI_ALSA="-DENABLE_ALSA=ON"
  else
    KODI_ALSA="-DENABLE_ALSA=OFF"
 fi

  if [ "${KODI_PULSEAUDIO_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" pulseaudio"
    KODI_PULSEAUDIO="-DENABLE_PULSEAUDIO=ON"
  else
    KODI_PULSEAUDIO="-DENABLE_PULSEAUDIO=OFF"
  fi

  if [ "${ESPEAK_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" espeak-ng"
  fi

  if [ "${KODI_PIPEWIRE_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" pipewire"
    KODI_PIPEWIRE="-DENABLE_PIPEWIRE=ON"

    if [ "${KODI_PULSEAUDIO_SUPPORT}" = "yes" -o "${KODI_ALSA_SUPPORT}" = "yes" ]; then
      die "KODI_PULSEAUDIO_SUPPORT and KODI_ALSA_SUPPORT cannot be used with KODI_PIPEWIRE_SUPPORT"
    fi
  else
    KODI_PIPEWIRE="-DENABLE_PIPEWIRE=OFF"
  fi

  if [ "${CEC_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libcec"
    KODI_CEC="-DENABLE_CEC=ON"
  else
    KODI_CEC="-DENABLE_CEC=OFF"
  fi

  if [ "${CEC_FRAMEWORK_SUPPORT}" = "yes" ]; then
    PKG_PATCH_DIRS+=" cec-framework"
  fi

  if [ "${KODI_OPTICAL_SUPPORT}" = yes ]; then
    KODI_OPTICAL="-DENABLE_OPTICAL=ON"
  else
    KODI_OPTICAL="-DENABLE_OPTICAL=OFF"
  fi

  if [ "${KODI_BLURAY_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libbluray"
    KODI_BLURAY="-DENABLE_BLURAY=ON"
  else
    KODI_BLURAY="-DENABLE_BLURAY=OFF"
  fi

  if [ "${AVAHI_DAEMON}" = yes ]; then
    PKG_DEPENDS_TARGET+=" avahi nss-mdns"
    KODI_AVAHI="-DENABLE_AVAHI=ON"
  else
    KODI_AVAHI="-DENABLE_AVAHI=OFF"
  fi

  case "${KODI_MYSQL_SUPPORT}" in
    mysql)   PKG_DEPENDS_TARGET+=" mysql"
             KODI_MYSQL="-DENABLE_MYSQLCLIENT=ON -DENABLE_MARIADBCLIENT=OFF"
             ;;
    mariadb) PKG_DEPENDS_TARGET+=" mariadb-connector-c"
             KODI_MYSQL="-DENABLE_MARIADBCLIENT=ON -DENABLE_MYSQLCLIENT=OFF"
             ;;
    *)       KODI_MYSQL="-DENABLE_MYSQLCLIENT=OFF -DENABLE_MARIADBCLIENT=OFF"
  esac

  if [ "${KODI_AIRPLAY_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libplist"
    KODI_AIRPLAY="-DENABLE_PLIST=ON"
  else
    KODI_AIRPLAY="-DENABLE_PLIST=OFF"
  fi

  if [ "${KODI_AIRTUNES_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libshairplay"
    KODI_AIRTUNES="-DENABLE_AIRTUNES=ON"
  else
    KODI_AIRTUNES="-DENABLE_AIRTUNES=OFF"
  fi

  if [ "${KODI_NFS_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libnfs"
    KODI_NFS="-DENABLE_NFS=ON"
  else
    KODI_NFS="-DENABLE_NFS=OFF"
  fi

  if [ "${KODI_SAMBA_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" samba"
    KODI_SAMBA="-DENABLE_SMBCLIENT=ON"
  else
    KODI_SAMBA="-DENABLE_SMBCLIENT=OFF"
  fi

  if [ "${KODI_WEBSERVER_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libmicrohttpd"
  fi

  if [ "${KODI_UPNP_SUPPORT}" = yes ]; then
    KODI_UPNP="-DENABLE_UPNP=ON"
  else
    KODI_UPNP="-DENABLE_UPNP=OFF"
  fi

  if [ "${TARGET_ARCH}" = "aarch64" -o "${TARGET_ARCH}" = "arm" ]; then
    if target_has_feature neon; then
      KODI_NEON="-DENABLE_NEON=ON"
    else
      KODI_NEON="-DENABLE_NEON=OFF"
    fi
  else
    KODI_NEON=""
  fi

  if [ "${VDPAU_SUPPORT}" = "yes" -a "${DISPLAYSERVER}" = "x11" ]; then
    PKG_DEPENDS_TARGET+=" libvdpau"
    KODI_VDPAU="-DENABLE_VDPAU=ON"
  else
    KODI_VDPAU="-DENABLE_VDPAU=OFF"
  fi

  if [ "${VAAPI_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" libva"
    KODI_VAAPI="-DENABLE_VAAPI=ON"
  else
    KODI_VAAPI="-DENABLE_VAAPI=OFF"
  fi

  if [ "${TARGET_ARCH}" = "x86_64" ]; then
    KODI_ARCH="-DWITH_CPU=${TARGET_ARCH}"
  else
    KODI_ARCH="-DWITH_ARCH=${TARGET_ARCH}"
  fi

  if [ ! "${KODIPLAYER_DRIVER}" = "default" -a "${DISPLAYSERVER}" = "no" ]; then
    PKG_DEPENDS_TARGET+=" ${KODIPLAYER_DRIVER} libinput libxkbcommon"
    if [ "${OPENGLES_SUPPORT}" = yes -a "${KODIPLAYER_DRIVER}" = "${OPENGLES}" ]; then
      KODI_PLATFORM="-DCORE_PLATFORM_NAME=gbm -DAPP_RENDER_SYSTEM=gles"
      CFLAGS+=" -DEGL_NO_X11"
      CXXFLAGS+=" -DEGL_NO_X11"
      if [ "${PROJECT}" = "Generic" ]; then
        PKG_APPLIANCE_XML="${PKG_DIR}/config/appliance-gbm-generic.xml"
      else
        PKG_APPLIANCE_XML="${PKG_DIR}/config/appliance-gbm.xml"
      fi
    elif [ "${KODIPLAYER_DRIVER}" = libamcodec ]; then
      KODI_PLATFORM="-DCORE_PLATFORM_NAME=aml -DAPP_RENDER_SYSTEM=gles"
      PKG_APPLIANCE_XML_G12X="${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/g12x/appliance.xml"
      PKG_APPLIANCE_XML_GXX="${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/gxx/appliance.xml"
    fi
  fi

  PKG_CMAKE_OPTS_TARGET="-DNATIVEPREFIX=${TOOLCHAIN} \
                         -DWITH_TEXTUREPACKER=${TOOLCHAIN}/bin/TexturePacker \
                         -DWITH_JSONSCHEMABUILDER=${TOOLCHAIN}/bin/JsonSchemaBuilder \
                         -DDEPENDS_PATH=${PKG_BUILD}/depends \
                         -DSWIG_EXECUTABLE=${TOOLCHAIN}/bin/swig \
                         -DPYTHON_EXECUTABLE=${TOOLCHAIN}/bin/${PKG_PYTHON_VERSION} \
                         -DPYTHON_INCLUDE_DIRS=${SYSROOT_PREFIX}/usr/include/${PKG_PYTHON_VERSION} \
                         -DGIT_VERSION=${PKG_VERSION} \
                         -DFFMPEG_PATH=${SYSROOT_PREFIX}/usr \
                         -DENABLE_INTERNAL_FFMPEG=OFF \
                         -DENABLE_INTERNAL_CROSSGUID=OFF \
                         -DENABLE_INTERNAL_UDFREAD=OFF \
                         -DENABLE_INTERNAL_SPDLOG=OFF \
                         -DENABLE_INTERNAL_RapidJSON=OFF \
                         -DENABLE_UDEV=ON \
                         -DENABLE_DBUS=ON \
                         -DENABLE_XSLT=ON \
                         -DENABLE_CCACHE=OFF \
                         -DENABLE_LIRCCLIENT=ON \
                         -DENABLE_EVENTCLIENTS=ON \
                         -DENABLE_DEBUGFISSION=OFF \
                         -DENABLE_APP_AUTONAME=OFF \
                         -DENABLE_TESTING=OFF \
                         -DENABLE_INTERNAL_FLATBUFFERS=OFF \
                         -DENABLE_LCMS2=OFF \
                         -DADDONS_CONFIGURE_AT_STARTUP=OFF \
                         ${PKG_KODI_USE_LTO} \
                         ${PKG_KODI_LINKER} \
                         ${KODI_ARCH} \
                         ${KODI_NEON} \
                         ${KODI_VDPAU} \
                         ${KODI_VAAPI} \
                         ${KODI_CEC} \
                         ${KODI_PLATFORM} \
                         ${KODI_SAMBA} \
                         ${KODI_NFS} \
                         ${KODI_AVAHI} \
                         ${KODI_UPNP} \
                         ${KODI_MYSQL} \
                         ${KODI_AIRPLAY} \
                         ${KODI_AIRTUNES} \
                         ${KODI_OPTICAL} \
                         ${KODI_BLURAY} \
                         ${KODI_ALSA} \
                         ${KODI_PULSEAUDIO} \
                         ${KODI_PIPEWIRE}"
}

prepare_libdvd_library() {
  # arg1 is library name libdvdcss/libdvdnav/libdvdread
  local LIBRARY_VERSION="$(awk -F= '/VERSION=/ {print $2}' ${PKG_BUILD}/tools/depends/target/${1}/${1^^}-VERSION)"
  local LIBRARY_SHA512="$(awk  -F= '/SHA512=/  {print $2}' ${PKG_BUILD}/tools/depends/target/${1}/${1^^}-VERSION)"
  local LIBRARY_ARCHIVE="${SOURCES}/${1}/${1}-${LIBRARY_VERSION}.tar.gz"

  if [ -f "${LIBRARY_ARCHIVE}" ]; then
    local LIBRARY_ARCHIVE_SHA512="$(sha512sum "${LIBRARY_ARCHIVE}" | cut -d ' ' -f 1)"
    if [ "${LIBRARY_ARCHIVE_SHA512}" = "${LIBRARY_SHA512}" ]; then
      KODI_LIBDVD+=" -D${1^^}_URL=${LIBRARY_ARCHIVE}"
    fi
  fi
}

configure_host() {
  setup_toolchain target:cmake
  cmake ${CMAKE_GENERATOR_NINJA} \
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CONF} \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
        -DHEADERS_ONLY=ON \
        ${KODI_ARCH} \
        ${KODI_NEON} \
        ${KODI_PLATFORM} ..
}

make_host() {
  :
}

makeinstall_host() {
  DESTDIR=${SYSROOT_PREFIX} cmake -DCMAKE_INSTALL_COMPONENT="kodi-addon-dev" -P cmake_install.cmake

  # more binaddons cross compile badness meh
  sed -e "s:INCLUDE_DIR /usr/include/kodi:INCLUDE_DIR ${SYSROOT_PREFIX}/usr/include/kodi:g" \
      -e "s:CMAKE_MODULE_PATH /usr/lib/kodi /usr/share/kodi/cmake:CMAKE_MODULE_PATH ${SYSROOT_PREFIX}/usr/share/kodi/cmake:g" \
      -i ${SYSROOT_PREFIX}/usr/lib/kodi/cmake/KodiConfig.cmake
}

pre_configure_target() {
  export LIBS="${LIBS} -lncurses"

  if [ "${KODI_DVDCSS_SUPPORT}" = yes ]; then
    KODI_LIBDVD="-DENABLE_DVDCSS=ON"
    prepare_libdvd_library libdvdcss
  else
    KODI_LIBDVD="-DENABLE_DVDCSS=OFF"
  fi

  prepare_libdvd_library libdvdnav
  prepare_libdvd_library libdvdread
  PKG_CMAKE_OPTS_TARGET+=" ${KODI_LIBDVD}"
}

post_make_target() {
  for libname in libdvdcss libdvdnav libdvdread; do
    mkdir -p "${SOURCES}/${libname}"
    cp "${PKG_BUILD}/.${TARGET_NAME}/build/download/${libname}"* "${SOURCES}/${libname}" || :
  done
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/.noinstall
    mv ${INSTALL}/usr/share/kodi/addons/skin.estouchy \
       ${INSTALL}/usr/share/kodi/addons/skin.estuary \
       ${INSTALL}/usr/share/kodi/addons/service.xbmc.versioncheck \
       ${INSTALL}/.noinstall

  rm -rf ${INSTALL}/usr/bin/kodi
  rm -rf ${INSTALL}/usr/bin/kodi-standalone
  rm -rf ${INSTALL}/usr/bin/xbmc
  rm -rf ${INSTALL}/usr/bin/xbmc-standalone
  rm -rf ${INSTALL}/usr/share/kodi/cmake
  rm -rf ${INSTALL}/usr/share/applications
  rm -rf ${INSTALL}/usr/share/icons
  rm -rf ${INSTALL}/usr/share/pixmaps
  rm -rf ${INSTALL}/usr/share/xsessions

  mkdir -p ${INSTALL}/usr/lib/kodi
    cp ${PKG_DIR}/scripts/kodi-config ${INSTALL}/usr/lib/kodi
    cp ${PKG_DIR}/scripts/kodi-after ${INSTALL}/usr/lib/kodi
    cp ${PKG_DIR}/scripts/kodi-safe-mode ${INSTALL}/usr/lib/kodi
    cp ${PKG_DIR}/scripts/kodi.sh ${INSTALL}/usr/lib/kodi

  if [ "${PROJECT}" = "Amlogic-ce" ]; then
    cp ${PKG_DIR}/scripts/aml-wait-for-dispcap.sh ${INSTALL}/usr/lib/kodi
  fi

    # Configure safe mode triggers - default 5 restarts within 900 seconds/15 minutes
    sed -e "s|@KODI_MAX_RESTARTS@|${KODI_MAX_RESTARTS:-5}|g" \
        -e "s|@KODI_MAX_SECONDS@|${KODI_MAX_SECONDS:-900}|g" \
        -i ${INSTALL}/usr/lib/kodi/kodi.sh

    if [ "${KODI_PIPEWIRE_SUPPORT}" = "yes" ]; then
      KODI_AE_SINK="PIPEWIRE"
    elif [ "${KODI_PULSEAUDIO_SUPPORT}" = "yes" -a "${KODI_ALSA_SUPPORT}" = "yes" ]; then
      KODI_AE_SINK="ALSA+PULSE"
    elif [ "${KODI_PULSEAUDIO_SUPPORT}" = "yes" -a "${KODI_ALSA_SUPPORT}" != "yes" ]; then
      KODI_AE_SINK="PULSE"
    elif [ "${KODI_PULSEAUDIO_SUPPORT}" != "yes" -a "${KODI_ALSA_SUPPORT}" = "yes" ]; then
      KODI_AE_SINK="ALSA"
    fi

    # adjust audio output device to what was built
    sed "s/@KODI_AE_SINK@/${KODI_AE_SINK}/" ${PKG_DIR}/config/kodi.conf.in > ${INSTALL}/usr/lib/kodi/kodi.conf

    # set default display environment
    if [ "${DISPLAYSERVER}" = "x11" ]; then
      echo "DISPLAY=:0.0" >> ${INSTALL}/usr/lib/kodi/kodi.conf
    elif [ "${DISPLAYSERVER}" = "wl" ]; then
      echo "WAYLAND_DISPLAY=wayland-1" >> ${INSTALL}/usr/lib/kodi/kodi.conf
    fi

    # nvidia: Enable USLEEP to reduce CPU load while rendering
    if listcontains "${GRAPHIC_DRIVERS}" "nvidia" || listcontains "${GRAPHIC_DRIVERS}" "nvidia-legacy"; then
      echo "__GL_YIELD=USLEEP" >> ${INSTALL}/usr/lib/kodi/kodi.conf
    fi

  mkdir -p ${INSTALL}/usr/sbin
    cp ${PKG_DIR}/scripts/service-addon-wrapper ${INSTALL}/usr/sbin

  mkdir -p ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/kodi-remote ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/setwakeup.sh ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/pastekodi ${INSTALL}/usr/bin
    ln -sf /usr/bin/pastekodi ${INSTALL}/usr/bin/pastecrash

  mkdir -p ${INSTALL}/usr/share/kodi/addons
    cp -R ${PKG_DIR}/config/repository.coreelec ${INSTALL}/usr/share/kodi/addons/${ADDON_REPO_ID}
    sed -e "s|@ADDON_URL@|${ADDON_URL}|g" -i ${INSTALL}/usr/share/kodi/addons/${ADDON_REPO_ID}/addon.xml
    sed -e "s|@ADDON_REPO_ID@|${ADDON_REPO_ID}|g" -i ${INSTALL}/usr/share/kodi/addons/${ADDON_REPO_ID}/addon.xml
    sed -e "s|@ADDON_REPO_NAME@|${ADDON_REPO_NAME}|g" -i ${INSTALL}/usr/share/kodi/addons/${ADDON_REPO_ID}/addon.xml
    sed -e "s|@ADDON_VERSION@|${ADDON_VERSION}|g" -i ${INSTALL}/usr/share/kodi/addons/${ADDON_REPO_ID}/addon.xml

  mkdir -p ${INSTALL}/usr/share/kodi/config

  ln -sf /run/libreelec/cacert.pem ${INSTALL}/usr/share/kodi/system/certs/cacert.pem

  mkdir -p ${INSTALL}/usr/share/kodi/system/settings

  ${PKG_DIR}/scripts/xml_merge.py ${PKG_DIR}/config/guisettings.xml \
                                ${PROJECT_DIR}/${PROJECT}/kodi/guisettings.xml \
                                ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/guisettings.xml \
                                > ${INSTALL}/usr/share/kodi/config/guisettings.xml

  ${PKG_DIR}/scripts/xml_merge.py ${PKG_DIR}/config/sources.xml \
                                ${PROJECT_DIR}/${PROJECT}/kodi/sources.xml \
                                ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/sources.xml \
                                > ${INSTALL}/usr/share/kodi/config/sources.xml

  ${PKG_DIR}/scripts/xml_merge.py ${PKG_DIR}/config/advancedsettings.xml \
                                ${PROJECT_DIR}/${PROJECT}/kodi/advancedsettings.xml \
                                ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/advancedsettings.xml \
                                > ${INSTALL}/usr/share/kodi/system/advancedsettings.xml

  ln -sf /var/share/kodi/system/settings/appliance.xml ${INSTALL}/usr/share/kodi/system/settings/appliance.xml

  ${PKG_DIR}/scripts/xml_merge.py ${PKG_DIR}/config/appliance.xml \
                                ${PKG_APPLIANCE_XML_G12X} \
                                ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/appliance.xml \
                                > ${INSTALL}/usr/share/kodi/system/settings/appliance.g12x.xml

  ${PKG_DIR}/scripts/xml_merge.py ${PKG_DIR}/config/appliance.xml \
                                ${PKG_APPLIANCE_XML_GXX} \
                                ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/kodi/appliance.xml \
                                > ${INSTALL}/usr/share/kodi/system/settings/appliance.gxx.xml

  mkdir -p ${INSTALL}/usr/cache/coreelec
    cp ${PKG_DIR}/config/network_wait ${INSTALL}/usr/cache/coreelec

  # update addon manifest
  ADDON_MANIFEST=${INSTALL}/usr/share/kodi/system/addon-manifest.xml
  xmlstarlet ed -L -d "/addons/addon[text()='service.xbmc.versioncheck']" ${ADDON_MANIFEST}
  xmlstarlet ed -L -d "/addons/addon[text()='skin.estouchy']" ${ADDON_MANIFEST}
  xmlstarlet ed -L --subnode "/addons" -t elem -n "addon" -v "${ADDON_REPO_ID}" ${ADDON_MANIFEST}
  if [ -n "${DISTRO_PKG_SETTINGS}" ]; then
    xmlstarlet ed -L --subnode "/addons" -t elem -n "addon" -v "${DISTRO_PKG_SETTINGS_ID}" ${ADDON_MANIFEST}
  fi

  # more binaddons cross compile badness meh
  sed -e "s:INCLUDE_DIR /usr/include/kodi:INCLUDE_DIR ${SYSROOT_PREFIX}/usr/include/kodi:g" \
      -e "s:CMAKE_MODULE_PATH /usr/lib/kodi /usr/share/kodi/cmake:CMAKE_MODULE_PATH ${SYSROOT_PREFIX}/usr/share/kodi/cmake:g" \
      -i ${SYSROOT_PREFIX}/usr/lib/kodi/cmake/KodiConfig.cmake

  if [ "${KODI_EXTRA_FONTS}" = yes ]; then
    mkdir -p ${INSTALL}/usr/share/kodi/media/Fonts
      cp ${PKG_DIR}/fonts/*.ttf ${INSTALL}/usr/share/kodi/media/Fonts
  fi

  # Compile kodi Python site-packages to .pyc bytecode, and remove .py source code
  python_compile ${INSTALL}/usr/lib/${PKG_PYTHON_VERSION}/site-packages/kodi

  debug_strip ${INSTALL}/usr/lib/kodi/kodi.bin
}

post_install() {
  enable_service kodi.target
  enable_service kodi-autostart.service
  enable_service kodi-cleanlogs.service
  enable_service kodi-halt.service
  enable_service kodi-poweroff.service
  enable_service kodi-reboot.service
  enable_service kodi-waitonnetwork.service
  enable_service kodi.service
  enable_service kodi-lirc-suspend.service
  enable_service kodi-cleanpackagecache.service
}
