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

void remap(int src, int dst) {
    int ret = 0;
    int power = 0, back = 0;
	struct input_event ev, ev_pre, ev_end;

    while(1) {
		ret = read(src, &ev, sizeof(struct input_event));
		if(ret != sizeof(struct input_event))
		{
			perror("read");
            break;
		}

		if (ev.value == 0xc0030) {
			ev_pre.time = ev.time;
			ev_pre.type = 4;
			ev_pre.code = 4;
			ev_pre.value = 0x9000b;
			power = 1;
			continue;
		}

		if (power==0 && ev.value==0xc0224) {
			ev_pre.time = ev.time;
			ev_pre.type = 4;
			ev_pre.code = 4;
			ev_pre.value = 0x9000b;
			back = 1;
			continue;
		}

		if (power) {
			write(dst, &ev_pre, sizeof(struct input_event));

			ev.code = 0x13a;
			write(dst, &ev, sizeof(struct input_event));

			ev_end.time = ev.time;
			ev_end.type = 0;
			ev_end.code = 0;
			ev_end.value = 0;
			write(dst, &ev_end, sizeof(struct input_event));

			ev_pre.value = 0x9000c;
			write(dst, &ev_pre, sizeof(struct input_event));

			ev.code = 0x13b;
			write(dst, &ev, sizeof(struct input_event));

			write(dst, &ev_end, sizeof(struct input_event));

			power = 0;
			continue;
		}

		if (back) {
			write(dst, &ev_pre, sizeof(struct input_event));

			ev.code = 0x13a;
			write(dst, &ev, sizeof(struct input_event));

			ev_end.time = ev.time;
			ev_end.type = 0;
			ev_end.code = 0;
			ev_end.value = 0;
			write(dst, &ev_end, sizeof(struct input_event));

			back = 0;
			continue;
		}
	}

    close(src);
    close(dst);

    return;
}

int main(int argc, char *argv[])
{
	int fd_from = 0, fd_to = 0;

	if (argc != 3) {
		printf("usage: %s <input event from> <input event to>", argv[0]);
		return 1;
	}

    while(1) {
	    fd_from = open(argv[1], O_RDONLY);
	    if(fd_from < 0)
	    {
	    	perror("open from");
            sleep(1);
            break;
	    }
	    fd_to = open(argv[2], O_WRONLY);
	    if(fd_to < 0)
	    {
	    	perror("open to");
            sleep(1);
            break;
	    }

        remap(fd_from, fd_to);
    }
}

