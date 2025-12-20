defenv
setenv bootfromnand 0
setenv upgrade_step 2
setenv ce_on_emmc "no"
setenv sddtb 'if fatload mmc 0 ${dtb_mem_addr} dtb.img; then else store dtb read $dtb_mem_addr; fi'
setenv usbdtb 'if fatload usb 0 ${dtb_mem_addr} dtb.img; then else store dtb read $dtb_mem_addr; fi'
setenv cfgloadsd 'if fatload mmc 0:1 ${loadaddr} cfgload; then setenv device mmc; setenv devnr 0; setenv partnr 1; autoscr ${loadaddr}; fi'
setenv cfgloadusb 'if fatload usb 0:1 ${loadaddr} cfgload; then setenv device usb; setenv devnr 0; setenv partnr 1; autoscr ${loadaddr}; fi'
setenv cfgloademmc 'for p in 1 2 3 4 5 6 7 8 9 A B C D E F 10 11 12 13 14 15 16 17 18; do if fatload mmc 1:${p} ${loadaddr} cfgload; then setenv device mmc; setenv devnr 1; setenv partnr ${p}; setenv ce_on_emmc "yes"; autoscr ${loadaddr}; fi; done;'
setenv bootfromsd 'if mmcinfo; then run cfgloadsd; if fatload mmc 0 ${loadaddr} kernel.img; then run sddtb; setenv bootargs ${bootargs} bootfromsd; bootm; fi; fi'
setenv bootfromusb 'usb start 0; run cfgloadusb; if fatload usb 0 ${loadaddr} kernel.img; then run usbdtb; setenv bootargs ${bootargs} bootfromusb; bootm; fi'
setenv bootfromemmc 'run cfgloademmc'
setenv bootcmd 'if test ${bootfromnand} = 1; then setenv bootfromnand 0; saveenv; else run bootfromsd; run bootfromusb; run bootfromemmc; fi; run storeboot'

saveenv
run storeargs
run bootfromsd
run bootfromusb
run bootfromemmc
