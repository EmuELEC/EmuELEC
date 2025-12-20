/*
 * gpio-fan.c - driver for fans controlled by GPIO.
 */
#include <linux/module.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/err.h>
#include <linux/gpio.h>
#include <linux/of_platform.h>
#include <linux/of_gpio.h>
#include <linux/time.h>
#include <linux/workqueue.h>

#define KHADAS_FAN_TRIG_TEMP_LEVEL0	50	// 50 degree if not set
#define KHADAS_FAN_TRIG_TEMP_LEVEL1	60	// 60 degree if not set
#define KHADAS_FAN_TRIG_TEMP_LEVEL2	70	// 70 degree if not set
#define KHADAS_FAN_TRIG_MAXTEMP		80
#define KHADAS_FAN_LOOP_SECS   		30 * HZ // 30 seconds
#define KHADAS_FAN_LOOP_PULSE 		2	// 20 msec
#define KHADAS_FAN_TEST_LOOP_SECS   	5 * HZ  // 5 seconds
#define KHADAS_FAN_LOOP_NODELAY_SECS   	0
#define KHADAS_FAN_GPIO_OFF		0
#define KHADAS_FAN_GPIO_ON		1

enum khadas_fan_mode {
	KHADAS_FAN_STATE_MANUAL = 0,
	KHADAS_FAN_STATE_AUTO,
};

enum khadas_fan_level {
	KHADAS_FAN_LEVEL_0 = 0,
	KHADAS_FAN_LEVEL_1,
	KHADAS_FAN_LEVEL_2,
	KHADAS_FAN_LEVEL_3,
};

enum khadas_fan_enable {
	KHADAS_FAN_DISABLE = 0,
	KHADAS_FAN_ENABLE,
};

struct khadas_fan_data {
	struct platform_device *pdev;
	struct class *class;
	struct delayed_work work;
	struct delayed_work fan_test_work;
	enum    khadas_fan_enable enable;
	enum 	khadas_fan_mode mode;
	enum 	khadas_fan_level level;
	int	ctrl_gpio0;
	int	ctrl_gpio1;
	int	trig_temp_level0;
	int	trig_temp_level1;
	int	trig_temp_level2;
        int     last_level;
        int     temp;  
};

struct khadas_fan_data *fan_data = NULL;

void khadas_fan_level_set(struct khadas_fan_data *fan_data, int level )
{
	if(3 == fan_data->last_level){
		gpio_set_value(fan_data->ctrl_gpio0, KHADAS_FAN_GPIO_ON);
		gpio_set_value(fan_data->ctrl_gpio1, KHADAS_FAN_GPIO_OFF);
	}else if(2 == fan_data->last_level){
		gpio_set_value(fan_data->ctrl_gpio0, KHADAS_FAN_GPIO_OFF);
		gpio_set_value(fan_data->ctrl_gpio1, KHADAS_FAN_GPIO_ON);
	}else if(1 == fan_data->last_level){
		gpio_set_value(fan_data->ctrl_gpio0, KHADAS_FAN_GPIO_ON);
		gpio_set_value(fan_data->ctrl_gpio1, KHADAS_FAN_GPIO_ON);
	}else{
		gpio_set_value(fan_data->ctrl_gpio0, KHADAS_FAN_GPIO_OFF);
		gpio_set_value(fan_data->ctrl_gpio1, KHADAS_FAN_GPIO_OFF);
	}
	if (fan_data->last_level > 3 && level > 3)
		fan_data->last_level--;
        else
		fan_data->last_level = level;
}

extern int get_cpu_temp(void);
static void fan_work_func(struct work_struct *_work)
{
	struct khadas_fan_data *fan_data = container_of(_work,
		   struct khadas_fan_data, work.work);

	int temp, level =1;

	temp =  get_cpu_temp();

	if(temp < 0){
		schedule_delayed_work(&fan_data->work, KHADAS_FAN_LOOP_PULSE);
		return;
	}

	fan_data->temp = fan_data->temp ? (fan_data->temp + temp) / 2 : temp;
	if (fan_data->temp < fan_data->trig_temp_level0)
		level = 0;
	else if (fan_data->temp < fan_data->trig_temp_level0 + 2)
		level = 6;
	else if (fan_data->temp < fan_data->trig_temp_level0 + 4)
		level = 5;
	else if (fan_data->temp < fan_data->trig_temp_level0 + 6)
		level = 4;
	else if (fan_data->temp < fan_data->trig_temp_level1)
		level = 3;
	else if (fan_data->temp < fan_data->trig_temp_level2)
		level = 2;

	khadas_fan_level_set(fan_data, level);

	if (level > 3)
		schedule_delayed_work(&fan_data->work, KHADAS_FAN_LOOP_PULSE);
	else
		schedule_delayed_work(&fan_data->work, KHADAS_FAN_LOOP_SECS);
}

