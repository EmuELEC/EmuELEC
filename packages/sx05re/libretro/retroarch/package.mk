#############################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="retroarch"
PKG_VERSION="2406935a58afe1971ba368fdca1865d15afc8c84"
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL="${PKG_SITE}.git"
PKG_LICENSE="GPLv3"
PKG_DEPENDS_TARGET="toolchain SDL2 alsa-lib openssl freetype zlib retroarch-assets retroarch-overlays core-info ffmpeg libass joyutils empty ${OPENGLES} samba avahi nss-mdns freetype openal-soft espeak"
PKG_LONGDESC="Reference frontend for the libretro API."
GET_HANDLER_SUPPORT="git"

if [ "${DEVICE}" = "Amlogic-ng" ] || [ "${DEVICE}" = "Amlogic-old" ]; then
  PKG_PATCH_DIRS="${DEVICE}"
fi

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ] || [ "${DEVICE}" == "RK356x" ] || [ "${DEVICE}" == "OdroidM1" ]; then
PKG_DEPENDS_TARGET+=" libdrm librga"
PKG_PATCH_DIRS="OdroidGoAdvance"
fi

# Pulseaudio Support
  if [ "${PULSEAUDIO_SUPPORT}" = yes ]; then
    PKG_DEPENDS_TARGET+=" pulseaudio"
fi

pre_configure_target() {
# Retroarch does not like -O3 for CHD loading with cheevos
export CFLAGS="${CFLAGS} -O3 -fno-tree-vectorize"

TARGET_CONFIGURE_OPTS=""
PKG_CONFIGURE_OPTS_TARGET="--disable-qt \
                           --enable-alsa \
                           --enable-udev \
                           --disable-opengl1 \
                           --disable-opengl \
                           --enable-egl \
                           --enable-opengles \
                           --disable-wayland \
                           --disable-x11 \
                           --enable-zlib \
                           --enable-freetype \
                           --disable-discord \
                           --disable-vg \
                           --disable-sdl \
                           --enable-sdl2 \
                           --enable-ffmpeg"

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ] || [ "${DEVICE}" == "RK356x" ] || [ "${DEVICE}" == "OdroidM1" ]; then
PKG_CONFIGURE_OPTS_TARGET+=" --enable-opengles3 \
                           --enable-opengles3_2 \
                           --enable-kms \
                           --disable-mali_fbdev"
else
PKG_CONFIGURE_OPTS_TARGET+=" --disable-kms \
                           --enable-mali_fbdev"
fi

if [ "${DEVICE}" == "OdroidGoAdvance" ]; then
PKG_CONFIGURE_OPTS_TARGET+=" --enable-odroidgo2"
fi

if [ ${ARCH} == "arm" ]; then
PKG_CONFIGURE_OPTS_TARGET+=" --enable-neon"
fi

cd ${PKG_BUILD}
}

