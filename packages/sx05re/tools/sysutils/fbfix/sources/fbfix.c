/* by crashoverride https://forum.odroid.com/viewtopic.php?p=254904#p254904 */

#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[])
{
		if (argc != 2) {
				fprintf(stderr, "Usage: %s <fb index 0-3>\n", argv[0]);
				return 1;
		}

		// Validate argument
		if (strlen(argv[1]) != 1 || !isdigit(argv[1][0])) {
				fprintf(stderr, "Error: framebuffer index must be a single digit (0-3)\n");
				return 1;
		}

		int fb_index = argv[1][0] - '0';
		if (fb_index < 0 || fb_index > 3) {
				fprintf(stderr, "Error: framebuffer index must be between 0 and 3\n");
				return 1;
		}

    int fbfd = 0;
    struct fb_var_screeninfo vinfo;
    struct fb_fix_screeninfo finfo;

		// Build framebuffer path
    char fb_path[16];
    snprintf(fb_path, sizeof(fb_path), "/dev/fb%d", fb_index);

    /* Open the file for reading and writing */
    fbfd = open(fb_path, O_RDWR);
    if (!fbfd) 
    {
        printf("Error: cannot open framebuffer device.\n");
        exit(1);
    }
    printf("The framebuffer device was opened successfully.\n");

    /* Get fixed screen information */
    if (ioctl(fbfd, FBIOGET_FSCREENINFO, &finfo))
    {
        printf("Error reading fixed information.\n");
        exit(2);
    }

    /* Get variable screen information */
    if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo)) 
    {
        printf("Error reading variable information.\n");
        exit(3);
    }

    printf("vinfo.yoffset=%d\n", vinfo.yoffset);
    
    if (vinfo.yoffset != 0)
    {
        printf("FIX: setting vinfo.yoffset=0.\n");
        vinfo.yoffset = 0;
        if (ioctl(fbfd, FBIOPUT_VSCREENINFO, &vinfo)) 
        {
            printf("Error setting variable information.\n");
            exit(4);
        }
    }

    return 0;
}