static void khadas_fan_set(struct khadas_fan_data  *fan_data)
{

	cancel_delayed_work(&fan_data->work);

	if (fan_data->enable == KHADAS_FAN_DISABLE) {
		fan_data->last_level = 0;
		khadas_fan_level_set(fan_data,0);
		return;
	}
	switch (fan_data->mode) {
	case KHADAS_FAN_STATE_MANUAL:
		switch(fan_data->level){
		case KHADAS_FAN_LEVEL_1:
			fan_data->last_level = 3;
			khadas_fan_level_set(fan_data,3);
			break;
		case KHADAS_FAN_LEVEL_2:
			fan_data->last_level = 2;
			khadas_fan_level_set(fan_data,2);
			break;
		case KHADAS_FAN_LEVEL_3:
			fan_data->last_level = 1;
			khadas_fan_level_set(fan_data,1);
			break;
		default:
			fan_data->last_level = 0;
			khadas_fan_level_set(fan_data,0);
			break;
		}
		break;

	case KHADAS_FAN_STATE_AUTO:
		// FIXME: achieve with a better way
		schedule_delayed_work(&fan_data->work, KHADAS_FAN_LOOP_PULSE);
		break;

	default:
		break;
	}
}

static ssize_t fan_enable_show(struct class *cls,
			 struct class_attribute *attr, char *buf)
{
	return sprintf(buf, "Fan enable: %d\n", fan_data->enable);
}

static ssize_t fan_enable_store(struct class *cls, struct class_attribute *attr,
		       const char *buf, size_t count)
{
	int enable;

	if (kstrtoint(buf, 0, &enable))
		return -EINVAL;

	// 0: manual, 1: auto
	if( enable >= 0 && enable < 2 ){
		fan_data->enable = enable;
		khadas_fan_set(fan_data);
	}

	return count;
}

static ssize_t fan_mode_show(struct class *cls,
			 struct class_attribute *attr, char *buf)
{
	return sprintf(buf, "Fan mode: %d\n", fan_data->mode);
}

static ssize_t fan_mode_store(struct class *cls, struct class_attribute *attr,
		       const char *buf, size_t count)
{
	int mode;

	if (kstrtoint(buf, 0, &mode))
		return -EINVAL;

	// 0: manual, 1: auto
	if( mode >= 0 && mode < 2 ){
		fan_data->mode = mode;
		khadas_fan_set(fan_data);
	}

	return count;
}

static ssize_t fan_level_show(struct class *cls,
			 struct class_attribute *attr, char *buf)
{
	return sprintf(buf, "Fan level: %d\n", fan_data->level);
}

static ssize_t fan_level_store(struct class *cls, struct class_attribute *attr,
		       const char *buf, size_t count)
{
	int level;

	if (kstrtoint(buf, 0, &level))
		return -EINVAL;

	if( level >= 0 && level < 4){
		fan_data->level = level;
		fan_data->last_level = level;
		khadas_fan_set(fan_data);
	}

	return count;
}


static ssize_t fan_temp_show(struct class *cls,
			 struct class_attribute *attr, char *buf)
{
	int temp = -EINVAL;
	temp = get_cpu_temp();

	return sprintf(buf, "cpu_temp:%d \nFan trigger temperature: pulse-level:%d level0:%d level1:%d level2:%d\n", 
		temp, fan_data->trig_temp_level0, fan_data->trig_temp_level0 + 6, fan_data->trig_temp_level1, fan_data->trig_temp_level2);
}

static struct class_attribute fan_class_attrs[] = {
	__ATTR(enable, 0644, fan_enable_show, fan_enable_store),
	__ATTR(mode, 0644, fan_mode_show, fan_mode_store),
	__ATTR(level, 0644, fan_level_show, fan_level_store),
	__ATTR(temp, 0444, fan_temp_show, NULL),
};

