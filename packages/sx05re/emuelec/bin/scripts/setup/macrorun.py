#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED USING AI

import json, os, select, sys, time, threading, queue, mmap
from typing import List, Optional
from evdev import InputDevice, list_devices, ecodes as e, UInput

class GoBack(Exception):   pass
class UserQuit(Exception): pass

CFG = "/storage/.config/emuelec/scripts/macro_config.json"
PID = "/tmp/macrorun.pid"
LOG = "/tmp/macrorun.log"
DZ  = 0.30
_AC = {}
_GB = [e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST]

_TL = {e.BTN_SOUTH:"A", e.BTN_EAST:"B", e.BTN_NORTH:"X", e.BTN_WEST:"Y",
       e.BTN_TL:"L1", e.BTN_TR:"R1", e.BTN_TL2:"L2", e.BTN_TR2:"R2",
       e.BTN_THUMBL:"L3", e.BTN_THUMBR:"R3", e.BTN_START:"START", e.BTN_SELECT:"SELECT",
       e.BTN_MODE:"HOME", e.BTN_DPAD_UP:"D↑", e.BTN_DPAD_DOWN:"D↓",
       e.BTN_DPAD_LEFT:"D<", e.BTN_DPAD_RIGHT:"D>"}

_AX = {e.ABS_X:"X", e.ABS_Y:"Y", e.ABS_RX:"RX", e.ABS_RY:"RY",
       e.ABS_Z:"Z", e.ABS_RZ:"RZ", e.ABS_HAT0X:"HATX", e.ABS_HAT0Y:"HATY"}

_B2K = {e.BTN_DPAD_UP:e.KEY_UP, e.BTN_DPAD_DOWN:e.KEY_DOWN,
        e.BTN_DPAD_LEFT:e.KEY_LEFT, e.BTN_DPAD_RIGHT:e.KEY_RIGHT,
        e.BTN_SOUTH:e.KEY_Z, e.BTN_EAST:e.KEY_X,
        e.BTN_NORTH:e.KEY_A, e.BTN_WEST:e.KEY_S,
        e.BTN_TL:e.KEY_Q, e.BTN_TR:e.KEY_W,
        e.BTN_TL2:e.KEY_E, e.BTN_TR2:e.KEY_R}

_A2K = {e.ABS_X:{1:e.KEY_RIGHT,-1:e.KEY_LEFT}, e.ABS_Y:{1:e.KEY_DOWN,-1:e.KEY_UP},
        e.ABS_RX:{1:e.KEY_D,-1:e.KEY_A}, e.ABS_RY:{1:e.KEY_S,-1:e.KEY_W},
        e.ABS_Z:{1:e.KEY_E}, e.ABS_RZ:{1:e.KEY_R},
        e.ABS_HAT0X:{1:e.KEY_RIGHT,-1:e.KEY_LEFT}, e.ABS_HAT0Y:{1:e.KEY_DOWN,-1:e.KEY_UP}}


def wait_for_controller(preferred_path=None):
    print("Waiting for controller...", flush=True)
    if preferred_path:
        try:
            dev = InputDevice(preferred_path)
            return dev
        except OSError:
            pass
    while True:
        for path in list_devices():
            try: dev = InputDevice(path)
            except OSError: continue
            caps = dev.capabilities()
            keys = caps.get(e.EV_KEY, [])
            abs_caps = caps.get(e.EV_ABS, [])
            has_face = any(b in keys for b in (e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST))
            has_dpad = any(b in keys for b in (e.BTN_DPAD_UP, e.BTN_DPAD_DOWN, e.BTN_DPAD_LEFT, e.BTN_DPAD_RIGHT))
            has_hat  = any(a in abs_caps for a in (e.ABS_HAT0X, e.ABS_HAT0Y))
            if has_face or has_dpad or has_hat:
                return dev
        time.sleep(1.0)

# Keys that auto-repeat when held
_REPEAT_KEYS   = {'left', 'right', 'up', 'down'}
_REPEAT_DELAY  = 0.4   # seconds before repeat starts
_REPEAT_RATE   = 0.08  # seconds between repeats

def _map_event(event, last_hat_x, last_hat_y):
    """Map a single evdev event to an action string, or None."""
    if event.type == e.EV_KEY and event.value == 1:
        code = event.code
        if code == e.BTN_DPAD_UP:    return 'up',   last_hat_x, last_hat_y
        if code == e.BTN_DPAD_DOWN:  return 'down', last_hat_x, last_hat_y
        if code == e.BTN_DPAD_LEFT:  return 'left', last_hat_x, last_hat_y
        if code == e.BTN_DPAD_RIGHT: return 'right',last_hat_x, last_hat_y
        if code in (e.BTN_SOUTH, e.BTN_START): return 'a', last_hat_x, last_hat_y
        if code == e.BTN_EAST:   return 'b',      last_hat_x, last_hat_y
        if code == e.BTN_NORTH:  return 'y',      last_hat_x, last_hat_y
        if code == e.BTN_WEST:   return 'x',      last_hat_x, last_hat_y
        if code == e.BTN_TL:     return 'l1',     last_hat_x, last_hat_y
        if code == e.BTN_TR:     return 'r1',     last_hat_x, last_hat_y
        if code in (e.BTN_SELECT, e.BTN_MODE): return 'select', last_hat_x, last_hat_y
        if code == e.KEY_UP:    return 'up',    last_hat_x, last_hat_y
        if code == e.KEY_DOWN:  return 'down',  last_hat_x, last_hat_y
        if code == e.KEY_LEFT:  return 'left',  last_hat_x, last_hat_y
        if code == e.KEY_RIGHT: return 'right', last_hat_x, last_hat_y
        if code == e.KEY_ENTER: return 'a',     last_hat_x, last_hat_y
        if code in (e.KEY_ESC, e.KEY_BACKSPACE): return 'b', last_hat_x, last_hat_y
    if event.type == e.EV_ABS:
        if event.code == e.ABS_HAT0Y:
            if event.value < 0 and last_hat_y >= 0:
                return 'up',   last_hat_x, event.value
            if event.value > 0 and last_hat_y <= 0:
                return 'down', last_hat_x, event.value
            return None, last_hat_x, 0
        if event.code == e.ABS_HAT0X:
            if event.value < 0 and last_hat_x >= 0:
                return 'left',  event.value, last_hat_y
            if event.value > 0 and last_hat_x <= 0:
                return 'right', event.value, last_hat_y
            return None, 0, last_hat_y
    return None, last_hat_x, last_hat_y

