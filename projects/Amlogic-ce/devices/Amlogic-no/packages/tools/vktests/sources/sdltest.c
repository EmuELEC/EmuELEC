#include <SDL2/SDL.h>
#include <stdio.h>
#include <dlfcn.h>

int main() {
    // Try to preload libdrm and libgbm
    void *libdrm = dlopen("/usr/lib/libdrm.so.2", RTLD_NOW | RTLD_GLOBAL);
    void *libgbm = dlopen("/usr/lib/libgbm.so.1", RTLD_NOW | RTLD_GLOBAL);
    
    if (!libdrm) printf("Warning: couldn't preload libdrm\n");
    if (!libgbm) printf("Warning: couldn't preload libgbm\n");
    
    setenv("SDL_VIDEODRIVER", "kmsdrm", 1);
    setenv("SDL_VIDEO_GL_DRIVER", "/var/lib/libMali.so", 1);
    setenv("SDL_VIDEO_EGL_DRIVER", "/var/lib/libMali.so", 1);
    
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }
    
    printf("Creating window...\n");
    SDL_Window *window = SDL_CreateWindow(
        "Test",
        0, 0,
        1920, 1080,
        SDL_WINDOW_FULLSCREEN
    );
    
    if (!window) {
        printf("Failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    
    printf("SUCCESS! Window created!\n");
    
    SDL_Delay(3000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    
    return 0;
}
