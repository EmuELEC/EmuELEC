# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain ${OPENGLES} emuelec-emulationstation retroarch"
PKG_SECTION="emuelec"
PKG_LONGDESC="EmuELEC Meta Package"
PKG_TOOLCHAIN="manual"

PKG_EXPERIMENTAL="nestopiaCV quasi88 xmil np2kai hypseus-singe yabasanshiroSA_1_11 yabasanshiroSA_1_5 fbneoSA same_cdi ikemen-go"
PKG_EMUS="${LIBRETRO_CORES} advancemame PPSSPPSDL amiberry hatarisa openbor dosbox-staging mupen64plus-nx mupen64plus-nx-alt scummvmsa stellasa solarus dosbox-pure pcsx_rearmed ecwolf potator freej2me duckstation flycastsa fmsx-libretro jzintv mupen64plussa"
PKG_DEPENDS_TARGET+=" emuelec-tools ${PKG_EMUS} ${PKG_EXPERIMENTAL} emuelec-ports"

# These packages are only meant for S922x, S905x2 and A311D devices as they run poorly on S905" 
#identifier Amlogic-ng Amlogic-ne Amlogic-no
case "${DEVICE}" in
    Amlogic-n*|RK356x|OdroidM1)
        PKG_DEPENDS_TARGET+=" ${LIBRETRO_S922X_CORES} mame2016 xow"
        ;;
esac

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	PKG_DEPENDS_TARGET+=" kmscon odroidgoa-utils"
    
  #we disable some cores that are not working or work poorly on OGA
	for discore in duckstation mesen-s virtualjaguar quicknes MC; do
		PKG_DEPENDS_TARGET=$(echo ${PKG_DEPENDS_TARGET} | sed "s|${discore} | |")
	done
	PKG_DEPENDS_TARGET+=" yabasanshiro"
else
	PKG_DEPENDS_TARGET+=" fbterm"
fi

# These cores do not work, or are not needed on aarch64, this package needs cleanup :) 
if [ "${ARCH}" == "aarch64" ]; then
  for discore in quicknes parallel-n64 pcsx_rearmed; do
		PKG_DEPENDS_TARGET=$(echo ${PKG_DEPENDS_TARGET} | sed "s|${discore}| |")
	done

  PKG_DEPENDS_TARGET+=" swanstation "
                        
  PKG_DEPENDS_TARGET+=" lib32-essential \
                        lib32-retroarch \
                        emuelec-32bit-info \
                        lib32-flycast \
                        lib32-mupen64plus \
                        lib32-pcsx_rearmed \
                        lib32-uae4arm \
                        lib32-parallel-n64 \
                        lib32-bennugd-monolithic \
                        lib32-droidports \
                        lib32-box86
                        lib32-libusb"
                        
#identifier Amlogic-ng Amlogic-ne Amlogic-no
case "${DEVICE}" in
    Amlogic-n*|RK356x|OdroidM1)
        PKG_DEPENDS_TARGET+=" dolphinSA"
        ;;
esac

if [ "${DEVICE}" == "Amlogic-old" ]; then
    #we disable some cores that are not working or work poorly on Amlogic-old
    for discore in yabasanshiroSA_1_11 yabasanshiroSA_1_5 yabasanshiro same_cdi duckstation; do
      PKG_DEPENDS_TARGET=$(echo ${PKG_DEPENDS_TARGET} | sed "s|${discore} | |")
    done
  fi
fi

makeinstall_target() {

	mkdir -p ${INSTALL}/usr/bin
	cp -rf ${PKG_DIR}/bin ${INSTALL}/usr

	mkdir -p ${INSTALL}/usr/config/
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/
  ln -sf /storage/.config/emuelec ${INSTALL}/emuelec

  # Added for compatibility with portmaster
  ln -sf /storage/roms ${INSTALL}/roms
  ln -sf /storage/roms/ports/portmaster ${INSTALL}/portmaster

  find ${INSTALL}/usr/config/emuelec/ -type f -exec chmod o+x {} \;

	mkdir -p ${INSTALL}/usr/config/emuelec/logs
	ln -sf /var/log ${INSTALL}/usr/config/emuelec/logs/var-log

  # leave for compatibility
  if [ "${DEVICE}" == "Amlogic-old" ]; then
    echo "s905" > ${INSTALL}/ee_s905
  fi

  echo "${DEVICE}" > ${INSTALL}/ee_arch
  
  mkdir -p ${INSTALL}/usr/share/retroarch-overlays
  cp -r ${PKG_DIR}/overlay/* ${INSTALL}/usr/share/retroarch-overlays
  
  mkdir -p ${INSTALL}/usr/share/common-shaders
  cp -r ${PKG_DIR}/shaders/* ${INSTALL}/usr/share/common-shaders
    
  mkdir -p ${INSTALL}/usr/share/libretro-database
  touch ${INSTALL}/usr/share/libretro-database/dummy
  
  # set audio for NE
  if [[ "${DEVICE}" == "Amlogic-ne" || "${DEVICE}" == "Amlogic-no" ]]; then
            sed -i 's/#ee_audio_device=auto/ee_audio_device=0,2/' "${INSTALL}/usr/config/emuelec/configs/emuelec.conf"
  fi
  
}

post_install() {
  for i in borders effects gamepads ipad keyboards misc; do
    rm -rf "${INSTALL}/usr/share/retroarch-overlays/${i}"
  done

  mkdir -p ${INSTALL}/etc/retroarch-joypad-autoconfig
  cp -r ${PKG_DIR}/gamepads/* ${INSTALL}/etc/retroarch-joypad-autoconfig

  # link default.target to emuelec.target
  ln -sf emuelec.target ${INSTALL}/usr/lib/systemd/system/default.target
  enable_service emuelec-autostart.service
  enable_service emuelec-disable_small_cores.service


  # Remove scripts from OdroidGoAdvance build
  if [[ ${DEVICE} == "OdroidGoAdvance" || "${DEVICE}" == "GameForce" ]]; then 
    for i in "wifi" "sselphs_scraper" "skyscraper" "system_info"; do 
    xmlstarlet ed -L -P -d "/gameList/game[name='${i}']" ${INSTALL}/usr/bin/scripts/setup/gamelist.xml
    rm "${INSTALL}/usr/bin/scripts/setup/${i}.sh"
    done
  fi 

  # For automatic updates we use the buildate
	date +"%m%d%Y" > ${INSTALL}/usr/buildate
	
	ln -sf /storage/roms ${INSTALL}/roms
	
  # We make sure all files in /usr/bin are executables
	find ${INSTALL}/usr/bin -type f -exec chmod +x {} \;
} 
