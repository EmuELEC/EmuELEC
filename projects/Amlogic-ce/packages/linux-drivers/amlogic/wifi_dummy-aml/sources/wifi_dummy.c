#include <linux/delay.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("kszaq");
MODULE_DESCRIPTION("Amlogic WiFi power on and SDIO rescan module");

extern void extern_wifi_set_enable(int);
extern void sdio_reinit(void);

static int __init wifi_dummy_init(void)
{
	printk(KERN_INFO "Triggered SDIO WiFi power on and bus rescan.\n");
	extern_wifi_set_enable(0);
	msleep(300);
	extern_wifi_set_enable(1);
	msleep(300);
	sdio_reinit();
	return 0;
}

static void __exit wifi_dummy_cleanup(void)
{
    printk(KERN_INFO "Cleaning up module.\n");
}

module_init(wifi_dummy_init);
module_exit(wifi_dummy_cleanup);
