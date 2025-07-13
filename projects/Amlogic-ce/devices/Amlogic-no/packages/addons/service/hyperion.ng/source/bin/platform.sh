#!/bin/sh

DECODERS="
  amvdec_h265
  amvdec_h265_fb
  amvdec_vp9
  amvdec_vp9_fb
  amvdec_av1
  amvdec_av1_fb"

case "$1" in
    start)
        double_write_mode=3
    ;;
    stop)
        double_write_mode=0
    ;;
    *)
        exit 0
    ;;
esac

for DECODER in ${DECODERS}; do
    [ -d "/sys/module/${DECODER}"  ] && echo ${double_write_mode} > /sys/module/${DECODER}/parameters/double_write_mode || :
done
