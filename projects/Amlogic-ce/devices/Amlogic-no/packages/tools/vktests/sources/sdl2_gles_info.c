// SDL2 + OpenGL ES Information Display
// Compile: gcc sdl2_gles_info.c -o sdl2_gles_info -lSDL2 -lGLESv2 -lEGL

#include <SDL2/SDL.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void print_separator(const char *title) {
    printf("\n");
    printf("=================================================================\n");
    printf("  %s\n", title);
    printf("=================================================================\n");
}

void print_egl_extensions() {
    print_separator("EGL CLIENT EXTENSIONS (pre-display)");
    
    const char *client_exts = eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS);
    if (client_exts) {
        printf("%s\n", client_exts);
    } else {
        printf("(none available)\n");
    }
}

int main(int argc, char *argv[]) {
    printf("\n");
    printf("#################################################################\n");
    printf("#                SDL2 + OpenGL ES System Information           #\n");
    printf("#################################################################\n");

    // Print EGL client extensions BEFORE SDL init
    print_egl_extensions();

    // Initialize SDL
    print_separator("SDL INITIALIZATION");
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("ERROR: SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }
    printf("✓ SDL initialized successfully\n");

    // Print SDL video driver
    const char *video_driver = SDL_GetCurrentVideoDriver();
    printf("✓ Video driver: %s\n", video_driver ? video_driver : "unknown");

    // Set OpenGL ES attributes
    print_separator("SETTING OPENGL ES ATTRIBUTES");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    printf("✓ Requested OpenGL ES 2.0 context\n");
    printf("✓ Requested RGB888 + 16-bit depth buffer\n");

    // Create window
    print_separator("CREATING WINDOW");
    SDL_Window *window = SDL_CreateWindow(
        "SDL2 GLES Info",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        1920, 1080,
        SDL_WINDOW_OPENGL | SDL_WINDOW_FULLSCREEN | SDL_WINDOW_SHOWN
    );

    if (!window) {
        printf("ERROR: SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    printf("✓ Window created successfully\n");

    int w, h;
    SDL_GetWindowSize(window, &w, &h);
    printf("✓ Window size: %dx%d\n", w, h);

    // Create OpenGL context
    print_separator("CREATING OPENGL ES CONTEXT");
    SDL_GLContext context = SDL_GL_CreateContext(window);
    if (!context) {
        printf("ERROR: SDL_GL_CreateContext failed: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    printf("✓ OpenGL ES context created successfully\n");

    // Make context current
    if (SDL_GL_MakeCurrent(window, context) != 0) {
        printf("ERROR: SDL_GL_MakeCurrent failed: %s\n", SDL_GetError());
        SDL_GL_DeleteContext(context);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    printf("✓ Context made current\n");

    // Get actual GL attributes
    print_separator("ACTUAL OPENGL ES CONTEXT ATTRIBUTES");
    int value;
    SDL_GL_GetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, &value);
    printf("GL Context Major Version: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, &value);
    printf("GL Context Minor Version: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_RED_SIZE, &value);
    printf("Red Size: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_GREEN_SIZE, &value);
    printf("Green Size: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_BLUE_SIZE, &value);
    printf("Blue Size: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_ALPHA_SIZE, &value);
    printf("Alpha Size: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_DEPTH_SIZE, &value);
    printf("Depth Size: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_STENCIL_SIZE, &value);
    printf("Stencil Size: %d\n", value);
    SDL_GL_GetAttribute(SDL_GL_DOUBLEBUFFER, &value);
    printf("Double Buffer: %s\n", value ? "Yes" : "No");

    // Get OpenGL ES information
    print_separator("OPENGL ES INFORMATION");
    printf("GL_VENDOR:   %s\n", glGetString(GL_VENDOR));
    printf("GL_RENDERER: %s\n", glGetString(GL_RENDERER));
    printf("GL_VERSION:  %s\n", glGetString(GL_VERSION));
    printf("GL_SHADING_LANGUAGE_VERSION: %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));

    // Get OpenGL ES extensions
    print_separator("OPENGL ES EXTENSIONS");
    const char *gl_extensions = (const char *)glGetString(GL_EXTENSIONS);
    if (gl_extensions) {
        // Print extensions one per line for readability
        char *ext_copy = strdup(gl_extensions);
        char *token = strtok(ext_copy, " ");
        int count = 0;
        while (token != NULL) {
            printf("  %3d: %s\n", ++count, token);
            token = strtok(NULL, " ");
        }
        printf("\nTotal GL extensions: %d\n", count);
        free(ext_copy);
    } else {
        printf("(none available)\n");
    }

    // Get EGL display and extensions
    print_separator("EGL INFORMATION");
    EGLDisplay egl_display = eglGetCurrentDisplay();
    if (egl_display != EGL_NO_DISPLAY) {
        printf("EGL Display: %p\n", egl_display);
        
        EGLContext egl_context = eglGetCurrentContext();
        if (egl_context != EGL_NO_CONTEXT) {
            EGLint ctx_version;
            if (eglQueryContext(egl_display, egl_context, EGL_CONTEXT_CLIENT_VERSION, &ctx_version)) {
                printf("EGL Context Client Version: %d\n", ctx_version);
            }
        }
        
        printf("\nEGL_VENDOR:  %s\n", eglQueryString(egl_display, EGL_VENDOR));
        printf("EGL_VERSION: %s\n", eglQueryString(egl_display, EGL_VERSION));
        
        print_separator("EGL DISPLAY EXTENSIONS");
        const char *egl_extensions = eglQueryString(egl_display, EGL_EXTENSIONS);
        if (egl_extensions) {
            char *ext_copy = strdup(egl_extensions);
            char *token = strtok(ext_copy, " ");
            int count = 0;
            while (token != NULL) {
                printf("  %3d: %s\n", ++count, token);
                token = strtok(NULL, " ");
            }
            printf("\nTotal EGL extensions: %d\n", count);
            free(ext_copy);
        } else {
            printf("(none available)\n");
        }
    } else {
        printf("EGL Display not available\n");
    }

    // Test basic rendering
    print_separator("TESTING BASIC RENDERING");
    printf("Clearing screen to RED...\n");
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    SDL_GL_SwapWindow(window);
    
    printf("✓ Rendered successfully!\n");
    printf("\nPress any key to test BLUE screen...\n");
    
    SDL_Event event;
    int running = 1;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT || 
                (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)) {
                running = 0;
            } else if (event.type == SDL_KEYDOWN) {
                printf("Clearing screen to BLUE...\n");
                glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
                glClear(GL_COLOR_BUFFER_BIT);
                SDL_GL_SwapWindow(window);
                printf("✓ Rendered successfully!\n");
                printf("\nPress ESC to exit...\n");
            }
        }
        SDL_Delay(10);
    }

    // Cleanup
    print_separator("CLEANUP");
    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();
    printf("✓ Cleaned up successfully\n\n");

    return 0;
}