class ControllerInput:
    def __init__(self, preferred_path=None):
        self.dev         = wait_for_controller(preferred_path)
        self.last_hat_x  = 0
        self.last_hat_y  = 0
        self._held       = None   # currently held repeatable key
        self._held_since = 0.0
        self._next_rep   = 0.0

    def wait_for_input(self) -> str:
        import select as _select
        fd = self.dev.fd
        while True:
            now = time.monotonic()
            # If a repeatable key is held, compute how long to wait
            if self._held:
                wait = max(0.0, self._next_rep - now)
            else:
                wait = 5.0  # no key held — block until event

            ready = _select.select([fd], [], [], wait)[0]

            if ready:
                # Drain all pending events
                action = None
                for event in self.dev.read():
                    # Track key releases to cancel repeat
                    if event.type == e.EV_KEY and event.value == 0:
                        code = event.code
                        released = None
                        if code in (e.BTN_DPAD_LEFT, e.KEY_LEFT):   released = 'left'
                        elif code in (e.BTN_DPAD_RIGHT, e.KEY_RIGHT): released = 'right'
                        elif code in (e.BTN_DPAD_UP, e.KEY_UP):       released = 'up'
                        elif code in (e.BTN_DPAD_DOWN, e.KEY_DOWN):   released = 'down'
                        if released and released == self._held:
                            self._held = None
                    # Hat axis release
                    if event.type == e.EV_ABS:
                        if event.code == e.ABS_HAT0Y and event.value == 0:
                            self.last_hat_y = 0
                            if self._held in ('up', 'down'): self._held = None
                        if event.code == e.ABS_HAT0X and event.value == 0:
                            self.last_hat_x = 0
                            if self._held in ('left', 'right'): self._held = None
                    mapped, self.last_hat_x, self.last_hat_y = _map_event(
                        event, self.last_hat_x, self.last_hat_y)
                    if mapped:
                        action = mapped
                        if mapped in _REPEAT_KEYS:
                            self._held      = mapped
                            self._held_since = time.monotonic()
                            self._next_rep   = self._held_since + _REPEAT_DELAY
                        else:
                            self._held = None
                if action:
                    return action
            else:
                # Timeout — fire repeat if key still held
                if self._held:
                    now = time.monotonic()
                    if now >= self._next_rep:
                        self._next_rep = now + _REPEAT_RATE
                        return self._held

    def close(self):
        try: self.dev.close()
        except: pass

controller = None
def init_controller(preferred_path=None):
    global controller
    controller = ControllerInput(preferred_path)

import ctypes, ctypes.util

_FONT_PATHS = [
    '/storage/.config/emulationstation/resources/ubuntu_condensed.ttf',
    '/usr/bin/resources/ubuntu_condensed.ttf',
    '/storage/.config/emulationstation/resources/opensans_hebrew_condensed_regular.ttf',
    '/usr/bin/resources/opensans_hebrew_condensed_regular.ttf',
    '/storage/.config/emulationstation/resources/Rubik-Regular.ttf',
    '/usr/bin/resources/Rubik-Regular.ttf',
    '/usr/share/kodi/media/Fonts/DejaVuSans.ttf',
]
_FONT_SIZE_PX = 28   

class _FTGeneric(ctypes.Structure):
    _fields_ = [('data', ctypes.c_void_p), ('finalizer', ctypes.c_void_p)]

class _FTBitmap(ctypes.Structure):
    _fields_ = [('rows', ctypes.c_uint), ('width', ctypes.c_uint),
                ('pitch', ctypes.c_int),
                ('buffer', ctypes.POINTER(ctypes.c_ubyte)),
                ('num_grays', ctypes.c_ushort), ('pixel_mode', ctypes.c_ubyte),
                ('palette_mode', ctypes.c_ubyte), ('palette', ctypes.c_void_p)]

class _FTVector(ctypes.Structure):
    _fields_ = [('x', ctypes.c_long), ('y', ctypes.c_long)]

class _FTGlyphMetrics(ctypes.Structure):
    _fields_ = [(n, ctypes.c_long) for n in
                ('width', 'height', 'horiBearingX', 'horiBearingY',
                 'horiAdvance', 'vertBearingX', 'vertBearingY', 'vertAdvance')]

class _FTGlyphSlot(ctypes.Structure):
    _fields_ = [('library', ctypes.c_void_p), ('face', ctypes.c_void_p),
                ('next', ctypes.c_void_p), ('glyph_index', ctypes.c_uint),
                ('generic', _FTGeneric), ('metrics', _FTGlyphMetrics),
                ('linearHoriAdvance', ctypes.c_long),
                ('linearVertAdvance', ctypes.c_long),
                ('advance', _FTVector), ('format', ctypes.c_int),
                ('bitmap', _FTBitmap),
                ('bitmap_left', ctypes.c_int), ('bitmap_top', ctypes.c_int)]
                # (trailing FT fields not needed)

class _FTBBox(ctypes.Structure):
    _fields_ = [(n, ctypes.c_long) for n in ('xMin', 'yMin', 'xMax', 'yMax')]

class _FTSizeMetrics(ctypes.Structure):
    _fields_ = [('x_ppem', ctypes.c_ushort), ('y_ppem', ctypes.c_ushort),
                ('x_scale', ctypes.c_long), ('y_scale', ctypes.c_long),
                ('ascender', ctypes.c_long), ('descender', ctypes.c_long),
                ('height', ctypes.c_long), ('max_advance', ctypes.c_long)]

class _FTSize(ctypes.Structure):
    _fields_ = [('face', ctypes.c_void_p), ('generic', _FTGeneric),
                ('metrics', _FTSizeMetrics), ('internal', ctypes.c_void_p)]

class _FTFace(ctypes.Structure):
    _fields_ = [('num_faces', ctypes.c_long), ('face_index', ctypes.c_long),
                ('face_flags', ctypes.c_long), ('style_flags', ctypes.c_long),
                ('num_glyphs', ctypes.c_long),
                ('family_name', ctypes.c_char_p), ('style_name', ctypes.c_char_p),
                ('num_fixed_sizes', ctypes.c_int), ('available_sizes', ctypes.c_void_p),
                ('num_charmaps', ctypes.c_int), ('charmaps', ctypes.c_void_p),
                ('generic', _FTGeneric), ('bbox', _FTBBox),
                ('units_per_EM', ctypes.c_ushort),
                ('ascender', ctypes.c_short), ('descender', ctypes.c_short),
                ('height', ctypes.c_short),
                ('max_advance_width', ctypes.c_short),
                ('max_advance_height', ctypes.c_short),
                ('underline_position', ctypes.c_short),
                ('underline_thickness', ctypes.c_short),
                ('glyph', ctypes.POINTER(_FTGlyphSlot)),
                ('size', ctypes.POINTER(_FTSize)),
                ('charmap', ctypes.c_void_p)]

