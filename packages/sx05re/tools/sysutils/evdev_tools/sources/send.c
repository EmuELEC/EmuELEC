/*
 * Signed-off-by: Ning Bo <n.b@live.com>
*/
#include <linux/input.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>

#define BASE_VALUE 0x9000b
#define BASE_CODE BTN_SELECT

int main(int argc, char *argv[])
{
	int fd_to = -1, ret = -1;
	struct input_event ev, ev_pre, ev_end;
	struct timeval ts;

	if (argc != 2) {
		printf("usage: %s <input event to>", argv[0]);
		return 1;
	}

	char *to = argv[1];

	fd_to = open(to, O_WRONLY);
	if(fd_to < 0)
	{
		perror("open to");
		return -1;
	}

    int version;
    ioctl(fd_to, EVIOCGVERSION, &version);

	gettimeofday(&ts, NULL);
	ev_pre.time=ts;
	ev_pre.type=4;
	ev_pre.code=4;
	ev_pre.value=BASE_VALUE+(BTN_A-BTN_SELECT);
	write(fd_to, &ev_pre, sizeof(struct input_event));

	ev.time=ts;
	ev.type=1;
	ev.code=BASE_CODE+(BTN_A-BTN_SELECT);
	ev.value=1;
	write(fd_to, &ev, sizeof(struct input_event));

	ev_end.time=ev.time;
	ev_end.type=0;
	ev_end.code=0;
	ev_end.value=0;
	write(fd_to, &ev_end, sizeof(struct input_event));

	sleep(1);

	gettimeofday(&ts, NULL);
	ev_pre.time=ts;
	write(fd_to, &ev_pre, sizeof(struct input_event));
	ev.time=ts;
	ev.value=0;
	write(fd_to, &ev, sizeof(struct input_event));
	ev_end.time=ts;
	write(fd_to, &ev_end, sizeof(struct input_event));
}

