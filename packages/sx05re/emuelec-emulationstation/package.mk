# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-emulationstation"
PKG_VERSION="cd0e21e16440255e5f8c284f1dea02d724382da1"
PKG_GIT_CLONE_BRANCH="EmuELEC"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/EmuELEC/emuelec-emulationstation"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 freetype freeimage vlc rapidjson ${OPENGLES} SDL2_mixer fping p7zip espeak"
PKG_SECTION="emuelec"
PKG_SHORTDESC="Emulationstation emulator frontend"
PKG_BUILD_FLAGS="-gold"
GET_HANDLER_SUPPORT="git"


if [[ ${DEVICE} == "OdroidGoAdvance"  ]] || [[ ${DEVICE} == "GameForce"  ]]; then 
	PKG_PATCH_DIRS="Rockchip/HH"
fi

if [[ ${DEVICE} == "OdroidM1"  ]] || [[ ${DEVICE} == "RK356x"  ]]; then 
	PKG_PATCH_DIRS="Rockchip"
fi

# themes for Emulationstation
PKG_DEPENDS_TARGET="${PKG_DEPENDS_TARGET} Crystal"

pre_configure_target() {

# adding audio port for s905w2 and derivatives
sed -i '/Audiodevices\.push_back("0,1");/a\\t\tAudiodevices.push_back("0,2");\n\t\tAudiodevices.push_back("1,2");' ${PKG_BUILD}/es-app/src/guis/GuiMenu.cpp

PKG_CMAKE_OPTS_TARGET=" -DENABLE_EMUELEC=1 -DDISABLE_KODI=1 -DENABLE_FILEMANAGER=1 -DGLES2=1 -DENABLE_TTS=1"

# Read api_keys.txt if it exist to add the required keys for cheevos, thegamesdb and screenscrapper. You need to get your own API keys. 
# File should be in this format
# -DSCREENSCRAPER_DEV_LOGIN=devid=<devusername>&devpassword=<devpassword> 
# -DGAMESDB_APIKEY=<gamesdbapikey>
# -DCHEEVOS_DEV_LOGIN=z=<yourusername>&y=<yourapikey>
# and it should be placed next to this file

if [ -f ${PKG_DIR}/api_keys.txt ]; then
while IFS="" read -r p || [ -n "${p}" ]
do
  PKG_CMAKE_OPTS_TARGET+=" ${p}"
done < ${PKG_DIR}/api_keys.txt
fi

if [[ ${DEVICE} == "GameForce" ]]; then
PKG_CMAKE_OPTS_TARGET+=" -DENABLE_GAMEFORCE=1"
fi

if [[ ${DEVICE} == "OdroidGoAdvance"  ]]; then
PKG_CMAKE_OPTS_TARGET+=" -DODROIDGOA=1"
fi

}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/config/emuelec/configs/locale/i18n/charmaps
	cp -rf ${PKG_BUILD}/locale/lang/* ${INSTALL}/usr/config/emuelec/configs/locale/
	cp -PR "$(get_build_dir glibc)/localedata/charmaps/UTF-8" ${INSTALL}/usr/config/emuelec/configs/locale/i18n/charmaps/UTF-8
	
	mkdir -p ${INSTALL}/usr/lib
	ln -sf /storage/.config/emuelec/configs/locale ${INSTALL}/usr/lib/locale
	
	mkdir -p ${INSTALL}/usr/config/emulationstation/resources
    cp -rf ${PKG_BUILD}/resources/* ${INSTALL}/usr/config/emulationstation/resources/
    
    mkdir -p ${INSTALL}/usr/bin
    ln -sf /storage/.config/emulationstation/resources ${INSTALL}/usr/bin/resources
    cp -rf ${PKG_BUILD}/emulationstation ${INSTALL}/usr/bin
    cp -PR "$(get_build_dir glibc)/.${TARGET_NAME}/locale/localedef" ${INSTALL}/usr/bin

	mkdir -p ${INSTALL}/etc/emulationstation/
	ln -sf /storage/.config/emulationstation/themes ${INSTALL}/etc/emulationstation/
   
	mkdir -p ${INSTALL}/usr/config/emulationstation
	cp -rf ${PKG_DIR}/config/scripts ${INSTALL}/usr/config/emulationstation
	cp -rf ${PKG_DIR}/config/*.cfg ${INSTALL}/usr/config/emulationstation

	chmod +x ${INSTALL}/usr/config/emulationstation/scripts/*
	chmod +x ${INSTALL}/usr/config/emulationstation/scripts/configscripts/*
	find ${INSTALL}/usr/config/emulationstation/scripts/ -type f -exec chmod o+x {} \; 
	
	# Vertical Games are only supported in the OdroidGoAdvance
    if [[ ${DEVICE} != "OdroidGoAdvance" ]]; then
        sed -i "s|, vertical||g" "${INSTALL}/usr/config/emulationstation/es_features.cfg"
    fi
	
	# Amlogic project has an issue with mixed audio
    if [[ "${DEVICE}" == "Amlogic-old" ]]; then
        sed -i "s|</config>|	<bool name=\"StopMusicOnScreenSaver\" value=\"false\" />\n</config>|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
    fi

    if [[ "${DEVICE}" == "OdroidGoAdvance" ]] || [[ "${DEVICE}" == "GameForce" ]]; then
        sed -i "s|<\/config>|	<string name=\"GamelistViewStyle\" value=\"Small Screen\" />\n<\/config>|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
        sed -i "s|value=\"panel\" />|value=\"small panel\" />|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
    fi
    
    if  [[ "${DEVICE}" == "GameForce" ]]; then
    	mkdir -p ${INSTALL}/usr/config/emulationstation/themesettings
        sed -i "s|<\/config>|	<string name=\"subset.ratio\" value=\"43\" />\n<\/config>|g" "${INSTALL}/usr/config/emulationstation/es_settings.cfg"
        echo "subset.ratio=43" > ${INSTALL}/usr/config/emulationstation/themesettings/Crystal.cfg
    fi

# Remove unused cores
CORESFILE="${INSTALL}/usr/config/emulationstation/es_systems.cfg"

#identifier Amlogic-ng Amlogic-ne Amlogic-no
if [[ "${DEVICE}" != "Amlogic-ng" || "${DEVICE}" != "Amlogic-ne" || "${DEVICE}" != "Amlogic-no" ]]; then

    if [[ ${DEVICE} == "OdroidGoAdvance" || "${DEVICE}" == "GameForce" ]]; then
        remove_cores="mesen-s quicknes mame2016 mesen"
    elif [ "${DEVICE}" == "Amlogic-old" ]; then
        remove_cores="mesen-s quicknes mame2016 mesen yabasanshiroSA yabasanshiro"
        xmlstarlet ed -L -P -d "/systemList/system[name='saturn']" ${CORESFILE}
        xmlstarlet ed -L -P -d "/systemList/system[name='phillips-cdi']" ${CORESFILE}
        xmlstarlet ed -L -P -d "/systemList/system/emulators/emulator[@name='Duckstation']" ${CORESFILE}
    fi
    
    for discore in ${remove_cores}; do
        sed -i "s|<core>${discore}</core>||g" ${CORESFILE}
        sed -i '/^[[:space:]]*$/d' ${CORESFILE}
    done
fi

# Remove Retrorun For unsupported devices
if [[ ${DEVICE} != "OdroidGoAdvance" ]] && [[ "${DEVICE}" != "GameForce" ]]; then
	xmlstarlet ed -L -P -d "/systemList/system/emulators/emulator[@name='retrorun']" ${CORESFILE}
else
	# remove duckstation for the OGA/GF
	xmlstarlet ed -L -P -d "/systemList/system/emulators/emulator[@name='Duckstation']" ${CORESFILE}

	# set parallel_n64_32b as default for handhelds
	sed -i "s|<core default=\"true\">mupen64plus_next</core>|<core>mupen64plus_next</core>|g" ${CORESFILE}
	sed -i "s|<core>parallel_n64_32b</core>|<core default=\"true\">parallel_n64_32b</core>|g" ${CORESFILE}
fi

}

post_install() {  
	enable_service emustation.service
	mkdir -p ${INSTALL}/usr/share
	ln -sf /storage/.config/emuelec/configs/locale ${INSTALL}/usr/share/locale
	mkdir -p ${INSTALL}/usr/bin/batocera/
	ln -sf /usr/bin/7zr ${INSTALL}/usr/bin/batocera/7zr
}
