# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="nvidia"
PKG_VERSION="520.56.06"
PKG_SHA256="e46ae5f497bd75370c8dea19cf3766d1bf4ae62e6343bc3c31b9a6d523f21eb3"
PKG_ARCH="x86_64"
PKG_LICENSE="nonfree"
PKG_SITE="https://www.nvidia.com/en-us/drivers/unix/"
PKG_URL="http://us.download.nvidia.com/XFree86/Linux-x86_64/${PKG_VERSION}/NVIDIA-Linux-x86_64-${PKG_VERSION}-no-compat32.run"
PKG_DEPENDS_TARGET="toolchain util-macros libglvnd"
PKG_LONGDESC="The GBM/Wayland graphic driver for NVIDIA GPUs supporting the GeForce 700 Series & above."
PKG_TOOLCHAIN="manual"

PKG_IS_KERNEL_PKG="yes"

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN} vulkan-tools"
fi

unpack() {
  [ -d ${PKG_BUILD} ] && rm -rf ${PKG_BUILD}

  sh ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} --extract-only --target ${PKG_BUILD}
}

make_target() {
  unset LDFLAGS

  cd kernel
    make module CC=${CC} LD=${LD} SYSSRC=$(kernel_path) SYSOUT=$(kernel_path)
    ${STRIP} --strip-debug nvidia.ko
  cd ..
}

