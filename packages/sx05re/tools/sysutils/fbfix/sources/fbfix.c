/* by crashoverride https://forum.odroid.com/viewtopic.php?p=254904#p254904 */

#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <sys/ioctl.h>

int main()
{
    int fbfd = 0;
    struct fb_var_screeninfo vinfo;
    struct fb_fix_screeninfo finfo;


    /* Open the file for reading and writing */
    fbfd = open("/dev/fb0", O_RDWR);
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
