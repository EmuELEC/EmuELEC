/* sdl_swcursor.c - software mouse pointer for SDL2 apps on EmuELEC
 *
 * EmuELEC's SDL2 only ships the "mali" and "offscreen" video drivers, and
 * mali implements no hardware cursor: SDL_ShowCursor() succeeds but nothing
 * is drawn. This shim paints a pointer right before each frame is shown.
 *
 * Two render paths are covered, whichever the application uses:
 *   SDL_RenderPresent   apps using the SDL_Renderer API (e.g. DREAMM)
 *   SDL_GL_SwapWindow   apps drawing with GLES2 themselves (e.g. Ruffle)
 *
 * Build:
 *   $CC -shared -fPIC -O2 -o sdl_swcursor.so sdl_swcursor.c -ldl
 * Use:
 *   LD_PRELOAD=/usr/lib/sdl_swcursor.so <app>
 *
 * Env:
 *   SWCURSOR=0          disable the pointer (games drawing their own)
 *   SWCURSOR_SCALE=n    pointer size multiplier (default 1)
 *   SWCURSOR_TOGGLE=n   SDL scancode toggling the pointer at runtime (0 = off)
 *   SWCURSOR_MENU=n     SDL scancode translated into a synthetic F12 press
 *                       (0 = off; used by DREAMM, see dreammstart.sh)
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* --- SDL bits, declared locally to avoid a build dependency ------------- */
#define SCANCODE_F12   69
#define SDLK_F12_      (SCANCODE_F12 | (1 << 30))
#define EV_KEYDOWN     0x300
#define EV_KEYUP       0x301
#define EV_SIZE        56

typedef struct { int x, y, w, h; } RECT;

/* --- GLES2 bits --------------------------------------------------------- */
#define GL_DEPTH_TEST         0x0B71
#define GL_STENCIL_TEST       0x0B90
#define GL_SCISSOR_BOX        0x0C10
#define GL_SCISSOR_TEST       0x0C11
#define GL_COLOR_CLEAR_VALUE  0x0C22
#define GL_COLOR_WRITEMASK    0x0C23
#define GL_COLOR_BUFFER_BIT   0x00004000

/* 'o' = black outline, '#' = white fill */
static const char *ARROW[] = {
    "o          ",
    "oo         ",
    "o#o        ",
    "o##o       ",
    "o###o      ",
    "o####o     ",
    "o#####o    ",
    "o######o   ",
    "o#######o  ",
    "o########o ",
    "o#####oooo ",
    "o##o##o    ",
    "o#o o##o   ",
    "oo   o##o  ",
    "o     o##o ",
    "       o#o ",
    "        oo ",
};
#define ARROW_H ((int)(sizeof(ARROW) / sizeof(ARROW[0])))

/* SDL */
static void      (*p_RenderPresent)(void *);
static void      (*p_SwapWindow)(void *);
static uint32_t  (*p_GetMouseState)(int *, int *);
static void      (*p_GetWindowSize)(void *, int *, int *);
static void      (*p_GetDrawableSize)(void *, int *, int *);
static void     *(*p_GL_GetProcAddress)(const char *);
static int       (*p_SetDrawColor)(void *, uint8_t, uint8_t, uint8_t, uint8_t);
static int       (*p_GetDrawColor)(void *, uint8_t *, uint8_t *, uint8_t *, uint8_t *);
static int       (*p_FillRect)(void *, const RECT *);
static void      (*p_WinToLogical)(void *, int, int, float *, float *);
static int       (*p_SetBlend)(void *, int);
static int       (*p_GetBlend)(void *, int *);
static const uint8_t *(*p_GetKeyboardState)(int *);
static int       (*p_PushEvent)(void *);
static uint32_t  (*p_GetTicks)(void);

/* GL */
static void (*p_glEnable)(unsigned);
static void (*p_glDisable)(unsigned);
static unsigned char (*p_glIsEnabled)(unsigned);
static void (*p_glScissor)(int, int, int, int);
static void (*p_glClearColor)(float, float, float, float);
static void (*p_glClear)(unsigned);
static void (*p_glGetIntegerv)(unsigned, int *);
static void (*p_glGetFloatv)(unsigned, float *);
static void (*p_glGetBooleanv)(unsigned, unsigned char *);
static void (*p_glColorMask)(unsigned char, unsigned char, unsigned char, unsigned char);
static int gl_ready;

static int initialised;
static int enabled = 1, visible = 1, scale = 1, toggle_key, menu_key;
static int in_render_present;   /* SDL's GLES renderer swaps internally */

