#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present Team CoreELEC (https://coreelec.org)

source /usr/lib/coreelec/read-firmware-version
SET_ANDROID_FIRMWARE="/sys/class/firmware_codec/android_firmware_version"

modprobe -q amvdec_ports
modprobe -q amvdec_avs
modprobe -q amvdec_avs2
modprobe -q amvdec_avs3
modprobe -q amvdec_mavs
modprobe -q amvdec_h264
modprobe -q amvdec_h264mvc
modprobe -q amvdec_mh264
modprobe -q amvdec_h265
modprobe -q amvdec_h266
modprobe -q amvdec_mjpeg
modprobe -q amvdec_mmjpeg
modprobe -q amvdec_mpeg12
modprobe -q amvdec_mmpeg12
modprobe -q amvdec_mpeg4
modprobe -q amvdec_mmpeg4
modprobe -q amvdec_real
modprobe -q amvdec_vc1
modprobe -q amvdec_av1
modprobe -q amvdec_vp9
modprobe -q amvdec_vp9_fb
modprobe -q amvdec_h265_fb
modprobe -q amvdec_av1_fb
modprobe -q amvdec_avs2_fb

if [ -f ${SET_ANDROID_FIRMWARE} ]; then
  read_firmware_version /vendor/lib/firmware/video/video_ucode.bin &>/dev/null
  echo "Android firmware version: ${minor}.${batch}"
  echo "${minor}.${batch}" > "${SET_ANDROID_FIRMWARE}"
fi
