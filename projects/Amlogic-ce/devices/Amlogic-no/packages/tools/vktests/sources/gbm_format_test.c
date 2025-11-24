// GBM Pixel Format Compatibility Test
// Tests both ARGB8888 and XRGB8888 formats to see which works with Mali
// Compile: gcc gbm_format_test.c -o gbm_format_test -lgbm -lEGL -lGLESv2 -ldl

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <dlfcn.h>
#include <stdint.h>
#include <gbm.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES2/gl2.h>

// Minimal DRM definitions (avoid needing libdrm headers)
#define DRM_MODE_CONNECTED 1
#define DRM_MODE_CONNECTOR_HDMIA 11
#define DRM_MODE_CONNECTOR_HDMIB 12

typedef struct _drmModeRes {
    int count_fbs;
    uint32_t *fbs;
    int count_crtcs;
    uint32_t *crtcs;
    int count_connectors;
    uint32_t *connectors;
    int count_encoders;
    uint32_t *encoders;
    uint32_t min_width, max_width;
    uint32_t min_height, max_height;
} drmModeRes;

typedef struct _drmModeModeInfo {
    uint32_t clock;
    uint16_t hdisplay, hsync_start, hsync_end, htotal, hskew;
    uint16_t vdisplay, vsync_start, vsync_end, vtotal, vscan;
    uint32_t vrefresh;
    uint32_t flags;
    uint32_t type;
    char name[32];
} drmModeModeInfo;

typedef struct _drmModeConnector {
    uint32_t connector_id;
    uint32_t encoder_id;
    uint32_t connector_type;
    uint32_t connector_type_id;
    uint32_t connection;
    uint32_t mmWidth, mmHeight;
    uint32_t subpixel;
    int count_modes;
    drmModeModeInfo *modes;
    int count_props;
    uint32_t *props;
    uint64_t *prop_values;
    int count_encoders;
    uint32_t *encoders;
} drmModeConnector;

// Function pointers
static drmModeRes* (*drmModeGetResources)(int fd);
static void (*drmModeFreeResources)(drmModeRes *ptr);
static drmModeConnector* (*drmModeGetConnector)(int fd, uint32_t connectorId);
static void (*drmModeFreeConnector)(drmModeConnector *ptr);
static int (*drmModeAddFB)(int fd, uint32_t width, uint32_t height, uint8_t depth,
                           uint8_t bpp, uint32_t pitch, uint32_t bo_handle, uint32_t *buf_id);
static int (*drmModeRmFB)(int fd, uint32_t bufferId);

static int load_drm_functions(void) {
    void *handle = dlopen("libdrm.so.2", RTLD_LAZY);
    if (!handle) {
        handle = dlopen("libdrm.so", RTLD_LAZY);
    }
    if (!handle) {
        printf("Failed to load libdrm: %s\n", dlerror());
        return 0;
    }
    
    drmModeGetResources = dlsym(handle, "drmModeGetResources");
    drmModeFreeResources = dlsym(handle, "drmModeFreeResources");
    drmModeGetConnector = dlsym(handle, "drmModeGetConnector");
    drmModeFreeConnector = dlsym(handle, "drmModeFreeConnector");
    drmModeAddFB = dlsym(handle, "drmModeAddFB");
    drmModeRmFB = dlsym(handle, "drmModeRmFB");
    
    if (!drmModeGetResources || !drmModeFreeResources || !drmModeGetConnector ||
        !drmModeFreeConnector || !drmModeAddFB || !drmModeRmFB) {
        printf("Failed to load DRM functions\n");
        return 0;
    }
    
    return 1;
}

typedef struct {
    uint32_t format;
    const char *name;
    int success;
    char error_msg[256];
} FormatTest;