make_target() {
  make HAVE_ONLINE_UPDATER=1 HAVE_UPDATE_CORES=1 HAVE_UPDATE_CORE_INFO=1 HAVE_COMPRESSION=1 HAVE_ACCESSIBILITY=1 HAVE_UPDATE_ASSETS=1 HAVE_LIBRETRODB=1 HAVE_BLUETOOTH=1 HAVE_NETWORKING=1 HAVE_LAKKA=1 HAVE_ZARCH=1 HAVE_QT=0 HAVE_LANGEXTRA=1 HAVE_LAKKA_PROJECT=odroidn2+.aarch64 HAVE_LAKKA_SERVER="https://www.lakka.tv"
  [ $? -eq 0 ] && echo "(retroarch ok)" || { echo "(retroarch failed)" ; exit 1 ; }
  make -C gfx/video_filters compiler=${CC} extra_flags="${CFLAGS}"
[ $? -eq 0 ] && echo "(video filters ok)" || { echo "(video filters failed)" ; exit 1 ; }
  make -C libretro-common/audio/dsp_filters compiler=${CC} extra_flags="${CFLAGS}"
[ $? -eq 0 ] && echo "(audio filters ok)" || { echo "(audio filters failed)" ; exit 1 ; }
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/etc
    cp ${PKG_BUILD}/retroarch ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/video_filters
    cp ${PKG_BUILD}/gfx/video_filters/*.so ${INSTALL}/usr/share/video_filters
    cp ${PKG_BUILD}/gfx/video_filters/*.filt ${INSTALL}/usr/share/video_filters
  mkdir -p ${INSTALL}/usr/share/audio_filters
    cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.so ${INSTALL}/usr/share/audio_filters
    cp ${PKG_BUILD}/libretro-common/audio/dsp_filters/*.dsp ${INSTALL}/usr/share/audio_filters
  
  # General configuration
  echo 'all_users_control_menu = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'assets_directory = /tmp/assets' >> ${INSTALL}/etc/retroarch.cfg
  echo 'audio_driver = alsathread' >> ${INSTALL}/etc/retroarch.cfg
  echo 'audio_filter_dir = /usr/share/audio_filters' >> ${INSTALL}/etc/retroarch.cfg
  echo 'cache_directory = /tmp/cache' >> ${INSTALL}/etc/retroarch.cfg
  echo 'cheat_database_path = /tmp/database/cht' >> ${INSTALL}/etc/retroarch.cfg
  echo 'cheevos_unlock_sound_enable = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'content_database_path = /tmp/database/rdb' >> ${INSTALL}/etc/retroarch.cfg
  echo 'content_show_images = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'content_show_video = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'core_assets_directory = /storage/roms/downloads' >> ${INSTALL}/etc/retroarch.cfg
  echo 'core_updater_buildbot_cores_url = http://dontupdatecores/' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_driver = udev' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_menu_toggle_gamepad_combo = 2' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player1_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player2_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player3_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player4_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player5_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player6_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player7_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_player8_analog_dpad_mode = 1' >> ${INSTALL}/etc/retroarch.cfg
  echo 'input_remapping_directory = /storage/.config/retroarch/config/remappings' >> ${INSTALL}/etc/retroarch.cfg
  echo 'joypad_autoconfig_dir = /tmp/joypads' >> ${INSTALL}/etc/retroarch.cfg
  echo 'libretro_directory = /tmp/cores' >> ${INSTALL}/etc/retroarch.cfg
  echo 'libretro_info_path = /tmp/cores' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_mouse_enable = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_advanced_settings = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_core_updater = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_load_content_animation = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_quit_retroarch = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_reboot = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_restart_retroarch = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_show_shutdown = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'menu_timedate_style = 15' >> ${INSTALL}/etc/retroarch.cfg
  echo 'notification_show_autoconfig = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'notification_show_config_override_load = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'notification_show_remap_load = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'overlay_directory = /tmp/overlays' >> ${INSTALL}/etc/retroarch.cfg
  echo 'playlist_directory = /storage/playlists' >> ${INSTALL}/etc/retroarch.cfg
  echo 'playlist_entry_remove_enable = 2' >> ${INSTALL}/etc/retroarch.cfg
  echo 'playlist_entry_rename = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'quick_menu_show_start_recording = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'quick_menu_show_start_streaming = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'quick_menu_show_undo_save_load_state = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'recording_output_directory = /storage/roms/mplayer/retroarch' >> ${INSTALL}/etc/retroarch.cfg
  echo 'rgui_browser_directory = /storage/roms' >> ${INSTALL}/etc/retroarch.cfg
  echo 'rgui_show_start_screen = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'savefiles_in_content_dir = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'savestate_directory = /storage/roms/savestates' >> ${INSTALL}/etc/retroarch.cfg
  echo 'savestate_thumbnail_enable = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'screenshot_directory = /storage/roms/screenshots' >> ${INSTALL}/etc/retroarch.cfg
  echo 'settings_show_directory = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'system_directory = /storage/roms/bios' >> ${INSTALL}/etc/retroarch.cfg
  echo 'thumbnails_directory = /storage/thumbnails' >> ${INSTALL}/etc/retroarch.cfg
  echo 'user_language = 0' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_aspect_ratio_auto = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_filter_dir = /usr/share/video_filters' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_fullscreen = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_gpu_screenshot = false' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_shader_dir = /tmp/shaders' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_threaded = true' >> ${INSTALL}/etc/retroarch.cfg
  echo 'video_windowed_fullscreen = false' >> ${INSTALL}/etc/retroarch.cfg

  # Audio
  if [ "${PROJECT}" == "OdroidXU3" ]; then # workaround the 55fps bug
    echo 'audio_out_rate = 44100' >> ${INSTALL}/etc/retroarch.cfg
  fi

  # Updater
  if [ "${ARCH}" == "arm" ]; then
    sed -i -e 's|core_updater_buildbot_cores_url =.*|core_updater_buildbot_cores_url = http://buildbot.libretro.com/nightly/linux/armhf/latest/|' ${INSTALL}/etc/retroarch.cfg
  fi
  
if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
    echo 'xmb_layout = 2' >> ${INSTALL}/etc/retroarch.cfg
    echo 'menu_widget_scale_auto = false' >> ${INSTALL}/etc/retroarch.cfg
    echo 'menu_widget_scale_factor = 2.0' >> ${INSTALL}/etc/retroarch.cfg
    echo 'menu_scale_factor = 1.0' >> ${INSTALL}/etc/retroarch.cfg
    echo 'video_font_size = 12.0' >> ${INSTALL}/etc/retroarch.cfg
    echo 'menu_rgui_shadows = true' >> ${INSTALL}/etc/retroarch.cfg
    echo 'rgui_aspect_ratio = 6' >> ${INSTALL}/etc/retroarch.cfg
    echo 'rgui_inline_thumbnails = true' >> ${INSTALL}/etc/retroarch.cfg
    echo 'input_max_users = 1' >> ${INSTALL}/etc/retroarch.cfg
fi

  mkdir -p ${INSTALL}/usr/config/retroarch/
  mv ${INSTALL}/etc/retroarch.cfg ${INSTALL}/usr/config/retroarch/
  
}

post_install() {  
  enable_service retroarch.service
  enable_service tmp-cores.mount
  enable_service tmp-joypads.mount
  enable_service tmp-database.mount
  enable_service tmp-assets.mount
  enable_service tmp-shaders.mount
  enable_service tmp-overlays.mount
}
