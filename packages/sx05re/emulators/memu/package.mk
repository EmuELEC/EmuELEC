# SPDX-License-Identifier: GPL-2.0-or-later
PKG_NAME="memu"
PKG_VERSION="58a4281bc63d194c4f2df36ee83b14d8496b61f9"
PKG_SHA256="296375dcad99fc000924e4a0c6b5f94db3fbd97b2690a1e61f81d71519c6d954"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Memotech-Bill/MEMU"
PKG_URL="https://github.com/Memotech-Bill/MEMU/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib"
PKG_LONGDESC="Memotech MTX emulator"
PKG_TOOLCHAIN="cmake"
PKG_CMAKE_OPTS_TARGET="
  -DTARGET=FBuf
  -DCMAKE_BUILD_TYPE=Release
"

pre_configure_target() {
  cat > /tmp/patch_memu.py << 'PYEOF'
import sys
kbd2_path = sys.argv[1]
t = open(kbd2_path).read()
# Add '"' (0x22 = Shift+2) to keyinfo table between ' '(0x20) and '#'(0x23)
new_entry = '    {\'"\',' + "               {NKEY,0x11,NKEY,0x11,NKEY,0x11,NKEY,0x11},NKEY,NKEY}, // 0x22 Shift+2\n"
t = t.replace("    {'#',", new_entry + "    {'#',", 1)
open(kbd2_path, "w").write(t)
PYEOF

  # Enable AUTOTYPE in FBuf CMake build
  sed -i 's/-DHAVE_NFX/-DHAVE_AUTOTYPE\n    -DHAVE_NFX/' \
    ${PKG_BUILD}/CMakeLists.txt

  # Add '"' character support for autotype
  python3 /tmp/patch_memu.py "${PKG_BUILD}/src/memu/kbd2.c"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -a ${PKG_BUILD}/run_time/memu-fb ${INSTALL}/usr/bin/memu
  cp ${PKG_DIR}/scripts/memustart.sh ${INSTALL}/usr/bin/memustart.sh
  chmod +x ${INSTALL}/usr/bin/memustart.sh

  mkdir -p ${INSTALL}/usr/config/emuelec/configs/memu/gptk
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/memu/autotype
  cp ${PKG_DIR}/config/memu.gptk \
    ${INSTALL}/usr/config/emuelec/configs/memu/gptk/memu.gptk
  cp ${PKG_DIR}/config/default.autotype \
    ${INSTALL}/usr/config/emuelec/configs/memu/autotype/default.autotype

  # MEMU runtime files
  cp -a ${PKG_BUILD}/run_time/memu.cfg \
        ${PKG_BUILD}/run_time/memu0.cfg \
        ${PKG_BUILD}/run_time/alt_keypad.kbd \
    ${INSTALL}/usr/config/emuelec/configs/memu/
  cp -a ${PKG_BUILD}/run_time/roms \
        ${PKG_BUILD}/run_time/disks \
        ${PKG_BUILD}/run_time/tapes \
    ${INSTALL}/usr/config/emuelec/configs/memu/
}