def _load_font():
    font_path = next((p for p in _FONT_PATHS if os.path.isfile(p)), None)
    if not font_path:
        raise SystemExit("ERROR: no usable system TTF found "
                         "(EmulationStation resources / Kodi fonts)")
    ft = None
    for name in ('libfreetype.so.6', 'libfreetype.so',
                 ctypes.util.find_library('freetype')):
        if not name:
            continue
        try:
            ft = ctypes.CDLL(name)
            break
        except OSError:
            continue
    if ft is None:
        raise SystemExit("ERROR: libfreetype not found")

    lib = ctypes.c_void_p()
    if ft.FT_Init_FreeType(ctypes.byref(lib)):
        raise SystemExit("ERROR: FT_Init_FreeType failed")
    face = ctypes.POINTER(_FTFace)()
    if ft.FT_New_Face(lib, font_path.encode(), 0, ctypes.byref(face)):
        raise SystemExit(f"ERROR: cannot open font {font_path}")
    ft.FT_Set_Pixel_Sizes(face, 0, _FONT_SIZE_PX)

    m    = face.contents.size.contents.metrics       # 26.6 fixed point
    asc  = (m.ascender + 63) >> 6
    desc = (-m.descender + 63) >> 6
    ch_h = asc + desc

    FT_LOAD_RENDER = 4
    # Pass 1: widest advance over printable ASCII defines the cell width
    adv, ch_w = {}, 1
    for code in range(32, 127):
        if ft.FT_Load_Char(face, code, FT_LOAD_RENDER):
            continue
        a = face.contents.glyph.contents.advance.x >> 6
        adv[code] = a
        if a > ch_w:
            ch_w = a

    # Pass 2: render every glyph centered into a fixed cell (coverage 0-255)
    glyphs = {}
    for code in range(32, 127):
        cell = bytearray(ch_w * ch_h)
        if ft.FT_Load_Char(face, code, FT_LOAD_RENDER) == 0:
            g, bm = face.contents.glyph.contents, face.contents.glyph.contents.bitmap
            if bm.buffer and bm.pitch > 0:
                x0 = (ch_w - adv.get(code, ch_w)) // 2 + g.bitmap_left
                y0 = asc - g.bitmap_top
                for ry in range(bm.rows):
                    ty = y0 + ry
                    if ty < 0 or ty >= ch_h:
                        continue
                    src, dst = ry * bm.pitch, ty * ch_w
                    for rx in range(bm.width):
                        tx = x0 + rx
                        if 0 <= tx < ch_w and bm.buffer[src + rx] > cell[dst + tx]:
                            cell[dst + tx] = bm.buffer[src + rx]
        glyphs[code] = bytes(cell)

    ft.FT_Done_Face(face)
    ft.FT_Done_FreeType(lib)
    return ch_w, ch_h, glyphs

CELL_W, CELL_H, GLYPHS = _load_font()  # cell size derived from font metrics

# Glyph render cache: (char_code, fg_bytes, bg_bytes) -> rendered bytes (CELL_H*CELL_W*4)
_GLYPH_CACHE = {}
_GLYPH_ROW   = CELL_W * 4

def _prerender(ch: int, fg: bytes, bg: bytes) -> bytes:
    key = (ch, fg, bg)
    cached = _GLYPH_CACHE.get(key)
    if cached: return cached
    glyph = GLYPHS.get(ch, GLYPHS[32])
    buf = bytearray(CELL_H * _GLYPH_ROW)
    for row_i in range(CELL_H):
        base = row_i * _GLYPH_ROW
        row_base = row_i * CELL_W
        for col_i in range(CELL_W):
            p = base + col_i * 4
            buf[p:p+4] = fg if glyph[row_base + col_i] > 128 else bg
    result = bytes(buf)
    _GLYPH_CACHE[key] = result
    return result

# ---------------------------------------------------------------------------
# Framebuffer renderer
# ---------------------------------------------------------------------------
FB_DEV    = '/dev/fb0'
FB_W      = 1920
FB_H      = 1080
FB_BPP    = 4          # BGRA32
FB_STRIDE = FB_W * FB_BPP

# Colour palette (BGRA bytes)
COL_BG      = bytes([0x18, 0x18, 0x18, 0xFF])   # dark grey
COL_FG      = bytes([0xFF, 0xFF, 0xFF, 0xFF])   # white
COL_SEL_BG  = bytes([0xFF, 0xFF, 0xFF, 0xFF])   # white background for selection
COL_SEL_FG  = bytes([0x18, 0x18, 0x18, 0xFF])   # dark text on white
COL_TITLE   = bytes([0x00, 0xD0, 0xD0, 0xFF])   # cyan
COL_DIM     = bytes([0x80, 0x80, 0x80, 0xFF])   # grey
COL_BORDER  = bytes([0x40, 0x40, 0x40, 0xFF])   # dark border
COL_YELLOW  = bytes([0x00, 0xD0, 0xFF, 0xFF])   # yellow (BGRA)

COLS = FB_W // CELL_W   # ~101
ROWS = FB_H // CELL_H   # ~45

_fb_file = None
_fb_map  = None
_bb      = None   # back-buffer (bytearray)
_bb_mv   = None   # memoryview into _bb for fast row writes

def fb_open():
    global _fb_file, _fb_map, _bb, _bb_mv
    _fb_file = open(FB_DEV, 'rb+')
    _fb_map  = mmap.mmap(_fb_file.fileno(), FB_W * FB_H * FB_BPP)
    _bb      = bytearray(FB_W * FB_H * FB_BPP)
    _bb_mv   = memoryview(_bb)

def fb_close():
    if _fb_map:  _fb_map.close()
    if _fb_file: _fb_file.close()

def fb_flip():
    """Blit back-buffer to framebuffer in one write — eliminates flicker."""
    _fb_map[0:FB_W * FB_H * FB_BPP] = _bb

def fb_fill(color: bytes):
    """Fill back-buffer with one colour."""
    row = color * FB_W
    for y in range(FB_H):
        off = y * FB_STRIDE
        _bb[off:off + FB_STRIDE] = row

def fb_rect(x: int, y: int, w: int, h: int, color: bytes):
    row = color * w
    x_off = x * FB_BPP
    row_bytes = w * FB_BPP
    for row_y in range(y, min(y + h, FB_H)):
        off = row_y * FB_STRIDE + x_off
        _bb[off:off + row_bytes] = row

def fb_char(cx: int, cy: int, ch: int, fg: bytes, bg: bytes):
    """Draw one character cell — uses pre-rendered cache + memoryview slices."""
    rendered = _prerender(ch, fg, bg)
    src = memoryview(rendered)
    base = cy * FB_STRIDE + cx * FB_BPP
    for row_i in range(CELL_H):
        dst = base + row_i * FB_STRIDE
        _bb_mv[dst:dst + _GLYPH_ROW] = src[row_i * _GLYPH_ROW:(row_i + 1) * _GLYPH_ROW]

def fb_text(col: int, row: int, text: str, fg: bytes, bg: bytes, max_cols: int = 0):
    """Draw text at grid position (col, row) into back-buffer."""
    if max_cols > 0:
        text = text[:max_cols]
    x = col * CELL_W
    y = row * CELL_H
    for i, ch in enumerate(text):
        if col + i >= COLS:
            break
        fb_char(x + i * CELL_W, y, ord(ch), fg, bg)

