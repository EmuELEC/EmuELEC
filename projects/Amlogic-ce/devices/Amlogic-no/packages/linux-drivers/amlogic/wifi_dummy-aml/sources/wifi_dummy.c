#include <linux/delay.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/of_address.h>
#include <linux/version.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("kszaq");
MODULE_DESCRIPTION("Amlogic WiFi power on and SDIO/PCIe rescan module");

extern void extern_wifi_set_enable(int);
extern void sdio_reinit(void);

#undef CONFIG_PCI

#ifdef CONFIG_PCI
extern void set_usb_wifi_power(int);
extern void pci_remove(void);
extern void pci_reinit(void);
#endif

/*
      name sdio                name sdio                 name sd1          
 full_name sdio@fe088000  full_name /sdio@ffe03000  full_name /sd1@ffe05000

      name pcie                name pcieA
 full_name pcie@e0000000  full_name /pcieA@fc000000
*/

static bool device_enabled(const char *path, const char *prefix)
{
struct device_node *parent_node;
struct device_node *child;
bool ret = false;
int len;

	/*pr_info("wifi_dummy: path=%s prefix=%s\n", path, prefix);*/

	parent_node = of_find_node_by_path(path);
	if (parent_node) {
		for_each_child_of_node(parent_node, child) {
			/*pr_info("wifi_dummy: full_name=%s, name=%s\n", child->full_name, child->name);*/
			if (!strncmp(child->name, prefix, strlen(prefix))) {
				len = strlen(child->name);

				if (child->full_name[0] == '/')
					len++;  /* include '/' */

				if (strlen(child->full_name) > len && child->full_name[len] == '@') {
					if (of_device_is_available(child)) {
						pr_info("wifi_dummy: found enabled %s\n", child->full_name);
						ret = true;
						break;
					} else {
						pr_info("wifi_dummy: found disabled %s\n", child->full_name);
					}
				}
			}
		}

		of_node_put(parent_node);
	}

	return ret;
}

static int __init wifi_dummy_init(void)
{
bool sdio_en = false;
bool pcie_en = false;

	pr_info("wifi_dummy: Triggered SDIO/PCIe WiFi power on and bus rescan\n");

	sdio_en  = device_enabled("/soc", "sdio");
	pcie_en  = device_enabled("/soc", "pcie");
	sdio_en |= device_enabled("/", "sdio");
	pcie_en |= device_enabled("/", "pcie");
	sdio_en |= device_enabled("/", "sd2");

	if (!sdio_en && !pcie_en) {
		pr_info("wifi_dummy: SDIO/PCIe not enabled\n");
		return -ENODEV;
	}

	pr_info("wifi_dummy: SDIO %s, PCIe %s\n",
		sdio_en ? "enabled" : "disabled",
		pcie_en ? "enabled" : "disabled");

#ifdef CONFIG_PCI
	if (pcie_en) {
		pci_remove();
		set_usb_wifi_power(0);
	}
#endif

	if (sdio_en) {
		extern_wifi_set_enable(0);
		msleep(300);
		extern_wifi_set_enable(1);
	} else {
		msleep(300);
	}

#ifdef CONFIG_PCI
	if (pcie_en)
		set_usb_wifi_power(1);
#endif

	msleep(300);

	if (sdio_en)
		sdio_reinit();

#ifdef CONFIG_PCI
	if (pcie_en)
		pci_reinit();
#endif

	return -ENODEV;
}

static void __exit wifi_dummy_cleanup(void)
{
	/* unused */
}

module_init(wifi_dummy_init);
module_exit(wifi_dummy_cleanup);