int test_format(int drm_fd, struct gbm_device *gbm, uint32_t format, const char *format_name, 
                drmModeConnector *connector, drmModeModeInfo *mode) {
    
    printf("\n--- Testing format: %s (0x%08x) ---\n", format_name, format);
    
    // Create GBM surface with this format
    printf("  Creating GBM surface...\n");
    struct gbm_surface *gbm_surface = gbm_surface_create(
        gbm,
        mode->hdisplay,
        mode->vdisplay,
        format,
        GBM_BO_USE_SCANOUT | GBM_BO_USE_RENDERING
    );
    
    if (!gbm_surface) {
        printf("  ✗ FAILED: gbm_surface_create returned NULL\n");
        return 0;
    }
    printf("  ✓ GBM surface created: %p\n", gbm_surface);
    
    // Get EGL display using platform extension
    printf("  Getting EGL display...\n");
    PFNEGLGETPLATFORMDISPLAYEXTPROC eglGetPlatformDisplayEXT = 
        (PFNEGLGETPLATFORMDISPLAYEXTPROC)eglGetProcAddress("eglGetPlatformDisplayEXT");
    
    if (!eglGetPlatformDisplayEXT) {
        printf("  ✗ FAILED: eglGetPlatformDisplayEXT not available\n");
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    
    EGLDisplay display = eglGetPlatformDisplayEXT(EGL_PLATFORM_GBM_KHR, gbm, NULL);
    if (display == EGL_NO_DISPLAY) {
        printf("  ✗ FAILED: eglGetPlatformDisplayEXT returned EGL_NO_DISPLAY\n");
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ EGL display obtained: %p\n", display);
    
    // Initialize EGL
    EGLint major, minor;
    if (!eglInitialize(display, &major, &minor)) {
        printf("  ✗ FAILED: eglInitialize failed (error: 0x%x)\n", eglGetError());
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ EGL initialized: %d.%d\n", major, minor);
    
    // Choose EGL config
    printf("  Choosing EGL config...\n");
    EGLint config_attribs[] = {
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_RED_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE, 8,
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
        EGL_NONE
    };
    
    EGLConfig config;
    EGLint num_configs;
    if (!eglChooseConfig(display, config_attribs, &config, 1, &num_configs) || num_configs == 0) {
        printf("  ✗ FAILED: eglChooseConfig failed (error: 0x%x)\n", eglGetError());
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ EGL config chosen (found %d configs)\n", num_configs);
    
    // Check what format EGL chose
    EGLint native_visual_id;
    eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &native_visual_id);
    printf("  ℹ EGL chose native visual ID: 0x%x\n", native_visual_id);
    
    // Create EGL context
    printf("  Creating EGL context...\n");
    EGLint context_attribs[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };
    
    EGLContext context = eglCreateContext(display, config, EGL_NO_CONTEXT, context_attribs);
    if (context == EGL_NO_CONTEXT) {
        printf("  ✗ FAILED: eglCreateContext failed (error: 0x%x)\n", eglGetError());
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ EGL context created: %p\n", context);
    
    // Create EGL window surface - THIS IS THE CRITICAL TEST
    printf("  Creating EGL window surface...\n");
    EGLSurface egl_surface = eglCreateWindowSurface(
        display, 
        config, 
        (EGLNativeWindowType)gbm_surface, 
        NULL
    );
    
    if (egl_surface == EGL_NO_SURFACE) {
        EGLint error = eglGetError();
        printf("  ✗ FAILED: eglCreateWindowSurface failed (error: 0x%x)\n", error);
        
        // Decode common error codes
        switch(error) {
            case EGL_BAD_MATCH:
                printf("     EGL_BAD_MATCH: Config doesn't match native window\n");
                break;
            case EGL_BAD_CONFIG:
                printf("     EGL_BAD_CONFIG: Invalid EGL config\n");
                break;
            case EGL_BAD_NATIVE_WINDOW:
                printf("     EGL_BAD_NATIVE_WINDOW: Invalid native window\n");
                break;
            case EGL_BAD_ALLOC:
                printf("     EGL_BAD_ALLOC: Resource allocation failed\n");
                break;
        }
        
        eglDestroyContext(display, context);
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ EGL window surface created: %p\n", egl_surface);
    
    // Make context current
    printf("  Making context current...\n");
    if (!eglMakeCurrent(display, egl_surface, egl_surface, context)) {
        printf("  ✗ FAILED: eglMakeCurrent failed (error: 0x%x)\n", eglGetError());
        eglDestroySurface(display, egl_surface);
        eglDestroyContext(display, context);
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ Context made current\n");
    
    // Try to render something
    printf("  Testing rendering...\n");
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);  // Green
    glClear(GL_COLOR_BUFFER_BIT);
    GLenum gl_error = glGetError();
    if (gl_error != GL_NO_ERROR) {
        printf("  ✗ FAILED: glClear failed (error: 0x%x)\n", gl_error);
        eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        eglDestroySurface(display, egl_surface);
        eglDestroyContext(display, context);
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ glClear succeeded\n");
    
    // Try to swap buffers
    printf("  Swapping buffers...\n");
    if (!eglSwapBuffers(display, egl_surface)) {
        printf("  ✗ FAILED: eglSwapBuffers failed (error: 0x%x)\n", eglGetError());
        eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        eglDestroySurface(display, egl_surface);
        eglDestroyContext(display, context);
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ eglSwapBuffers succeeded\n");
    
    // Lock front buffer to verify we can scan it out
    printf("  Locking front buffer...\n");
    struct gbm_bo *bo = gbm_surface_lock_front_buffer(gbm_surface);
    if (!bo) {
        printf("  ✗ FAILED: gbm_surface_lock_front_buffer returned NULL\n");
        eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        eglDestroySurface(display, egl_surface);
        eglDestroyContext(display, context);
        eglTerminate(display);
        gbm_surface_destroy(gbm_surface);
        return 0;
    }
    printf("  ✓ Front buffer locked\n");
    
    // Check buffer properties
    uint32_t bo_format = gbm_bo_get_format(bo);
    uint32_t width = gbm_bo_get_width(bo);
    uint32_t height = gbm_bo_get_height(bo);
    uint32_t stride = gbm_bo_get_stride(bo);
    uint32_t handle = gbm_bo_get_handle(bo).u32;
    
    printf("  ℹ Buffer properties:\n");
    printf("     Format: 0x%08x (requested: 0x%08x) %s\n", 
           bo_format, format, (bo_format == format) ? "✓ MATCH" : "✗ MISMATCH");
    printf("     Size: %ux%u\n", width, height);
    printf("     Stride: %u\n", stride);
    printf("     Handle: %u\n", handle);
    
    // Try to create DRM framebuffer
    printf("  Creating DRM framebuffer...\n");
    uint32_t fb_id;
    int ret = drmModeAddFB(drm_fd, width, height, 24, 32, stride, handle, &fb_id);
    if (ret) {
        printf("  ✗ WARNING: drmModeAddFB failed: %d (but format might still work for SDL)\n", ret);
    } else {
        printf("  ✓ DRM framebuffer created: %u\n", fb_id);
        drmModeRmFB(drm_fd, fb_id);
    }
    
    // Cleanup
    gbm_surface_release_buffer(gbm_surface, bo);
    eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    eglDestroySurface(display, egl_surface);
    eglDestroyContext(display, context);
    eglTerminate(display);
    gbm_surface_destroy(gbm_surface);
    
    printf("  ✓✓✓ FORMAT %s: SUCCESS ✓✓✓\n", format_name);
    return 1;
}

int main(int argc, char *argv[]) {
    printf("===============================================\n");
    printf("  GBM Pixel Format Compatibility Test\n");
    printf("===============================================\n\n");
    
    // Load DRM functions
    if (!load_drm_functions()) {
        printf("Failed to load DRM library functions\n");
        return 1;
    }
    printf("✓ DRM functions loaded\n");
    
    // Open DRM device
    printf("Opening DRM device...\n");
    int drm_fd = open("/dev/dri/card0", O_RDWR | O_CLOEXEC);
    if (drm_fd < 0) {
        perror("Failed to open /dev/dri/card0");
        return 1;
    }
    printf("✓ DRM device opened: fd=%d\n", drm_fd);
    
    // Create GBM device
    printf("Creating GBM device...\n");
    struct gbm_device *gbm = gbm_create_device(drm_fd);
    if (!gbm) {
        printf("✗ gbm_create_device failed\n");
        close(drm_fd);
        return 1;
    }
    printf("✓ GBM device created: %p\n", gbm);
    printf("  Backend: %s\n", gbm_device_get_backend_name(gbm));
    
    // Get DRM resources
    printf("\nGetting DRM resources...\n");
    drmModeRes *resources = drmModeGetResources(drm_fd);
    if (!resources) {
        printf("✗ drmModeGetResources failed\n");
        gbm_device_destroy(gbm);
        close(drm_fd);
        return 1;
    }
    printf("✓ Found %d connectors\n", resources->count_connectors);
    
    // Find connected display
    drmModeConnector *connector = NULL;
    for (int i = 0; i < resources->count_connectors; i++) {
        connector = drmModeGetConnector(drm_fd, resources->connectors[i]);
        if (connector->connection == DRM_MODE_CONNECTED && connector->count_modes > 0) {
            printf("✓ Using connector %d (%s)\n", i, 
                   connector->connector_type == DRM_MODE_CONNECTOR_HDMIA ? "HDMI-A" : "unknown");
            break;
        }
        drmModeFreeConnector(connector);
        connector = NULL;
    }
    
    if (!connector) {
        printf("✗ No connected display found\n");
        drmModeFreeResources(resources);
        gbm_device_destroy(gbm);
        close(drm_fd);
        return 1;
    }
    
    drmModeModeInfo *mode = &connector->modes[0];
    printf("✓ Using mode: %ux%u @%uHz\n", mode->hdisplay, mode->vdisplay, mode->vrefresh);
    
    // Test formats
    printf("\n===============================================\n");
    printf("  TESTING PIXEL FORMATS\n");
    printf("===============================================\n");
    
    FormatTest tests[] = {
        { GBM_FORMAT_ARGB8888, "ARGB8888", 0, "" },
        { GBM_FORMAT_XRGB8888, "XRGB8888", 0, "" },
        { GBM_FORMAT_ABGR8888, "ABGR8888", 0, "" },
        { GBM_FORMAT_XBGR8888, "XBGR8888", 0, "" }
    };
    
    int num_tests = sizeof(tests) / sizeof(tests[0]);
    
    for (int i = 0; i < num_tests; i++) {
        tests[i].success = test_format(drm_fd, gbm, tests[i].format, tests[i].name, 
                                       connector, mode);
    }
    
    // Print summary
    printf("\n===============================================\n");
    printf("  TEST SUMMARY\n");
    printf("===============================================\n\n");
    
    for (int i = 0; i < num_tests; i++) {
        printf("%s (0x%08x): %s\n", 
               tests[i].name, 
               tests[i].format,
               tests[i].success ? "✓ SUCCESS" : "✗ FAILED");
    }
    
    printf("\n===============================================\n");
    printf("  RECOMMENDATION\n");
    printf("===============================================\n\n");
    
    int argb_works = tests[0].success;
    int xrgb_works = tests[1].success;
    
    if (argb_works && xrgb_works) {
        printf("Both ARGB8888 and XRGB8888 work!\n");
        printf("SDL2's default (ARGB8888) should be fine.\n");
    } else if (xrgb_works && !argb_works) {
        printf("Only XRGB8888 works!\n");
        printf("This explains why the patch is needed.\n");
        printf("Mali blob doesn't support alpha in scanout buffers.\n");
    } else if (argb_works && !xrgb_works) {
        printf("Only ARGB8888 works!\n");
        printf("The patch shouldn't be necessary.\n");
    } else {
        printf("Neither format works!\n");
        printf("There may be a deeper issue with the Mali driver or kernel.\n");
    }
    
    // Cleanup
    drmModeFreeConnector(connector);
    drmModeFreeResources(resources);
    gbm_device_destroy(gbm);
    close(drm_fd);
    
    printf("\n");
    return 0;
}
