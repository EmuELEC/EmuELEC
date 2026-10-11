/* dreamm_cursor.c - software mouse pointer for SDL2 video drivers without one
 *
 * Build (WSL, EmuELEC toolchain):
 *   $TC/bin/aarch64-libreelec-linux-gnu-gcc \
 *       --sysroot=$TC/aarch64-libreelec-linux-gnu/sysroot \
 *       -shared -fPIC -O2 -o dreamm_cursor.so dreamm_cursor.c -ldl
 *
 * Usage:
 *   LD_PRELOAD=/usr/lib/dreamm_cursor.so dreamm -sdl -fullscreen
 *
 * Rationale: EmuELEC's SDL2 only provides the "mali" and "offscreen" video
 * drivers. The mali backend implements no cursor at all, so SDL_ShowCursor()
 * succeeds but draws nothing. This shim hooks SDL_RenderPresent and draws the
 * pointer onto the application's own renderer instead.
 *
 * Env:
 *   DREAMM_CURSOR=0          disable the overlay entirely (for games that
 *                            draw their own cursor, e.g. Dark Forces)
 *   DREAMM_CURSOR_SCALE=3    pointer size (default 3)
 *   DREAMM_CURSOR_TOGGLE=68  SDL scancode that toggles the pointer at runtime
 *                            (default 68 = F11, 0 disables the hotkey)
 *   DREAMM_CURSOR_DEBUG=1    log mouse coordinates to stderr
 *   DREAMM_MENU_KEY=67       SDL scancode that opens DREAMM's in-game menu
 *                            (default 67 = F10, 0 disables it)
 *
 * gptokeyb can only emit F1-F10 and cannot send modifier combinations, so
 * neither F12 nor ALT+U -- DREAMM's own shortcuts for the in-game menu -- can
 * be produced from a controller. The menu key above is therefore translated
 * into a synthetic F12 key event, which DREAMM picks up as if it came from a
 * real keyboard. The menu itself is mouse driven, so it is fully usable with
 * the stick and R1 once it is open.
 *
 * The toggle key is sampled from SDL_GetKeyboardState once per presented
 * frame. The event queue is deliberately left untouched: hooking it means a
 * short press can be consumed by the application before the hook runs, and
 * removing the key from the stream also stops SDL from tracking its state.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define SCANCODE_F10 67
#define SCANCODE_F11 68
#define SCANCODE_F12 69

/* SDL_Event field offsets, stable across SDL 2.0.x on all supported ABIs */
#define EV_SIZE          56
#define EV_OFF_TYPE       0   /* Uint32 */
#define EV_OFF_TIMESTAMP  4   /* Uint32 */
#define EV_OFF_WINDOWID   8   /* Uint32 */
#define EV_OFF_STATE     12   /* Uint8  */
#define EV_OFF_REPEAT    13   /* Uint8  */
#define EV_OFF_SCANCODE  16   /* int    */
#define EV_OFF_SYM       20   /* Sint32 */
#define EV_OFF_MOD       24   /* Uint16 */

#define EV_KEYDOWN    0x300
#define EV_KEYUP      0x301
#define SDL_PRESSED_  1
#define SDL_RELEASED_ 0

/* SDLK_F12 == SDL_SCANCODE_F12 | SDLK_SCANCODE_MASK */
#define SDLK_SCANCODE_MASK_ (1 << 30)
#define SDLK_F12_ (SCANCODE_F12 | SDLK_SCANCODE_MASK_)

typedef struct { int x, y, w, h; } RECT;

static void     (*p_RenderPresent)(void *);
static uint32_t (*p_GetMouseState)(int *, int *);
static int      (*p_SetDrawColor)(void *, uint8_t, uint8_t, uint8_t, uint8_t);
static int      (*p_GetDrawColor)(void *, uint8_t *, uint8_t *, uint8_t *, uint8_t *);
static int      (*p_FillRect)(void *, const RECT *);
static int      (*p_WinToLogical)(void *, int, int, float *, float *);
static int      (*p_GetScale)(void *, float *, float *);
static int      (*p_SetBlend)(void *, int);
static int      (*p_GetBlend)(void *, int *);
static const uint8_t *(*p_GetKeyboardState)(int *);
static int      (*p_PushEvent)(void *);
static uint32_t (*p_GetTicks)(void);

