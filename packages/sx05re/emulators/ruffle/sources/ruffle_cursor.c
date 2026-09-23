/* ruffle_cursor.c — software mouse cursor for ruffle4consoles on EmuELEC
 *
 * EmuELEC's SDL2 only ships the "mali" and "offscreen" video backends, and
 * mali implements no hardware cursor: SDL_ShowCursor() succeeds but nothing
 * is drawn. This shim tracks the pointer from the ordinary SDL mouse events
 * and paints a small arrow right before each buffer swap.
 *
 * Build (cross):
 *   aarch64-linux-gnu-gcc -shared -fPIC -O2 -o ruffle_cursor.so ruffle_cursor.c -ldl
 * Use:
 *   LD_PRELOAD=/path/ruffle_cursor.so ./ruffle-native-adaptive.aarch64
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned int   GLenum;
typedef unsigned char  GLboolean;
typedef int            GLint;
typedef int            GLsizei;
typedef unsigned int   GLbitfield;
typedef float          GLfloat;

#define GL_SCISSOR_TEST       0x0C11
#define GL_SCISSOR_BOX        0x0C10
#define GL_COLOR_CLEAR_VALUE  0x0C22
#define GL_COLOR_WRITEMASK    0x0C23
#define GL_COLOR_BUFFER_BIT   0x00004000
#define GL_DEPTH_TEST         0x0B71
#define GL_STENCIL_TEST       0x0B90

/* --- SDL bits we need, declared locally to avoid a build dependency ------ */
#define SDL_MOUSEMOTION 0x400

static void *(*real_GL_GetProcAddress)(const char *);
static int   (*real_PollEvent)(void *);
static void  (*real_SwapWindow)(void *);
static void  (*real_GetWindowSize)(void *, int *, int *);

static void (*p_glEnable)(GLenum);
static void (*p_glDisable)(GLenum);
static GLboolean (*p_glIsEnabled)(GLenum);
static void (*p_glScissor)(GLint, GLint, GLsizei, GLsizei);
static void (*p_glClearColor)(GLfloat, GLfloat, GLfloat, GLfloat);
static void (*p_glClear)(GLbitfield);
static void (*p_glGetIntegerv)(GLenum, GLint *);
static void (*p_glGetFloatv)(GLenum, GLfloat *);
static void (*p_glGetBooleanv)(GLenum, GLboolean *);
static void (*p_glColorMask)(GLboolean, GLboolean, GLboolean, GLboolean);

static int mouse_x = -1, mouse_y = -1;   /* -1 = no motion seen yet */
static int gl_ready = 0;

static void init_gl(void)
{
    if (gl_ready) return;
    if (!real_GL_GetProcAddress)
        real_GL_GetProcAddress = dlsym(RTLD_NEXT, "SDL_GL_GetProcAddress");
    if (!real_GL_GetProcAddress) return;

#define LOAD(x) p_##x = real_GL_GetProcAddress(#x); if (!p_##x) return;
    LOAD(glEnable) LOAD(glDisable) LOAD(glIsEnabled) LOAD(glScissor)
    LOAD(glClearColor) LOAD(glClear) LOAD(glGetIntegerv) LOAD(glGetFloatv)
    LOAD(glGetBooleanv) LOAD(glColorMask)
#undef LOAD
    gl_ready = 1;
}

/* Filled rectangle via scissor + clear: works on plain GLES2 without shaders */
static void rect(int x, int y, int w, int h, float r, float g, float b)
{
    p_glScissor(x, y, w, h);
    p_glClearColor(r, g, b, 1.0f);
    p_glClear(GL_COLOR_BUFFER_BIT);
}

/* Classic arrow, built from horizontal slices; drawn white over black. */
static void draw_cursor(int x, int y_top, int win_h)
{
    const int H = 18;                    /* arrow height in pixels */
    for (int row = 0; row < H; row++) {
        int w = (row < 12) ? row + 2 : (row < 14 ? 6 : 4);
        int off = (row < 12) ? 0 : (row - 12) * 2 + 2;
        int gy = win_h - (y_top + row) - 1;      /* GL origin is bottom left */
        if (gy < 0) break;
        rect(x + off - 1, gy, w + 2, 1, 0.0f, 0.0f, 0.0f);   /* outline */
        rect(x + off,     gy, w,     1, 1.0f, 1.0f, 1.0f);   /* body    */
    }
}

/* --- hooks -------------------------------------------------------------- */
int SDL_PollEvent(void *event)
{
    if (!real_PollEvent) real_PollEvent = dlsym(RTLD_NEXT, "SDL_PollEvent");
    int r = real_PollEvent(event);
    if (r && event) {
        unsigned int type;
        memcpy(&type, event, sizeof(type));
        if (type == SDL_MOUSEMOTION) {
            int x, y;
            memcpy(&x, (char *)event + 20, sizeof(x));   /* SDL_MouseMotionEvent.x */
            memcpy(&y, (char *)event + 24, sizeof(y));   /* .y */
            mouse_x = x;
            mouse_y = y;
        }
    }
    return r;
}

void SDL_GL_SwapWindow(void *window)
{
    if (!real_SwapWindow) real_SwapWindow = dlsym(RTLD_NEXT, "SDL_GL_SwapWindow");
    if (!real_GetWindowSize) real_GetWindowSize = dlsym(RTLD_NEXT, "SDL_GetWindowSize");

    init_gl();
    if (gl_ready && mouse_x >= 0) {
        int w = 0, h = 0;
        if (real_GetWindowSize) real_GetWindowSize(window, &w, &h);
        if (h > 0) {
            /* save state */
            GLboolean sc = p_glIsEnabled(GL_SCISSOR_TEST);
            GLint box[4]; p_glGetIntegerv(GL_SCISSOR_BOX, box);
            GLfloat col[4]; p_glGetFloatv(GL_COLOR_CLEAR_VALUE, col);
            GLboolean mask[4]; p_glGetBooleanv(GL_COLOR_WRITEMASK, mask);
            GLboolean depth = p_glIsEnabled(GL_DEPTH_TEST);
            GLboolean sten  = p_glIsEnabled(GL_STENCIL_TEST);

            p_glDisable(GL_DEPTH_TEST);
            p_glDisable(GL_STENCIL_TEST);
            p_glColorMask(1, 1, 1, 1);
            p_glEnable(GL_SCISSOR_TEST);

            draw_cursor(mouse_x, mouse_y, h);

            /* restore */
            p_glScissor(box[0], box[1], box[2], box[3]);
            p_glClearColor(col[0], col[1], col[2], col[3]);
            p_glColorMask(mask[0], mask[1], mask[2], mask[3]);
            if (!sc) p_glDisable(GL_SCISSOR_TEST);
            if (depth) p_glEnable(GL_DEPTH_TEST);
            if (sten)  p_glEnable(GL_STENCIL_TEST);
        }
    }
    real_SwapWindow(window);
}