def fb_text_centered(row: int, text: str, fg: bytes, bg: bytes, fill_row: bool = False):
    if fill_row:
        fb_rect(0, row * CELL_H, FB_W, CELL_H, bg)
    col = max(0, (COLS - len(text)) // 2)
    fb_text(col, row, text, fg, bg)

def fb_fill_row(row: int, color: bytes):
    fb_rect(0, row * CELL_H, FB_W, CELL_H, color)

def fb_hline(row: int, char: str = '─'):
    fb_text(0, row, char * COLS, COL_BORDER, COL_BG)

# ---------------------------------------------------------------------------
# Input constants / classes  (unchanged from original)
# ---------------------------------------------------------------------------
ROM_PLACEHOLDER = "<ROM_PATH>"
MAX_CMD_LEN = 256
CMD_ALPHABET = list("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 -_./\\()[]{}\"'=:,;")

DEFAULT_LISTMEDIA_FILE = "/storage/roms/listmedia.txt"
SYSTEM_LISTMEDIA_FILE  = "/usr/bin/scripts/setup/listmedia.txt"

class UserQuit(Exception): pass
class GoBack(Exception):   pass

class MediaEntry:
    def __init__(self, system, media_name, brief, exts):
        self.system = system; self.media_name = media_name
        self.brief = brief;   self.exts = exts

# ---------------------------------------------------------------------------
# Controller input (unchanged)
# ---------------------------------------------------------------------------
def wait_for_controller(preferred_path=None):
    print("Waiting for controller...", flush=True)
    if preferred_path:
        try:
            dev = InputDevice(preferred_path)
            return dev
        except OSError:
            pass
    while True:
        for path in list_devices():
            try: dev = InputDevice(path)
            except OSError: continue
            caps = dev.capabilities()
            keys = caps.get(e.EV_KEY, [])
            abs_caps = caps.get(e.EV_ABS, [])
            has_face = any(b in keys for b in (e.BTN_SOUTH, e.BTN_EAST, e.BTN_NORTH, e.BTN_WEST))
            has_dpad = any(b in keys for b in (e.BTN_DPAD_UP, e.BTN_DPAD_DOWN, e.BTN_DPAD_LEFT, e.BTN_DPAD_RIGHT))
            has_hat  = any(a in abs_caps for a in (e.ABS_HAT0X, e.ABS_HAT0Y))
            if has_face or has_dpad or has_hat:
                return dev
        time.sleep(1.0)

# Keys that auto-repeat when held
_REPEAT_KEYS   = {'left', 'right', 'up', 'down'}
_REPEAT_DELAY  = 0.4   # seconds before repeat starts
_REPEAT_RATE   = 0.08  # seconds between repeats

def _map_event(event, last_hat_x, last_hat_y):
    """Map a single evdev event to an action string, or None."""
    if event.type == e.EV_KEY and event.value == 1:
        code = event.code
        if code == e.BTN_DPAD_UP:    return 'up',   last_hat_x, last_hat_y
        if code == e.BTN_DPAD_DOWN:  return 'down', last_hat_x, last_hat_y
        if code == e.BTN_DPAD_LEFT:  return 'left', last_hat_x, last_hat_y
        if code == e.BTN_DPAD_RIGHT: return 'right',last_hat_x, last_hat_y
        if code in (e.BTN_SOUTH, e.BTN_START): return 'a', last_hat_x, last_hat_y
        if code == e.BTN_EAST:   return 'b',      last_hat_x, last_hat_y
        if code == e.BTN_NORTH:  return 'y',      last_hat_x, last_hat_y
        if code == e.BTN_WEST:   return 'x',      last_hat_x, last_hat_y
        if code == e.BTN_TL:     return 'l1',     last_hat_x, last_hat_y
        if code == e.BTN_TR:     return 'r1',     last_hat_x, last_hat_y
        if code in (e.BTN_SELECT, e.BTN_MODE): return 'select', last_hat_x, last_hat_y
        if code == e.KEY_UP:    return 'up',    last_hat_x, last_hat_y
        if code == e.KEY_DOWN:  return 'down',  last_hat_x, last_hat_y
        if code == e.KEY_LEFT:  return 'left',  last_hat_x, last_hat_y
        if code == e.KEY_RIGHT: return 'right', last_hat_x, last_hat_y
        if code == e.KEY_ENTER: return 'a',     last_hat_x, last_hat_y
        if code in (e.KEY_ESC, e.KEY_BACKSPACE): return 'b', last_hat_x, last_hat_y
    if event.type == e.EV_ABS:
        if event.code == e.ABS_HAT0Y:
            if event.value < 0 and last_hat_y >= 0:
                return 'up',   last_hat_x, event.value
            if event.value > 0 and last_hat_y <= 0:
                return 'down', last_hat_x, event.value
            return None, last_hat_x, 0
        if event.code == e.ABS_HAT0X:
            if event.value < 0 and last_hat_x >= 0:
                return 'left',  event.value, last_hat_y
            if event.value > 0 and last_hat_x <= 0:
                return 'right', event.value, last_hat_y
            return None, 0, last_hat_y
    return None, last_hat_x, last_hat_y

class ControllerInput:
    def __init__(self, preferred_path=None):
        self.dev         = wait_for_controller(preferred_path)
        self.last_hat_x  = 0
        self.last_hat_y  = 0
        self._held       = None   # currently held repeatable key
        self._held_since = 0.0
        self._next_rep   = 0.0

    def wait_for_input(self) -> str:
        import select as _select
        fd = self.dev.fd
        while True:
            now = time.monotonic()
            # If a repeatable key is held, compute how long to wait
            if self._held:
                wait = max(0.0, self._next_rep - now)
            else:
                wait = 5.0  # no key held — block until event

            ready = _select.select([fd], [], [], wait)[0]

            if ready:
                # Drain all pending events
                action = None
                for event in self.dev.read():
                    # Track key releases to cancel repeat
                    if event.type == e.EV_KEY and event.value == 0:
                        code = event.code
                        released = None
                        if code in (e.BTN_DPAD_LEFT, e.KEY_LEFT):   released = 'left'
                        elif code in (e.BTN_DPAD_RIGHT, e.KEY_RIGHT): released = 'right'
                        elif code in (e.BTN_DPAD_UP, e.KEY_UP):       released = 'up'
                        elif code in (e.BTN_DPAD_DOWN, e.KEY_DOWN):   released = 'down'
                        if released and released == self._held:
                            self._held = None
                    # Hat axis release
                    if event.type == e.EV_ABS:
                        if event.code == e.ABS_HAT0Y and event.value == 0:
                            self.last_hat_y = 0
                            if self._held in ('up', 'down'): self._held = None
                        if event.code == e.ABS_HAT0X and event.value == 0:
                            self.last_hat_x = 0
                            if self._held in ('left', 'right'): self._held = None
                    mapped, self.last_hat_x, self.last_hat_y = _map_event(
                        event, self.last_hat_x, self.last_hat_y)
                    if mapped:
                        action = mapped
                        if mapped in _REPEAT_KEYS:
                            self._held      = mapped
                            self._held_since = time.monotonic()
                            self._next_rep   = self._held_since + _REPEAT_DELAY
                        else:
                            self._held = None
                if action:
                    return action
            else:
                # Timeout — fire repeat if key still held
                if self._held:
                    now = time.monotonic()
                    if now >= self._next_rep:
                        self._next_rep = now + _REPEAT_RATE
                        return self._held

    def close(self):
        try: self.dev.close()
        except: pass

controller = None
def init_controller(preferred_path=None):
    global controller
    controller = ControllerInput(preferred_path)

# ---------------------------------------------------------------------------
# UI rendering
# ---------------------------------------------------------------------------
TITLE_ROW    = 0
SUBTITLE_ROW = 1
SEP1_ROW     = 2
INFO_START   = 3
LIST_START   = 5
LIST_ROWS    = ROWS - LIST_START - 3   # visible list items
SEP2_ROW     = ROWS - 3
HINT_ROW     = ROWS - 2
SEP3_ROW     = ROWS - 1

def draw_screen(title: str, items: List[str], selected: int, offset: int,
                info: str = "", total: int = 0):
    fb_fill(COL_BG)
    # Title bar
    fb_fill_row(TITLE_ROW, COL_SEL_BG)
    fb_text_centered(TITLE_ROW, f"  {title}  ", COL_SEL_FG, COL_SEL_BG)
    # Subtitle / counter
    if total > 0:
        sub = f"{selected+1}/{total}"
        fb_text(COLS - len(sub) - 2, SUBTITLE_ROW, sub, COL_DIM, COL_BG)
    # Separator
    fb_hline(SEP1_ROW)
    # Info lines — dynamic height, max half the screen
    info_lines = info.split('\n') if info else []
    max_info = (ROWS - 8) // 2  # never use more than half the screen for info
    info_lines = info_lines[:max_info]
    for i, line in enumerate(info_lines):
        # First line cyan, rest white (for cmd content block)
        col = COL_TITLE if i == 0 else (COL_DIM if not line.strip() else COL_FG)
        fb_text(2, INFO_START + i, line[:COLS-4], col, COL_BG)
    # Dynamic list start: below info block
    list_start = INFO_START + max(len(info_lines), 1) + 1
    list_rows  = SEP2_ROW - list_start
    # List items
    end = min(offset + list_rows, len(items))
    for i in range(offset, end):
        row = list_start + (i - offset)
        text = items[i]
        is_confirm = text.startswith('--- ') and text.endswith(' ---')
        is_sep     = text.startswith('--- ') and not text.endswith(' ---')
        if len(text) > COLS - 4:
            text = text[:COLS - 7] + '...'
        if is_confirm:
            # Green separator line above confirm entry
            if row > list_start:
                sep_color = bytes([0x00, 0x80, 0x00, 0xFF])
                fb_rect(0, (row - 1) * CELL_H + CELL_H - 2, FB_W, 2, sep_color)
            if i == selected:
                fb_fill_row(row, bytes([0x00, 0x90, 0x00, 0xFF]))
                fb_text_centered(row, f"> {text} <", bytes([0xE0, 0xFF, 0xE0, 0xFF]), bytes([0x00, 0x90, 0x00, 0xFF]))
            else:
                fb_fill_row(row, COL_BG)
                fb_text_centered(row, text, bytes([0x00, 0xD0, 0x00, 0xFF]), COL_BG)
        elif is_sep:
            fb_fill_row(row, COL_BG)
            fb_text(2, row, text, COL_DIM, COL_BG, COLS - 2)
        elif i == selected:
            fb_fill_row(row, COL_SEL_BG)
            fb_text(2, row, f"> {text}", COL_SEL_FG, COL_SEL_BG, COLS - 2)
        else:
            fb_text(2, row, f"  {text}", COL_FG, COL_BG, COLS - 2)
    # Scroll indicator
    if end < len(items):
        fb_text(COLS - 5, list_start + list_rows - 1, " ... ", COL_DIM, COL_BG)
    # Bottom bar
    fb_hline(SEP2_ROW)
    hint = "D-Pad:Navigate  A:Select  B:Back  Select:Quit  L/R:Page"
    fb_text_centered(HINT_ROW, hint, COL_DIM, COL_BG)
    fb_hline(SEP3_ROW)
    fb_flip()
    return list_rows

def select_from_list(title: str, items: List[str], info: str = "", initial_selected: int = 0) -> Optional[int]:
    if not items: return None
    total = len(items)
    selected = max(0, min(initial_selected, total - 1))
    offset = 0
    cur_list_rows = LIST_ROWS  # initial estimate, updated after first draw
    while True:
        # Only adjust offset when selected is out of view — never reset it
        if selected < offset:
            offset = selected
        elif selected >= offset + cur_list_rows:
            offset = selected - cur_list_rows + 1
        offset = max(0, offset)
        cur_list_rows = draw_screen(title, items, selected, offset, info, total)
        key = controller.wait_for_input()
        if key == 'select': raise UserQuit()
        elif key == 'up':
            selected = (selected - 1) % total
        elif key == 'down':
            selected = (selected + 1) % total
        elif key == 'left':
            selected = max(0, selected - cur_list_rows)
        elif key == 'right':
            selected = min(total - 1, selected + cur_list_rows)
        elif key == 'a': return selected
        elif key == 'b': raise GoBack()

def _simple_dialog(title: str, message: str, options: List[str], selected_init: int = 0) -> int:
    selected = selected_init
    while True:
        fb_fill(COL_BG)
        fb_fill_row(TITLE_ROW, COL_SEL_BG)
        fb_text_centered(TITLE_ROW, f"  {title}  ", COL_SEL_FG, COL_SEL_BG)
        fb_hline(SEP1_ROW)
        # Message
        lines = message.split('\n')
        for i, line in enumerate(lines[:ROWS - 10]):
            fb_text(2, 3 + i, line[:COLS - 4], COL_FG, COL_BG)
        # Options
        opt_row = 3 + len(lines) + 2
        for i, opt in enumerate(options):
            if i == selected:
                fb_fill_row(opt_row + i, COL_SEL_BG)
                fb_text_centered(opt_row + i, f"> {opt} <", COL_SEL_FG, COL_SEL_BG)
            else:
                fb_text_centered(opt_row + i, f"  {opt}  ", COL_FG, COL_BG)
        fb_hline(SEP2_ROW)
        fb_text_centered(HINT_ROW, "D-Pad:Navigate  A:Confirm  B:Back", COL_DIM, COL_BG)
        fb_flip()
        key = controller.wait_for_input()
        if key == 'select': raise UserQuit()
        elif key in ('up', 'down'): selected = 1 - selected if len(options) == 2 else (selected - 1 if key == 'up' else selected + 1) % len(options)
        elif key == 'a': return selected
        elif key == 'b': return -1

def confirm_dialog(title: str, message: str, default_yes: bool = True) -> bool:
    sel = _simple_dialog(title, message, ["Yes", "No"], 0 if default_yes else 1)
    return sel == 0

def ok_dialog(title: str, message: str):
    _simple_dialog(title, message, ["OK"], 0)

def back_exit_dialog(title: str, message: str) -> str:
    sel = _simple_dialog(title, message, ["BACK", "EXIT"], 0)
    if sel == 1: return "exit"
    return "back"

# ---------------------------------------------------------------------------
# Command line editor (fbdev version)
# ---------------------------------------------------------------------------
def edit_command_line(default_cmd: str) -> Optional[str]:
    cmd = list(default_cmd[:MAX_CMD_LEN])
    while len(cmd) < 20: cmd.append(' ')
    position = 0
    view_offset = 0
    view_width = COLS - 6

    while True:
        fb_fill(COL_BG)
        fb_fill_row(TITLE_ROW, COL_SEL_BG)
        fb_text_centered(TITLE_ROW, "  Edit Command Line  ", COL_SEL_FG, COL_SEL_BG)
        fb_hline(SEP1_ROW)
        fb_text(2, 3, "L/R:Move  Up/Dn:Char  L1/R1:Jump10  X:Insert  Y:Delete  A:OK  B:Cancel", COL_DIM, COL_BG)
        fb_hline(4)
        # Scroll view
        if position < view_offset: view_offset = position
        elif position >= view_offset + view_width: view_offset = position - view_width + 1
        vis_start = view_offset
        vis_end   = min(view_offset + view_width, len(cmd))
        # Draw cmd chars
        draw_row = 6
        fb_fill_row(draw_row, bytes([0x10, 0x10, 0x30, 0xFF]))
        left_ind  = "<" if view_offset > 0 else " "
        right_ind = ">" if vis_end < len(cmd) else " "
        fb_text(0, draw_row, left_ind, COL_DIM, bytes([0x10,0x10,0x30,0xFF]))
        fb_text(COLS-1, draw_row, right_ind, COL_DIM, bytes([0x10,0x10,0x30,0xFF]))
        for idx in range(vis_start, vis_end):
            ch = cmd[idx] if idx < len(cmd) else ' '
            screen_col = 1 + (idx - vis_start)
            if idx == position:
                fb_char(screen_col * CELL_W, draw_row * CELL_H, ord(ch), COL_SEL_FG, COL_SEL_BG)
            else:
                fb_char(screen_col * CELL_W, draw_row * CELL_H, ord(ch), COL_FG, bytes([0x10,0x10,0x30,0xFF]))
        # Status
        pos_info = f"Pos:{position+1}/{len(cmd)}  Len:{len(cmd)}/{MAX_CMD_LEN}"
        fb_text(2, 8, pos_info, COL_DIM, COL_BG)
        # Preview
        preview = ''.join(cmd).rstrip()
        if len(preview) > COLS - 12: preview = preview[:COLS-15] + "..."
        fb_text(2, 10, f"Preview: {preview}", COL_TITLE, COL_BG)
        fb_hline(SEP2_ROW)
        fb_text_centered(HINT_ROW, "A:Accept  B:Cancel  Select:Quit", COL_DIM, COL_BG)
        fb_flip()

        key = controller.wait_for_input()
        if key == 'select': raise UserQuit()
        elif key == 'right':
            if position < len(cmd) - 1: position += 1
        elif key == 'left':
            if position > 0: position -= 1
        elif key == 'r1': position = min(position + 10, len(cmd) - 1)
        elif key == 'l1': position = max(position - 10, 0)
        elif key == 'up':
            cur = cmd[position]
            try: idx = CMD_ALPHABET.index(cur)
            except ValueError: idx = 0
            cmd[position] = CMD_ALPHABET[(idx + 1) % len(CMD_ALPHABET)]
        elif key == 'down':
            cur = cmd[position]
            try: idx = CMD_ALPHABET.index(cur)
            except ValueError: idx = 0
            cmd[position] = CMD_ALPHABET[(idx - 1) % len(CMD_ALPHABET)]
        elif key == 'x':
            if len(cmd) < MAX_CMD_LEN: cmd.insert(position, ' ')
        elif key == 'y':
            if len(cmd) > 1:
                cmd.pop(position)
                if position >= len(cmd): position = len(cmd) - 1
        elif key == 'a':
            final = ''.join(cmd).strip()
            if not final: continue
            if ROM_PLACEHOLDER not in final:
                ok_dialog("Missing Placeholder", f"Command must contain {ROM_PLACEHOLDER}")
                continue
            return final
        elif key == 'b':
            return None

# ---------------------------------------------------------------------------
# Listmedia parser (unchanged)
# ---------------------------------------------------------------------------
def _read_listmedia_text(path):
    with open(path, 'rb') as f: data = f.read()
    if b'\x00' in data[:4096]:
        try: return data.decode('utf-16')
        except: return data.decode('utf-16-le', errors='ignore')
    return data.decode('utf-8', errors='ignore')

def parse_listmedia(path):
    if not os.path.isfile(path): raise FileNotFoundError(path)
    text = _read_listmedia_text(path)
    systems = {}; current_system = None
    for line in text.splitlines():
        original = line.rstrip('\r\n'); stripped = original.strip()
        if not stripped: continue
        tokens = stripped.split()
        if len(tokens) == 2 and tokens[1].startswith('(none'): continue
        if len(tokens) < 3: continue
        brief_idx = next((i for i,t in enumerate(tokens) if t.startswith('(') and t.endswith(')')), None)
        if brief_idx is None or brief_idx == 0: continue
        is_cont = bool(original) and original[0].isspace()
        if is_cont:
            if current_system is None: continue
            system = current_system; media_name = tokens[0]
        else:
            system = tokens[0]; current_system = system
            if brief_idx >= 2: media_name = tokens[1]
            else: continue
        brief = tokens[brief_idx].strip('()')
        exts  = [t for t in tokens[brief_idx+1:] if t.startswith('.')]
        systems.setdefault(system, []).append(MediaEntry(system, media_name, brief, exts))
    return systems

# ---------------------------------------------------------------------------
# System / media / directory selection
# ---------------------------------------------------------------------------
def choose_system(systems):
    all_systems = sorted(systems.keys())
    while True:
        idx = select_from_list("Select System", all_systems, f"Total systems: {len(all_systems)}")
        if idx is None: raise GoBack()
        return all_systems[idx]

def detect_media_types(rom_dir, entries):
    """Scan rom_dir for files and return MediaEntry list that match by extension.
    Also peeks inside ZIP/7z archives to check contained file extensions."""
    try:
        found_exts = set()
        for name in os.listdir(rom_dir):
            if name.startswith('.') or name.lower().endswith('.cmd'): continue
            ext = os.path.splitext(name)[1].lower()
            if not ext: continue
            found_exts.add(ext)
            # Peek inside archives
            if ext in ('.zip', '.7z'):
                contents = _archive_contents(os.path.join(rom_dir, name))
                for inner in contents.split(', '):
                    inner_ext = os.path.splitext(inner)[1].lower()
                    if inner_ext: found_exts.add(inner_ext)
    except Exception:
        return []
    matches = []
    for entry in entries:
        entry_exts = set(e.lower() for e in entry.exts)
        if entry_exts & found_exts:
            matches.append(entry)
    return matches

def choose_media(entries, rom_dir=None):
    """Choose media type, with optional auto-detect from rom_dir."""
    # Auto-detect if rom_dir provided
    if rom_dir:
        matches = detect_media_types(rom_dir, entries)
        if len(matches) == 1:
            m = matches[0]
            if confirm_dialog(
                "Media Type Detected",
                f"Scanned: {rom_dir}\n\nDetected media type:\n{m.media_name} ({m.brief})\n{' '.join(m.exts[:5])}\n\nUse this?",
                True
            ):
                return m
        elif len(matches) > 1:
            auto_options = [f"{e.media_name} ({e.brief}) {' '.join(e.exts[:3])}" for e in matches]
            auto_options.append('[ Show all media types ]')
            dir_short = rom_dir if len(rom_dir) <= COLS - 10 else '...' + rom_dir[-(COLS - 13):]
            info = f"Scanned: {dir_short}\nFound {len(matches)} matching type(s) — select one or show all."
            idx = select_from_list("Detected Media Types", auto_options, info)
            if idx is None: raise GoBack()
            if idx < len(matches):
                return matches[idx]
            # Fall through to full list
    # Full manual list
    options = [f"{e.media_name} ({e.brief}) {' '.join(e.exts[:3])}" for e in entries]
    idx = select_from_list("Select Media Type", options)
    if idx is None: raise GoBack()
    return entries[idx]


# ---------------------------------------------------------------------------
# Controller / device helpers
# ---------------------------------------------------------------------------
def _nr(dev, c, v):
    k = (dev.path, c)
    if k not in _AC:
        try: i = dev.absinfo(c); _AC[k] = ((i.min+i.max)/2, max((i.max-i.min)/2, 1.))
        except: _AC[k] = (0., 32767.)
    a, b = _AC[k]; return (v-a)/b

def _nodes(pref=None):
    ds = []
    for p in list_devices():
        try: ds.append(InputDevice(p))
        except: pass
    a = next((d for d in ds if d.path==pref), None) if pref else None
    if not a: a = next((d for d in ds if any(b in d.capabilities().get(e.EV_KEY,[]) for b in _GB)), None)
    if not a: return []
    base = a.name.rstrip(" 0123456789")
    return [a] + [d for d in ds if d.path!=a.path and d.name.startswith(base)
                  and (d.capabilities().get(e.EV_KEY) or d.capabilities().get(e.EV_ABS))]

def find_devs(pref=None):
    ns = _nodes(pref)
    if not ns:
        progress_screen("Macro Runner", "Waiting for controller...")
        while not ns:
            time.sleep(1); ns = _nodes(pref)
    return ns

# ---------------------------------------------------------------------------
# FB UI helpers
# ---------------------------------------------------------------------------
def progress_screen(title, message=""):
    fb_fill(COL_BG)
    fb_fill_row(TITLE_ROW, COL_SEL_BG)
    fb_text_centered(TITLE_ROW, f"  {title}  ", COL_SEL_FG, COL_SEL_BG)
    fb_hline(SEP1_ROW)
    if message:
        for i, line in enumerate(message.split("\n")[:ROWS-8]):
            fb_text(2, INFO_START+i, line[:COLS-4], COL_FG, COL_BG)
    fb_text_centered(ROWS-2, "Please wait...", COL_DIM, COL_BG)
    fb_flip()

def show_active(macro):
    """Show active macro info screen. Any button continues."""
    trig_str, evts_str = fmt_macro(macro)
    fb_fill(COL_BG)
    fb_fill_row(TITLE_ROW, COL_SEL_BG)
    fb_text_centered(TITLE_ROW, "  M A C R O  A C T I V E  ", COL_SEL_FG, COL_SEL_BG)
    fb_hline(SEP1_ROW)
    row = INFO_START
    fb_text(2, row,   f"Name   : {macro.get('name','?').upper()}", COL_TITLE, COL_BG); row+=1
    fb_text(2, row+1, f"Trigger: [{trig_str}]",                    COL_FG,    COL_BG); row+=2
    fb_text(2, row+1, f"Macro  : [{evts_str}]",                    COL_FG,    COL_BG); row+=3
    fb_hline(row+1)
    fb_text(2, row+2, "Macro is running in the background.",        COL_DIM,   COL_BG)
    fb_text(2, row+3, "Hold trigger 3s at any time to stop it.",    COL_DIM,   COL_BG)
    fb_hline(SEP2_ROW)
    fb_text_centered(HINT_ROW, "Press any button to continue...", COL_DIM, COL_BG)
    fb_flip()
    # Wait for any button
    while True:
        key = controller.wait_for_input()
        if key: return

def show_running():
    """Show 'macro running' screen. Returns True=stop, False=keep."""
    fb_fill(COL_BG)
    fb_fill_row(TITLE_ROW, COL_SEL_BG)
    fb_text_centered(TITLE_ROW, "  M A C R O  R U N N I N G  ", COL_SEL_FG, COL_SEL_BG)
    fb_hline(SEP1_ROW)
    fb_text(2, INFO_START,   "A macro is currently running in the background.", COL_FG,  COL_BG)
    fb_text(2, INFO_START+2, "A: Stop it", COL_TITLE, COL_BG)
    fb_text(2, INFO_START+3, "B: Keep it running and exit", COL_DIM,  COL_BG)
    fb_hline(SEP2_ROW)
    fb_flip()
    while True:
        key = controller.wait_for_input()
        if key == "b": return False
        if key == "a": return True

# ---------------------------------------------------------------------------
# Macro format helpers
# ---------------------------------------------------------------------------
def _trig_str(macro):
    t = macro.get("trigger")
    if isinstance(t, dict):
        if t.get("type") == "key":
            return _TL.get(t["code"], f"BTN_{t['code']}")
        return _AX.get(t.get("code",""), "?") + ("+" if t.get("positive") else "-")
    # Legacy: trigger_code int
    code = macro.get("trigger_code")
    return _TL.get(code, str(code)) if code is not None else "?"

def _trig_code(macro):
    """Return (type, code[, positive]) for trigger matching."""
    t = macro.get("trigger")
    if isinstance(t, dict):
        if t.get("type") == "key":
            return ("key", t["code"])
        return ("axis", t["code"], t.get("positive", True))
    code = macro.get("trigger_code")
    return ("key", code) if code is not None else None

def fmt_macro(macro):
    trig = _trig_str(macro)
    parts = []
    for ev in macro.get("macro_events", []):
        if ev["type"] == "key":
            parts.append(_TL.get(ev["code"], f"BTN_{ev['code']}"))
        elif ev["type"] == "axis":
            val = ev.get("value", 0)
            parts.append(_AX.get(ev["code"], f"AX{ev['code']}") + ("+" if val>0 else "-"))
    return trig, ", ".join(parts)

# ---------------------------------------------------------------------------
# Macro selection
# ---------------------------------------------------------------------------
def pick(macros):
    opts = []
    for m in macros:
        trig, evts = fmt_macro(m)
        opts.append(f"{m.get('name','?').upper()}  |  [{trig}]  →  {evts}")
    return select_from_list("Select Macro to Activate", opts, "A:Activate  B:Cancel")

# ---------------------------------------------------------------------------
# UInput playback
# ---------------------------------------------------------------------------
def _make_ui(evts):
    keys = set()
    for ev in evts:
        if ev["type"] == "key":
            k = _B2K.get(ev["code"])
            if k: keys.add(k)
        elif ev["type"] == "axis":
            val = ev.get("value", 0)
            k = _A2K.get(ev["code"], {}).get(1 if val>0 else -1)
            if k: keys.add(k)
    if not keys: return None
    return UInput({e.EV_KEY: list(keys)}, name="Virtual-Macro", bustype=e.BUS_USB)

def _play(ui, evts, delay=0.05):
    if not ui: return
    for ev in evts:
        k = None
        if ev["type"] == "key":
            k = _B2K.get(ev["code"])
        elif ev["type"] == "axis":
            val = ev.get("value", 0)
            k = _A2K.get(ev["code"], {}).get(1 if val>0 else -1)
        if not k: continue
        ui.write(e.EV_KEY, k, 1); ui.syn(); time.sleep(delay)
        ui.write(e.EV_KEY, k, 0); ui.syn()

def run_macro(dev_paths, macro):
    trig   = _trig_code(macro)
    evts   = macro["macro_events"]
    if not evts or not trig: return
    ui = _make_ui(evts)
    q  = queue.Queue()

    def _reader(path):
        try:
            dev = InputDevice(path)
            for ev in dev.read_loop(): q.put(ev)
        except: pass

    for p in dev_paths:
        threading.Thread(target=_reader, args=(p,), daemon=True).start()

    pressed, done, t0 = False, False, 0.0
    while True:
        try: ev = q.get(timeout=0.05)
        except queue.Empty:
            if pressed and not done and time.time()-t0 >= 0.1:
                done = True; _play(ui, evts)
            continue

        if trig[0] == "key" and ev.type == e.EV_KEY and ev.code == trig[1]:
            if ev.value == 1:
                pressed, done, t0 = True, False, time.time()
            elif ev.value == 0 and pressed:
                held, pressed = time.time()-t0, False
                if held >= 3: ui.close(); return
                if not done: _play(ui, evts)
        elif trig[0] == "axis" and ev.type == e.EV_ABS and ev.code == trig[1]:
            try:
                dev = InputDevice(dev_paths[0])
                i   = dev.absinfo(trig[1])
                mid = (i.min + i.max) / 2
                rng = max((i.max - i.min) / 2, 1.0)
                n   = (ev.value - mid) / rng
                dev.close()
            except: n = ev.value / 32767.0
            active = (n > DZ) if trig[2] else (n < -DZ)
            if active and not pressed:
                pressed, done, t0 = True, False, time.time()
            elif not active and pressed:
                held, pressed = time.time()-t0, False
                if held >= 3: ui.close(); return
                if not done: _play(ui, evts)

        if pressed and not done and time.time()-t0 >= 0.1:
            done = True; _play(ui, evts)

# ---------------------------------------------------------------------------
# PID helpers
# ---------------------------------------------------------------------------
def running():
    try:
        with open(PID) as f: pid = int(f.read().strip())
        os.kill(pid, 0); return True
    except: return False

def stop_running():
    try:
        with open(PID) as f: pid = int(f.read().strip())
        os.kill(pid, 15)
        time.sleep(0.2)
        if os.path.exists(PID): os.remove(PID)
    except: pass

def daemonize(dev_paths, macro):
    try:
        if os.fork() > 0: return 0
        os.setsid()
        if os.fork() > 0: os._exit(0)
    except OSError: return 2
    try: sys.stdin.close()
    except: pass
    try: log = open(LOG, "ab", buffering=0)
    except: log = open("/dev/null", "ab", buffering=0)
    for fd in (1, 2):
        try: os.dup2(log.fileno(), fd)
        except: pass
    try:
        with open(PID, "w") as f: f.write(str(os.getpid()))
    except: pass
    try: run_macro(dev_paths, macro)
    finally:
        try: os.remove(PID)
        except: pass
    os._exit(0)

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
def lcfg():
    if not os.path.exists(CFG):
        return None
    with open(CFG) as f: d = json.load(f)
    # Legacy migration
    if "macros" not in d:
        d = {"device_path": d.get("device_path"), "macros": [{"name": "DEFAULT",
             "trigger_code": d.get("trigger_code"),
             "macro_events": [{"type": "key", "code": k} for k in d.get("macro_keys", [])]}]}
    for m in d.get("macros", []):
        if "macro_keys" in m and "macro_events" not in m:
            m["macro_events"] = [{"type": "key", "code": k} for k in m.pop("macro_keys")]
    d["macros"] = [m for m in d["macros"] if m.get("macro_events")]
    return d

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    fb_open()
    fb_fill(COL_BG)
    fb_flip()
    init_controller()

    try:
        if running():
            stop = show_running()
            if not stop:
                return 0
            stop_running()
            time.sleep(0.5)

        cfg = lcfg()
        if not cfg or not cfg.get("macros"):
            ok_dialog("No Macros", "No macros found.\n\nRun Macro Setup first.")
            return 1

        devs = find_devs(cfg.get("device_path"))
        init_controller(devs[0].path)

        try:
            idx = pick(cfg["macros"])
        except (GoBack, UserQuit):
            return 0
        if idx is None:
            return 0

        macro = cfg["macros"][idx]
        show_active(macro)
        return 0 if daemonize([d.path for d in devs], macro) == 0 else 1

    except (GoBack, UserQuit):
        return 0
    finally:
        fb_fill(COL_BG)
        fb_flip()
        fb_close()
        if controller:
            controller.close()

if __name__ == "__main__":
    sys.exit(main())