/* 'o' = black outline, '#' = white fill, ' ' = transparent */
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

static int cursor_visible = 1;   /* toggled at runtime by the hotkey */
static int cursor_enabled = -1;  /* -1 = env not probed yet */
static int cursor_scale   = 3;
static int cursor_debug   = 0;
static int toggle_key     = SCANCODE_F11;
static int menu_key       = SCANCODE_F10;

static void resolve(void)
{
    if (p_RenderPresent)
        return;

    p_RenderPresent    = dlsym(RTLD_NEXT,    "SDL_RenderPresent");
    p_GetMouseState    = dlsym(RTLD_DEFAULT, "SDL_GetMouseState");
    p_SetDrawColor     = dlsym(RTLD_DEFAULT, "SDL_SetRenderDrawColor");
    p_GetDrawColor     = dlsym(RTLD_DEFAULT, "SDL_GetRenderDrawColor");
    p_FillRect         = dlsym(RTLD_DEFAULT, "SDL_RenderFillRect");
    p_WinToLogical     = dlsym(RTLD_DEFAULT, "SDL_RenderWindowToLogical");
    p_GetScale         = dlsym(RTLD_DEFAULT, "SDL_RenderGetScale");
    p_SetBlend         = dlsym(RTLD_DEFAULT, "SDL_SetRenderDrawBlendMode");
    p_GetBlend         = dlsym(RTLD_DEFAULT, "SDL_GetRenderDrawBlendMode");
    p_GetKeyboardState = dlsym(RTLD_DEFAULT, "SDL_GetKeyboardState");
    p_PushEvent        = dlsym(RTLD_DEFAULT, "SDL_PushEvent");
    p_GetTicks         = dlsym(RTLD_DEFAULT, "SDL_GetTicks");
}

static void probe_env(void)
{
    const char *e;

    cursor_enabled = 1;
    if ((e = getenv("DREAMM_CURSOR")) != NULL && atoi(e) == 0)
        cursor_enabled = 0;

    if ((e = getenv("DREAMM_CURSOR_SCALE")) != NULL) {
        cursor_scale = atoi(e);
        if (cursor_scale < 1)
            cursor_scale = 1;
    }

    if ((e = getenv("DREAMM_CURSOR_TOGGLE")) != NULL)
        toggle_key = atoi(e);

    if ((e = getenv("DREAMM_MENU_KEY")) != NULL)
        menu_key = atoi(e);

    if (getenv("DREAMM_CURSOR_DEBUG") != NULL)
        cursor_debug = 1;
}

/* Queue a synthetic key event for the given scancode. */
static void push_key(int scancode, int32_t sym, int down)
{
    char ev[EV_SIZE];

    if (!p_PushEvent)
        return;

    memset(ev, 0, sizeof(ev));
    *(uint32_t *)(ev + EV_OFF_TYPE)      = down ? EV_KEYDOWN : EV_KEYUP;
    *(uint32_t *)(ev + EV_OFF_TIMESTAMP) = p_GetTicks ? p_GetTicks() : 0;
    *(uint32_t *)(ev + EV_OFF_WINDOWID)  = 0;
    *(uint8_t  *)(ev + EV_OFF_STATE)     = down ? SDL_PRESSED_ : SDL_RELEASED_;
    *(uint8_t  *)(ev + EV_OFF_REPEAT)    = 0;
    *(int      *)(ev + EV_OFF_SCANCODE)  = scancode;
    *(int32_t  *)(ev + EV_OFF_SYM)       = sym;
    *(uint16_t *)(ev + EV_OFF_MOD)       = 0;

    p_PushEvent(ev);
}

/* Translate the controller-reachable menu key into DREAMM's own F12 shortcut.
 *
 * gptokeyb cannot emit F11/F12 or modifier combinations, so ALT+U and F12 are
 * both out of reach from a pad. Injecting the event here gives DREAMM exactly
 * what it expects. */