static int env_int(const char *name, int def)
{
    const char *e = getenv(name);
    return e ? atoi(e) : def;
}

static void init(void)
{
    if (initialised)
        return;
    initialised = 1;

    p_RenderPresent     = dlsym(RTLD_NEXT,    "SDL_RenderPresent");
    p_SwapWindow        = dlsym(RTLD_NEXT,    "SDL_GL_SwapWindow");
    p_GetMouseState     = dlsym(RTLD_DEFAULT, "SDL_GetMouseState");
    p_GetWindowSize     = dlsym(RTLD_DEFAULT, "SDL_GetWindowSize");
    p_GetDrawableSize   = dlsym(RTLD_DEFAULT, "SDL_GL_GetDrawableSize");
    p_GL_GetProcAddress = dlsym(RTLD_DEFAULT, "SDL_GL_GetProcAddress");
    p_SetDrawColor      = dlsym(RTLD_DEFAULT, "SDL_SetRenderDrawColor");
    p_GetDrawColor      = dlsym(RTLD_DEFAULT, "SDL_GetRenderDrawColor");
    p_FillRect          = dlsym(RTLD_DEFAULT, "SDL_RenderFillRect");
    p_WinToLogical      = dlsym(RTLD_DEFAULT, "SDL_RenderWindowToLogical");
    p_SetBlend          = dlsym(RTLD_DEFAULT, "SDL_SetRenderDrawBlendMode");
    p_GetBlend          = dlsym(RTLD_DEFAULT, "SDL_GetRenderDrawBlendMode");
    p_GetKeyboardState  = dlsym(RTLD_DEFAULT, "SDL_GetKeyboardState");
    p_PushEvent         = dlsym(RTLD_DEFAULT, "SDL_PushEvent");
    p_GetTicks          = dlsym(RTLD_DEFAULT, "SDL_GetTicks");

    enabled    = env_int("SWCURSOR", 1) != 0;
    scale      = env_int("SWCURSOR_SCALE", 1);
    toggle_key = env_int("SWCURSOR_TOGGLE", 0);
    menu_key   = env_int("SWCURSOR_MENU", 0);
    if (scale < 1)
        scale = 1;
}

static void init_gl(void)
{
    if (gl_ready || !p_GL_GetProcAddress)
        return;
#define LOAD(x) if (!(p_##x = p_GL_GetProcAddress(#x))) return;
    LOAD(glEnable) LOAD(glDisable) LOAD(glIsEnabled) LOAD(glScissor)
    LOAD(glClearColor) LOAD(glClear) LOAD(glGetIntegerv) LOAD(glGetFloatv)
    LOAD(glGetBooleanv) LOAD(glColorMask)
#undef LOAD
    gl_ready = 1;
}

/* --- keys ---------------------------------------------------------------
 * Sampled from SDL_GetKeyboardState once per frame instead of hooking the
 * event queue, so a short press can't be consumed before we see it. */
static int rising(int key, int *held)
{
    const uint8_t *keys;
    int now, edge;

    if (!key || !p_GetKeyboardState || !(keys = p_GetKeyboardState(NULL)))
        return 0;
    now = keys[key];
    edge = now && !*held;
    *held = now;
    return edge;
}

static void push_f12(int down)
{
    char ev[EV_SIZE];

    memset(ev, 0, sizeof(ev));
    *(uint32_t *)(ev + 0)  = down ? EV_KEYDOWN : EV_KEYUP;
    *(uint32_t *)(ev + 4)  = p_GetTicks ? p_GetTicks() : 0;
    *(uint8_t  *)(ev + 12) = down ? 1 : 0;
    *(int      *)(ev + 16) = SCANCODE_F12;
    *(int32_t  *)(ev + 20) = SDLK_F12_;
    p_PushEvent(ev);
}

static void poll_keys(void)
{
    static int toggle_held, menu_held;

    if (rising(toggle_key, &toggle_held))
        visible = !visible;
    if (p_PushEvent && rising(menu_key, &menu_held)) {
        push_f12(1);
        push_f12(0);
    }
}

static int want_cursor(void)
{
    return enabled && visible && p_GetMouseState;
}

