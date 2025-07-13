# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="media_modules-aml"
PKG_VERSION="ca9530ef9110f3ae54d5d7019588ec057a667f3b"
PKG_SHA256="d1b6019daec6e47872ba6142b5af0847b645f6998696b22c54e25404db86a5c9"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/media_modules-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="${PKG_NAME}: Linux driver"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/drivers \
    EXTRA_CFLAGS="-DLIMIT_DECODE_INSTANCE=1" \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG2_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG4_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VC1=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264_MVC=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H265=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H266=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VP9=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MJPEG_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS2=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS3=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AV1=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VP9_FB=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H265_FB=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AV1_FB=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS2_FB=m
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/video/NO_TEE
    for soc in ${TEE_SOC}; do
      cp -PR ${PKG_BUILD}/firmware/${soc} ${INSTALL}/$(get_full_firmware_dir)/video
    done
    if [ -f "${PKG_BUILD}/firmware/NO_TEE/video_ucode.bin" ]; then
      cp -PR ${PKG_BUILD}/firmware/NO_TEE/video_ucode.bin ${INSTALL}/$(get_full_firmware_dir)/video/NO_TEE
    else
      cp -PR ${PKG_BUILD}/firmware/video_ucode.bin ${INSTALL}/$(get_full_firmware_dir)/video/NO_TEE
    fi

  mkdir -p ${INSTALL}/usr/lib/coreelec
    install -m 0755 ${PKG_DIR}/scripts/media_modules-aml.sh ${INSTALL}/usr/lib/coreelec/media_modules-aml
    install -m 0755 ${PKG_DIR}/scripts/read-firmware-version.sh ${INSTALL}/usr/lib/coreelec/read-firmware-version
}

post_install() {
  enable_service media_modules-aml.service
}
