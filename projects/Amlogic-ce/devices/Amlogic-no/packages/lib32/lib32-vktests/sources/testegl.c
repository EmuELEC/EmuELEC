#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/kd.h>

#define DRM_IOCTL_BASE 'd'
#define DRM_IOCTL_SET_MASTER _IO(DRM_IOCTL_BASE, 0x1e)
#define DRM_IOCTL_DROP_MASTER _IO(DRM_IOCTL_BASE, 0x1f)

int main() {
    // Switch VT to graphics mode
    int tty_fd = open("/dev/tty0", O_RDWR);
    if (tty_fd >= 0) {
        ioctl(tty_fd, KDSETMODE, KD_GRAPHICS);
        printf("✓ Set tty to graphics mode\n");
        close(tty_fd);
    }
    
    int drm_fd = open("/dev/dri/card0", O_RDWR);
    if (drm_fd < 0) {
        printf("Failed to open DRM\n");
        return 1;
    }
    
    // Try to become DRM master
    if (ioctl(drm_fd, DRM_IOCTL_SET_MASTER, 0) < 0) {
        printf("✗ Failed to become DRM master (fbcon is in the way)\n");
        close(drm_fd);
        return 1;
    }
    
    printf("✓✓✓ Successfully became DRM master!\n");
    printf("Now SDL2 should work. Try running emulationstation.\n");
    
    // Keep DRM master and wait
    sleep(60);
    
    return 0;
}