/* --- SDL_Renderer path --------------------------------------------------- */
static void draw_renderer(void *r)
{
    uint8_t cr = 0, cg = 0, cb = 0, ca = 0;
    int bm = 0, mx = 0, my = 0, pass, row, col;
    float lx, ly;

    if (!p_FillRect || !p_SetDrawColor)
        return;

    p_GetMouseState(&mx, &my);
    lx = mx;
    ly = my;
    if (p_WinToLogical)
        p_WinToLogical(r, mx, my, &lx, &ly);

    if (p_GetDrawColor) p_GetDrawColor(r, &cr, &cg, &cb, &ca);
    if (p_GetBlend)     p_GetBlend(r, &bm);
    if (p_SetBlend)     p_SetBlend(r, 1);

    for (pass = 0; pass < 2; pass++) {
        char want = pass ? '#' : 'o';
        uint8_t c = pass ? 255 : 0;

        p_SetDrawColor(r, c, c, c, 255);
        for (row = 0; row < ARROW_H; row++)
            for (col = 0; ARROW[row][col]; col++) {
                RECT q = { (int)lx + col * scale, (int)ly + row * scale, scale, scale };
                if (ARROW[row][col] == want)
                    p_FillRect(r, &q);
            }
    }

    if (p_GetDrawColor) p_SetDrawColor(r, cr, cg, cb, ca);
    if (p_SetBlend)     p_SetBlend(r, bm);
}

void SDL_RenderPresent(void *renderer)
{
    init();
    if (renderer) {
        poll_keys();
        if (want_cursor())
            draw_renderer(renderer);
    }
    in_render_present = 1;
    if (p_RenderPresent)
        p_RenderPresent(renderer);
    in_render_present = 0;
}

/* --- raw GLES2 path ----------------------------------------------------- */
static void draw_gl(void *window)
{
    int w = 0, h = 0, dw = 0, dh = 0, mx = 0, my = 0, row, col, pass;
    float sx = 1.0f, sy = 1.0f;
    int box[4];
    float clr[4];
    unsigned char mask[4], sc, depth, sten;

    init_gl();
    if (!gl_ready || !p_GetWindowSize)
        return;

    p_GetWindowSize(window, &w, &h);
    if (w <= 0 || h <= 0)
        return;
    dw = w; dh = h;
    if (p_GetDrawableSize)
        p_GetDrawableSize(window, &dw, &dh);
    sx = (float)dw / w;
    sy = (float)dh / h;

    p_GetMouseState(&mx, &my);

    sc    = p_glIsEnabled(GL_SCISSOR_TEST);
    depth = p_glIsEnabled(GL_DEPTH_TEST);
    sten  = p_glIsEnabled(GL_STENCIL_TEST);
    p_glGetIntegerv(GL_SCISSOR_BOX, box);
    p_glGetFloatv(GL_COLOR_CLEAR_VALUE, clr);
    p_glGetBooleanv(GL_COLOR_WRITEMASK, mask);

    p_glDisable(GL_DEPTH_TEST);
    p_glDisable(GL_STENCIL_TEST);
    p_glColorMask(1, 1, 1, 1);
    p_glEnable(GL_SCISSOR_TEST);

    /* filled squares via scissor + clear: no shaders needed */
    for (pass = 0; pass < 2; pass++) {
        char want = pass ? '#' : 'o';
        float c = pass ? 1.0f : 0.0f;

        p_glClearColor(c, c, c, 1.0f);
        for (row = 0; row < ARROW_H; row++)
            for (col = 0; ARROW[row][col]; col++) {
                int x = (int)((mx + col * scale) * sx);
                int y = (int)((my + (row + 1) * scale) * sy);
                if (ARROW[row][col] != want)
                    continue;
                p_glScissor(x, dh - y, (int)(scale * sx + 0.5f), (int)(scale * sy + 0.5f));
                p_glClear(GL_COLOR_BUFFER_BIT);
            }
    }

    p_glScissor(box[0], box[1], box[2], box[3]);
    p_glClearColor(clr[0], clr[1], clr[2], clr[3]);
    p_glColorMask(mask[0], mask[1], mask[2], mask[3]);
    if (!sc)   p_glDisable(GL_SCISSOR_TEST);
    if (depth) p_glEnable(GL_DEPTH_TEST);
    if (sten)  p_glEnable(GL_STENCIL_TEST);
}

void SDL_GL_SwapWindow(void *window)
{
    init();
    if (!in_render_present) {
        poll_keys();
        if (want_cursor())
            draw_gl(window);
    }
    if (p_SwapWindow)
        p_SwapWindow(window);
}

/* the hardware cursor doesn't exist; keep apps from hiding "it" */
int SDL_ShowCursor(int toggle)
{
    (void)toggle;
    return 1;
}