static int khadas_fan_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	int ret;
	int i;

	printk("khadas_fan_probe\n");

	fan_data = devm_kzalloc(dev, sizeof(struct khadas_fan_data), GFP_KERNEL);
	if (!fan_data)
		return -ENOMEM;

	ret = of_property_read_u32(dev->of_node, "trig_temp_level0", &fan_data->trig_temp_level0);
	if (ret < 0)
		fan_data->trig_temp_level0 = KHADAS_FAN_TRIG_TEMP_LEVEL0;
	ret = of_property_read_u32(dev->of_node, "trig_temp_level1", &fan_data->trig_temp_level1);
	if (ret < 0)
		fan_data->trig_temp_level1 = KHADAS_FAN_TRIG_TEMP_LEVEL1;
	ret = of_property_read_u32(dev->of_node, "trig_temp_level2", &fan_data->trig_temp_level2);
	if (ret < 0)
		fan_data->trig_temp_level2 = KHADAS_FAN_TRIG_TEMP_LEVEL2;

	fan_data->ctrl_gpio0 = of_get_named_gpio(dev->of_node, "fan_ctl0", 0);
	fan_data->ctrl_gpio1 = of_get_named_gpio(dev->of_node, "fan_ctl1", 0);
	if ((gpio_request(fan_data->ctrl_gpio0, "FAN") != 0)|| (gpio_request(fan_data->ctrl_gpio1, "FAN") != 0))
		return -EIO;

	gpio_direction_output(fan_data->ctrl_gpio0, KHADAS_FAN_GPIO_OFF);
	gpio_direction_output(fan_data->ctrl_gpio1, KHADAS_FAN_GPIO_OFF);
	fan_data->mode = KHADAS_FAN_STATE_AUTO;
	fan_data->level = KHADAS_FAN_LEVEL_0;
	fan_data->enable = KHADAS_FAN_ENABLE;
	fan_data->last_level = 0;
	fan_data->temp = 0;

	INIT_DELAYED_WORK(&fan_data->work, fan_work_func);
	khadas_fan_level_set(fan_data,0);
	schedule_delayed_work(&fan_data->work, KHADAS_FAN_TEST_LOOP_SECS);

	fan_data->pdev = pdev;
	platform_set_drvdata(pdev, fan_data);

	fan_data->class = class_create(THIS_MODULE, "fan");
	if (IS_ERR(fan_data->class)) {
		return PTR_ERR(fan_data->class);
	}

	for (i = 0; i < ARRAY_SIZE(fan_class_attrs); i++){
		ret = class_create_file(fan_data->class, &fan_class_attrs[i]);
		if(0!=ret){
			printk("khadas_fan_probe,class_create_file%d failed \n", i);
		}
	}
	dev_info(dev, "trigger temperature is level0:%d, level1:%d, level2:%d.\n", fan_data->trig_temp_level0, fan_data->trig_temp_level1, fan_data->trig_temp_level2);
	return 0;
}

static int khadas_fan_remove(struct platform_device *pdev)
{
	fan_data->enable = KHADAS_FAN_DISABLE;
	khadas_fan_set(fan_data);

	return 0;
}

static void khadas_fan_shutdown(struct platform_device *pdev)
{
	fan_data->enable = KHADAS_FAN_DISABLE;
	khadas_fan_set(fan_data);
}

#ifdef CONFIG_PM
static int khadas_fan_suspend(struct platform_device *pdev, pm_message_t state)
{
	cancel_delayed_work(&fan_data->work);
        fan_data->last_level = 0;
	khadas_fan_level_set(fan_data, 0);
	return 0;
}

static int khadas_fan_resume(struct platform_device *pdev)
{
	khadas_fan_set(fan_data);
	return 0;
}
#endif

static struct of_device_id of_khadas_fan_match[] = {
	{ .compatible = "fanctl", },
	{},
};

static struct platform_driver khadas_fan_driver = {
	.probe	= khadas_fan_probe,
#ifdef CONFIG_PM
	.suspend = khadas_fan_suspend,
	.resume = khadas_fan_resume,
#endif
	.remove	= khadas_fan_remove,
	.shutdown = khadas_fan_shutdown,
	.driver	= {
		.name	= "fanctl",
		.owner = THIS_MODULE,
		.of_match_table = of_match_ptr(of_khadas_fan_match),
	},
};

module_platform_driver(khadas_fan_driver);

MODULE_AUTHOR("kenny <kenny@khadas.com>");
MODULE_DESCRIPTION("khadas GPIO Fan driver");
MODULE_LICENSE("GPL");