makeinstall_target() {
  # Linux kernel modules
  mkdir -p ${INSTALL}/$(get_full_module_dir)/nvidia
    cp -P kernel/nvidia.ko         ${INSTALL}/$(get_full_module_dir)/nvidia
    cp -P kernel/nvidia-drm.ko     ${INSTALL}/$(get_full_module_dir)/nvidia
    cp -P kernel/nvidia-uvm.ko     ${INSTALL}/$(get_full_module_dir)/nvidia
    cp -P kernel/nvidia-modeset.ko ${INSTALL}/$(get_full_module_dir)/nvidia

  # GBM
  mkdir -p ${INSTALL}/usr/lib/gbm
    cp -p libnvidia-allocator.so.${PKG_VERSION}     ${INSTALL}/usr/lib
    ln -sf libnvidia-allocator.so.${PKG_VERSION}    ${INSTALL}/usr/lib/liballocator.so.0
    ln -sf ../libnvidia-allocator.so.${PKG_VERSION} ${INSTALL}/usr/lib/gbm/nvidia-drm_gbm.so

  mkdir -p ${INSTALL}/usr/share/egl/egl_external_platform.d
    cp -p 15_nvidia_gbm.json          ${INSTALL}/usr/share/egl/egl_external_platform.d
    cp -p libnvidia-egl-gbm.so.1.1.0  ${INSTALL}/usr/lib
    ln -sf libnvidia-egl-gbm.so.1.1.0 ${INSTALL}/usr/lib/libnvidia-egl-gbm.so.1
    ln -sf libnvidia-egl-gbm.so.1     ${INSTALL}/usr/lib/libnvidia-egl-gbm.so

  # GLVND
  mkdir -p ${INSTALL}/usr/share/glvnd/egl_vendor.d
    cp -p 10_nvidia.json ${INSTALL}/usr/share/glvnd/egl_vendor.d

  # Wayland
  mkdir -p ${INSTALL}/usr/lib
    cp -p libnvidia-egl-wayland.so.1.1.9  ${INSTALL}/usr/lib/
    ln -sf libnvidia-egl-wayland.so.1.1.9 ${INSTALL}/usr/lib/libnvidia-egl-wayland.so.1
    ln -sf libnvidia-egl-wayland.so.1     ${INSTALL}/usr/lib/libnvidia-egl-wayland.so

  mkdir -p ${INSTALL}/usr/share/egl/egl_external_platform.d
    cp -p 10_nvidia_wayland.json ${INSTALL}/usr/share/egl/egl_external_platform.d

  # OpenGL / EGL
  mkdir -p ${INSTALL}/usr/lib
    cp -p libEGL_nvidia.so.${PKG_VERSION}  ${INSTALL}/usr/lib/
    ln -sf libEGL_nvidia.so.${PKG_VERSION} ${INSTALL}/usr/lib/libEGL_nvidia.so.0
    ln -sf libEGL_nvidia.so.0              ${INSTALL}/usr/lib/libEGL_nvidia.so

  # OpenGL core
  mkdir -p ${INSTALL}/usr/lib
    cp -p libnvidia-eglcore.so.${PKG_VERSION}  ${INSTALL}/usr/lib/
    ln -sf libnvidia-eglcore.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvidia-eglcore.so
    cp -p libnvidia-glsi.so.${PKG_VERSION}  ${INSTALL}/usr/lib
    ln -sf libnvidia-glsi.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvidia-glsi.so

  # OpenGL ES
  mkdir -p ${INSTALL}/usr/lib
    cp -p libGLESv2_nvidia.so.${PKG_VERSION}  ${INSTALL}/usr/lib
    ln -sf libGLESv2_nvidia.so.${PKG_VERSION} ${INSTALL}/usr/lib/libGLESv2_nvidia.so.2
    ln -sf libGLESv2_nvidia.so.2              ${INSTALL}/usr/lib/libGLESv2_nvidia.so

  # Vulkan
  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    mkdir -p ${INSTALL}/usr/lib
      cp -P libnvidia-glvkspirv.so.${PKG_VERSION}  ${INSTALL}/usr/lib
      ln -sf libnvidia-glvkspirv.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvidia-glvkspirv.so

      cp -p libnvidia-vulkan-producer.so.${PKG_VERSION}  ${INSTALL}/usr/lib
      ln -sf libnvidia-vulkan-producer.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvidia-vulkan-producer.so.1
      ln -sf libnvidia-vulkan-producer.so.1              ${INSTALL}/usr/lib/libnvidia-vulkan-producer.so

    mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
      sed "s#libGLX_nvidia.so.0#libEGL_nvidia.so.0#" nvidia_layers.json > ${INSTALL}/usr/share/vulkan/implicit_layer.d/nvidia_layers.json
    mkdir -p ${INSTALL}/usr/share/vulkan/icd.d
      sed "s#libGLX_nvidia.so.0#libEGL_nvidia.so.0#" nvidia_icd.json > ${INSTALL}/usr/share/vulkan/icd.d/nvidia_icd.json
  fi

  # CUDA
  mkdir -p ${INSTALL}/usr/lib
    cp -p libcuda.so.${PKG_VERSION}  ${INSTALL}/usr/lib
    ln -sf libcuda.so.${PKG_VERSION} ${INSTALL}/usr/lib/libcuda.so.1
    ln -sf libcuda.so.1              ${INSTALL}/usr/lib/libcuda.so

  # NVDEC
  mkdir -p ${INSTALL}/usr/lib
    cp -p libnvcuvid.so.${PKG_VERSION}  ${INSTALL}/usr/lib
    ln -sf libnvcuvid.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvcuvid.so.1
    ln -sf libnvcuvid.so.1              ${INSTALL}/usr/lib/libnvcuvid.so

  # nvidia-tls
  mkdir -p ${INSTALL}/usr/lib
    cp -P libnvidia-tls.so.${PKG_VERSION}  ${INSTALL}/usr/lib
    ln -sf libnvidia-tls.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvidia-tls.so

  # NVIDIA Management Library (NVML) / System Management Interface
  mkdir -p ${INSTALL}/usr/bin
    cp -P nvidia-smi ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/lib
    cp -P libnvidia-ml.so.${PKG_VERSION}  ${INSTALL}/usr/lib
    ln -sf libnvidia-ml.so.${PKG_VERSION} ${INSTALL}/usr/lib/libnvidia-ml.so.1
    ln -sf libnvidia-ml.so.1              ${INSTALL}/usr/lib/libnvidia-ml.so

  # App profiles
  mkdir -p ${INSTALL}/usr/share/nvidia
    cp -P nvidia-application-profiles-${PKG_VERSION}-rc ${INSTALL}/usr/share/nvidia
}
