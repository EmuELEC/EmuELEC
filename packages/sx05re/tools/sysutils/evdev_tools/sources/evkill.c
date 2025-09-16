/* Usage: evkill <-k, --keys keys> <-d, --device evdev> <programs>
eg: evkill -k 304+305 -d /dev/input/event3 retroarch

Signed-off-by: Ning Bo <n.b@live.com> 
*/

#define _GNU_SOURCE

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <fcntl.h>
#include <linux/input.h>
#include <dirent.h>
#include <libgen.h>

void set_bit(char *mem, int key) {
	int8_t *byte = (int8_t *)mem + key / 8;
	*byte |= 1 << key % 8;
}

void clr_bit(char *mem, int key) {
	int8_t *byte = (int8_t *)mem + key / 8;
	*byte &= ~(1 << key % 8);
}

static const struct option long_options[] = {
	{"device", required_argument, NULL, 'd'},
	{"keys", required_argument, NULL, 'k'},
	{0, 0, 0, 0}
};

char *js2evdev(char *joystick) {
	char *evdev = NULL;
	char *path = NULL;
	DIR *dir;
	struct dirent *ptr;

	asprintf(&path, "/sys/class/input/%s/device", basename(joystick));
	dir = opendir(path);
	free(path);
	if (dir == NULL) {
		return NULL;
	}

	while((ptr = readdir(dir)) != NULL) {
		if (ptr->d_type == DT_DIR && strncmp(ptr->d_name, "event", 5) == 0) {
			asprintf(&evdev, "/dev/input/%s", ptr->d_name);
		}
	}

	return evdev;
}

int main(int argc, char* argv[])
{
	int ret = 0;
	int opt = 0;
	struct input_event ev;
	char *dev = NULL, *keys = NULL;
	char cmd[1024];

	int size = (KEY_CNT - 1) / 8 + 1;
	char *bitmap0 = (char *)malloc(size);
	char *bitmap1 = (char *)malloc(size);
	memset(bitmap0, 0x0, size);
	memset(bitmap1, 0x0, size);

	while((opt = getopt_long(argc, argv, "d:k:", long_options, NULL)) != -1)
	{
		switch(opt)
		{
			case 'd':
				dev = strdup(optarg);
				break;
			case 'k':
				keys = strdup(optarg);
				break;
			default:
				printf("Usage: %s <-k, --keys keys> <-d, --device evdev or joystick> <programe...>\n", argv[0]);
				exit(1);
				break;
		}
	}

	if (dev == NULL || keys== NULL || optind == argc) {
		printf("Usage: %s <-k, --keys keys> <-d, --device evdev or joystick> <programe...>\n", argv[0]);
		exit(1);
	}

	strcpy(cmd, "killall ");
	int i;
	for (i = optind; i < argc; i++) {
		strcat(cmd, argv[i]);
	}

	char *str, *saveptr, *key;
	for (i = 0, str = keys; ; i++, str = NULL) {
		key = strtok_r(str, ",+", &saveptr);
		if (key == NULL)
			break;

		if (atoi(key) > KEY_MAX)
			continue;

		set_bit(bitmap0, atoi(key));
	}

	while(1) {
		int fd, version, ready;

		ready = 0;
		do {
			fd = open(dev, O_RDONLY);
			if (fd > 0) {
				if (ioctl(fd, EVIOCGVERSION, &version)) {
					ready = 1;
					break;
				}
			}

			char *evdev = js2evdev(dev);
			if (!evdev) {
				break;
			}

			fd = open(evdev, O_RDONLY);
			free(evdev);
			if (fd > 0) {
				if (ioctl(fd, EVIOCGVERSION, &version) == 0) {
					ready = 1;
					break;
				}
			}
		} while(0);

		if (!ready) {
			sleep(1);
			continue;
		}

		while(1) {
			ret = read(fd, &ev, sizeof(struct input_event));
			if (ret < 0) {
				perror("read");
				break;
			}

			if (ev.type == EV_KEY) {
				if (ev.value == 0) {
					clr_bit(bitmap1, ev.code);
					continue;
				} else {
					set_bit(bitmap1, ev.code);
				}
			}

			if (memcmp(bitmap0, bitmap1, size) == 0) {
				memset(bitmap1, 0x0, size);
				/* printf("execute cmd: %s\n", cmd);*/
				system(cmd);
				exit(0);
			}
		}

		close(fd);
	}

	return 0;
}