static void poll_menu(void)
{
    static int held = 0;
    const uint8_t *keys;
    int now;

    if (!menu_key || !p_GetKeyboardState)
        return;

    keys = p_GetKeyboardState(NULL);
    if (!keys)
        return;

    now = keys[menu_key];

    if (now && !held) {
        push_key(SCANCODE_F12, SDLK_F12_, 1);
        push_key(SCANCODE_F12, SDLK_F12_, 0);
        if (cursor_debug)
            fprintf(stderr, "[cursor] injected F12 (menu)\n");
    }
    held = now;
}

/* Poll the toggle key once per presented frame.
 *
 * SDL_GetKeyboardState returns a state array that SDL keeps updated as it
 * processes events, so checking it every frame catches any press that lasts
 * at least one frame -- unlike hooking the event queue, where a short press
 * can be consumed by the application before our hook ever runs.
 *
 * The key is deliberately left in the event stream: DREAMM does not bind F11,
 * and letting SDL see it is what keeps this state array accurate. */
static void poll_toggle(void)
{
    static int held = 0;
    const uint8_t *keys;
    int now;

    if (!toggle_key || !p_GetKeyboardState)
        return;

    keys = p_GetKeyboardState(NULL);
    if (!keys)
        return;

    now = keys[toggle_key];

    /* rising edge only: one toggle per press, however long it is held */
    if (now && !held) {
        cursor_visible = !cursor_visible;
        if (cursor_debug)
            fprintf(stderr, "[cursor] toggled %s\n",
                    cursor_visible ? "on" : "off");
    }
    held = now;
}

static void draw_cursor(void *r)
{
    uint8_t or_ = 0, og = 0, ob = 0, oa = 0;
    int obm = 0;
    int mx = 0, my = 0;
    float lx, ly;
    int s = cursor_scale;
    int pass, row, col;

    if (!p_GetMouseState || !p_FillRect || !p_SetDrawColor)
        return;

    p_GetMouseState(&mx, &my);

    /* window coordinates -> renderer logical coordinates */
    if (p_WinToLogical) {
        p_WinToLogical(r, mx, my, &lx, &ly);
    } else if (p_GetScale) {
        float sx = 1.0f, sy = 1.0f;
        p_GetScale(r, &sx, &sy);
        lx = mx / (sx > 0.0f ? sx : 1.0f);
        ly = my / (sy > 0.0f ? sy : 1.0f);
    } else {
        lx = (float)mx;
        ly = (float)my;
    }

    if (cursor_debug)
        fprintf(stderr, "[cursor] win=%d,%d log=%.1f,%.1f\n", mx, my, lx, ly);

    /* save the renderer state we touch */
    if (p_GetDrawColor)
        p_GetDrawColor(r, &or_, &og, &ob, &oa);
    if (p_GetBlend)
        p_GetBlend(r, &obm);
    if (p_SetBlend)
        p_SetBlend(r, 1);   /* SDL_BLENDMODE_BLEND */

    /* pass 0 = outline, pass 1 = fill */
    for (pass = 0; pass < 2; pass++) {
        char want = pass ? '#' : 'o';

        if (pass)
            p_SetDrawColor(r, 255, 255, 255, 255);
        else
            p_SetDrawColor(r, 0, 0, 0, 255);

        for (row = 0; row < ARROW_H; row++) {
            const char *line = ARROW[row];

            for (col = 0; line[col]; col++) {
                RECT q;

                if (line[col] != want)
                    continue;

                q.x = (int)lx + col * s;
                q.y = (int)ly + row * s;
                q.w = s;
                q.h = s;
                p_FillRect(r, &q);
            }
        }
    }

    /* restore */
    if (p_GetDrawColor)
        p_SetDrawColor(r, or_, og, ob, oa);
    if (p_SetBlend)
        p_SetBlend(r, obm);
}

void SDL_RenderPresent(void *renderer)
{
    resolve();

    if (cursor_enabled < 0)
        probe_env();

    if (renderer) {
        poll_menu();
        if (cursor_enabled) {
            poll_toggle();
            if (cursor_visible)
                draw_cursor(renderer);
        }
    }

    if (p_RenderPresent)
        p_RenderPresent(renderer);
}

/* swallow attempts to hide the (non-existent) hardware cursor */
int SDL_ShowCursor(int toggle)
{
    (void)toggle;
    return 1;
}