# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-ports"
PKG_VERSION="1.0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain Jinja2:host pyyaml pyyaml:host"
PKG_SECTION="emuelec"
PKG_SHORTDESC="EmuELEC Ports Meta Package"
PKG_TOOLCHAIN="manual"


PKG_DEPENDS_TARGET+=" commander-genius \
                devilutionX \
                sdlpop \
                VVVVVV \
                opentyrian \
                bermuda \
                hodesdl \
                hydracastlelabyrinth \
                eduke \
                rigelengine \
                sonic2013 \
                soniccd \
                supertux \
                supertuxkart \
                chocolate-doom \
                lzdoom \
                gzdoom \
                supermariowar \
                bstone \
                hurrican \
                cdogs-sdl \
                abuse \
                fheroes2 \
                augustus \
                xash3d \
                sonicmania \
                shovelknight \
                tmntsr \
                falloutce1 \
                falloutce2 \
                ccleste \
                celeste"

amlogicports=""
hhports=" openjazz"

if [ "${DEVICE}" == "Amlogic"* ]; then
	PKG_DEPENDS_TARGET+="${amlogicports}"
fi

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	PKG_DEPENDS_TARGET+="${hhports}"
fi


make_target() {
mkdir -p ${PKG_BUILD}/scripts
python3 port_builder.py ports.yaml scripts
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin/ports
cp -rf ${PKG_BUILD}/scripts/* ${INSTALL}/usr/bin/ports

# Remove duplicate newlines just to be tidy
for file in "${INSTALL}/usr/bin/ports/*.sh"; do
sed  -i '$!N; /^\(.*\)\n\1$/!P; D' ${file}
done

# Remove empty lines from gamelist.xml
sed -i '/^$/d' ${INSTALL}/usr/bin/ports/gamelist.xml

}
