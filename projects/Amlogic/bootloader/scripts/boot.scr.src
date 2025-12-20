load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} ${prefix}uEnv.ini && env import -t ${kernel_addr_r} ${filesize}
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} ${prefix}KERNEL
load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${dtb_name}
bootm ${kernel_addr_r} - ${fdt_addr_r}
