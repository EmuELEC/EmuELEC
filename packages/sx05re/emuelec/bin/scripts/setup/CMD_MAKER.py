#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# MADE WITH THE HELP OF CLAUDE.AI

import os, glob, re, shutil, mmap, json, struct, time, sys
import xml.etree.ElementTree as ET
from typing import Dict, List, Tuple, Optional
from evdev import InputDevice, list_devices, ecodes as e


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
_GLYPH_CACHE: dict = {}
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

def choose_directory_interactive(prompt, start_dir='/storage/roms'):
    current = os.path.abspath(start_dir)
    while True:
        try:
            entries = os.listdir(current)
            subdirs = sorted(d for d in entries if os.path.isdir(os.path.join(current, d)) and not d.startswith('.'))
            files   = sorted(f for f in entries if os.path.isfile(os.path.join(current, f)) and not f.startswith('.') and not f.lower().endswith('.cmd'))
        except:
            subdirs = []; files = []

        # Navigable options
        nav = ['[Use This Directory]']
        if current != '/': nav.append('[.. Parent Directory]')
        nav.extend(subdirs)

        # Display list: nav items + separator + file list (non-navigable)
        display = list(nav)
        if files:
            display.append('--- Files in this directory ---')
            display.extend(f'  {f}' for f in files)

        dir_short = current if len(current) <= COLS - 10 else '...' + current[-(COLS - 13):]
        info = f"Current: {dir_short}"

        nav_total = len(nav)
        selected = 0
        offset = 0

        while True:
            if selected < offset: offset = selected
            elif selected >= offset + LIST_ROWS: offset = selected - LIST_ROWS + 1
            offset = max(0, min(offset, max(0, len(display) - LIST_ROWS)))
            draw_screen(prompt, display, selected, offset, info, nav_total)
            key = controller.wait_for_input()
            if key == 'select': raise UserQuit()
            elif key == 'up':
                selected = (selected - 1) % nav_total
            elif key == 'down':
                selected = (selected + 1) % nav_total
            elif key == 'left':
                selected = max(0, selected - LIST_ROWS)
            elif key == 'right':
                selected = min(nav_total - 1, selected + LIST_ROWS)
            elif key == 'a': break
            elif key == 'b': raise GoBack()

        sel = nav[selected]
        if sel == '[Use This Directory]': return current
        elif sel == '[.. Parent Directory]':
            parent = os.path.dirname(current)
            if parent != current: current = parent
        else: current = os.path.join(current, sel)

def ask_file_filter(default_exts):
    exts = [x.lower() for x in (default_exts or [])]
    if '.zip' not in exts: exts.append('.zip')
    if '.7z' not in exts: exts.append('.7z')
    if not exts: return []
    ext_str = ' '.join(exts[:8]) + (f' (+{len(exts)-8})' if len(exts) > 8 else '')
    if confirm_dialog("File Filter", f"Filter by these file types?\n\n{ext_str}", True):
        return exts
    options = ['All files (no filter)'] + exts
    choice = select_from_list("Pick one file type", options)
    if choice is None: raise GoBack()
    return [] if choice == 0 else [exts[choice - 1]]

def find_rom_files(rom_dir, exts, extra_dirs=None):
    """Find ROM files in rom_dir and optionally in extra_dirs (list of subdir names)."""
    files = []
    try:
        # Files directly in rom_dir
        for name in sorted(os.listdir(rom_dir)):
            if name.startswith('.'): continue
            if not os.path.isfile(os.path.join(rom_dir, name)): continue
            if name.lower().endswith('.cmd'): continue
            if exts and os.path.splitext(name)[1].lower() not in exts: continue
            files.append(name)
        # Files in selected subdirs (recursive)
        for subdir in (extra_dirs or []):
            subpath = os.path.join(rom_dir, subdir)
            for root, dirs, filenames in os.walk(subpath):
                dirs[:] = sorted(d for d in dirs if not d.startswith('.'))
                for name in sorted(filenames):
                    if name.startswith('.'): continue
                    if name.lower().endswith('.cmd'): continue
                    if exts and os.path.splitext(name)[1].lower() not in exts: continue
                    relpath = os.path.relpath(os.path.join(root, name), rom_dir)
                    files.append(relpath)
    except Exception:
        pass
    return files

def get_subdirs_with_rom_files(rom_dir, exts):
    """Return sorted list of direct subdirs of rom_dir that contain matching ROM files."""
    result = []
    try:
        for entry in sorted(os.scandir(rom_dir), key=lambda e: e.name):
            if not entry.is_dir() or entry.name.startswith('.'): continue
            for root, dirs, filenames in os.walk(entry.path):
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                for name in filenames:
                    if name.startswith('.'): continue
                    if name.lower().endswith('.cmd'): continue
                    if exts and os.path.splitext(name)[1].lower() not in exts: continue
                    result.append(entry.name)
                    break
                else: continue
                break
    except Exception:
        pass
    return result

def ask_subdirs(rom_dir, exts):
    """Ask user which subdirectories to include. Returns list of subdir names or []."""
    subdirs = get_subdirs_with_rom_files(rom_dir, exts)
    if not subdirs:
        return []
    # Ask: none / all / pick individually via checkbox list
    idx = _simple_dialog(
        "Subdirectories Found",
        f"{len(subdirs)} subdirectory/ies with matching\nfiles found.\n\nInclude subdirectories?",
        ["No", "All subdirectories", "Select individually"]
    )
    if idx <= 0:
        return []
    if idx == 1:
        return subdirs
    # idx == 2: checkbox list of all subdirs
    selected = set(range(len(subdirs)))  # all selected by default
    cursor = 0
    while True:
        labels = []
        for i, sub in enumerate(subdirs):
            mark = '[x]' if i in selected else '[ ]'
            labels.append(f"{mark} {sub}")
        labels.append('--- CONFIRM SELECTION ---')
        n_sel = len(selected)
        choice = select_from_list(
            f"Select Subdirectories ({n_sel}/{len(subdirs)})",
            labels,
            "A:Toggle  Last item:Confirm",
            initial_selected=cursor
        )
        if choice is None:
            raise GoBack()
        cursor = choice
        if choice == len(subdirs):  # CONFIRM
            break
        if choice in selected:
            selected.discard(choice)
        else:
            selected.add(choice)
    return [subdirs[i] for i in sorted(selected)]

def _archive_contents(filepath: str) -> str:
    """Return a string showing all filenames inside a zip/7z."""
    ext = os.path.splitext(filepath)[1].lower()
    try:
        if ext == '.zip':
            import zipfile
            with zipfile.ZipFile(filepath, 'r') as zf:
                names = sorted(n for n in zf.namelist() if not n.endswith('/'))
                return ', '.join(os.path.basename(n) for n in names)
        if ext == '.7z':
            import subprocess
            r = subprocess.run(['7z', 'l', '-slt', filepath],
                               capture_output=True, text=True, timeout=3)
            if r.returncode == 0:
                found = []
                for line in r.stdout.splitlines():
                    if line.startswith('Path = ') and not line.endswith(os.path.basename(filepath)):
                        found.append(os.path.basename(line[7:].strip()))
                return ', '.join(found)
    except Exception:
        pass
    return ''

def ask_file_selection(rom_files: list, rom_dir: str = '') -> list:
    """Show found files as a checkbox list. All selected by default, A toggles."""
    if not rom_files:
        return []
    # Pre-compute archive contents for display (once)
    archive_exts = {'.zip', '.7z'}
    hints = {}
    for f in rom_files:
        ext = os.path.splitext(f)[1].lower()
        if ext in archive_exts:
            full = os.path.join(rom_dir, f) if rom_dir else f
            contents = _archive_contents(full)
            if contents:
                hints[f] = contents

    selected = set(range(len(rom_files)))  # all selected by default
    cursor = 0  # persistent cursor position across redraws
    while True:
        labels = []
        index_map = []
        for i, f in enumerate(rom_files):
            mark = '[x]' if i in selected else '[ ]'
            hint = hints.get(f, '')
            max_w = COLS - 6
            fname = f if len(f) <= max_w else '...' + f[-(max_w - 3):]
            if hint:
                first_line = f"{mark} {fname}"
                inline = f"{first_line}  [{hint}]"
                if len(inline) <= COLS - 2:
                    labels.append(inline)
                    index_map.append(i)
                else:
                    labels.append(first_line)
                    index_map.append(i)
                    chunk_w = max_w - 4
                    hint_str = f"[{hint}]"
                    while hint_str:
                        chunk = hint_str[:chunk_w]
                        if len(hint_str) > chunk_w:
                            cut = chunk.rfind(', ')
                            if cut > 0:
                                chunk = hint_str[:cut + 1]
                                hint_str = hint_str[cut + 2:]
                            else:
                                hint_str = hint_str[chunk_w:]
                        else:
                            hint_str = ''
                        labels.append(f"     {chunk}")
                        index_map.append(-1)
            else:
                labels.append(f"{mark} {fname}")
                index_map.append(i)
        labels.append('--- CONFIRM SELECTION ---')
        index_map.append(-2)
        n_sel = len(selected)
        info = f"Found {len(rom_files)} file(s).  Selected: {n_sel}\nA:Toggle  L/R:Page  Last item:Confirm"
        choice = select_from_list(
            f"Select Files ({n_sel}/{len(rom_files)})",
            labels,
            info,
            initial_selected=cursor
        )
        if choice is None:
            raise GoBack()
        cursor = choice  # remember cursor position
        mapped = index_map[choice]
        if mapped == -2:  # CONFIRM
            break
        if mapped == -1:  # continuation line — toggle parent
            for j in range(choice - 1, -1, -1):
                if index_map[j] >= 0:
                    mapped = index_map[j]
                    break
        if mapped >= 0:
            if mapped in selected:
                selected.discard(mapped)
            else:
                selected.add(mapped)
    return [rom_files[i] for i in sorted(selected)]

# ---------------------------------------------------------------------------
# CMD building / writing
# ---------------------------------------------------------------------------
def build_default_template_preset(system, media, extra_options=''):
    parts = [system, '-rp /storage/roms/bios']
    if extra_options.strip(): parts.append(extra_options.strip())
    parts.append(f'-{media.brief} "{ROM_PLACEHOLDER}"')
    return ' '.join(parts)

def apply_template(template, rom_path):
    return template.replace(ROM_PLACEHOLDER, rom_path)

def write_cmd_file(cmd_path, cmd_line):
    os.makedirs(os.path.dirname(cmd_path), exist_ok=True)
    with open(cmd_path, 'w', encoding='utf-8') as f:
        f.write(cmd_line + '\n')

def show_remaining_files(remaining: list):
    """Show all remaining files before bulk-creating. Returns True to confirm, False to cancel."""
    while True:
        labels = [os.path.basename(f) if len(os.path.basename(f)) <= COLS - 4
                  else '...' + os.path.basename(f)[-(COLS - 7):]
                  for f in remaining]
        labels.append('--- CONFIRM: CREATE ALL ---')
        info = f"Will create .cmd for {len(remaining)} file(s).\nB:Cancel"
        idx = select_from_list(
            f"Create All — {len(remaining)} files",
            labels,
            info
        )
        if idx is None: return False
        if idx == len(remaining): return True  # CONFIRM

def review_cmd(cmd_path, cmd_line, accept_all, remaining=None):
    if accept_all: return cmd_line, True, True
    # Build info block: path + full cmd content wrapped at COLS-4
    disp_path = cmd_path if len(cmd_path) <= COLS - 4 else '...' + cmd_path[-(COLS - 7):]
    # Word-wrap cmd_line at COLS-4
    max_w = COLS - 4
    words = cmd_line.split(' ')
    lines = []; cur = ''
    for w in words:
        if cur and len(cur) + 1 + len(w) > max_w:
            lines.append(cur); cur = w
        else:
            cur = (cur + ' ' + w).strip() if cur else w
    if cur: lines.append(cur)
    cmd_wrapped = '\n'.join(lines)
    info = f"Output: {disp_path}\n\n.cmd content:\n{cmd_wrapped}"
    idx = select_from_list("Create .cmd File",
        ["CREATE .CMD FOR THIS ROM", "SKIP THIS ROM",
         "CREATE FOR ALL SELECTED", "BACK"], info)
    if idx is None or idx == 3: raise GoBack()
    if idx == 0: return cmd_line, True, False
    if idx == 2:
        all_remaining = [cmd_path] + (remaining or [])
        if show_remaining_files(all_remaining):
            return cmd_line, True, True
        else:
            return None, False, False
    return None, False, False

# ---------------------------------------------------------------------------
# gamelist.xml update (unchanged)
# ---------------------------------------------------------------------------
def update_gamelist_paths(gamelist_path, rom_dir, rom_files):
    if not os.path.isfile(gamelist_path): return 0
    base_names = {os.path.splitext(n)[0] for n in rom_files}
    try: tree = ET.parse(gamelist_path); root = tree.getroot()
    except: return 0
    changed = 0
    for pe in root.iter('path'):
        text = (pe.text or '').strip()
        if not text: continue
        old_base = os.path.basename(text); base, ext = os.path.splitext(old_base)
        if base not in base_names or ext.lower() == '.cmd': continue
        pe.text = text[:-len(old_base)] + base + '.cmd'; changed += 1
    if changed:
        try: shutil.copy2(gamelist_path, gamelist_path + '.bak'); tree.write(gamelist_path, encoding='utf-8', xml_declaration=True)
        except: return 0
    return changed

def maybe_update_gamelist(rom_dir, rom_files):
    if not rom_files: return
    if not confirm_dialog("Update gamelist.xml", "Update gamelist.xml paths to use .cmd files?", False):
        ok_dialog("Gamelist.xml", "Gamelist.xml update was skipped."); return
    gl = os.path.join(rom_dir, 'gamelist.xml')
    if not os.path.isfile(gl):
        ok_dialog("Gamelist.xml", "gamelist.xml not found."); return
    changed = update_gamelist_paths(gl, rom_dir, rom_files)
    if changed > 0: ok_dialog("Success", f"Updated {changed} entries in gamelist.xml")
    else: ok_dialog("Gamelist.xml", "No matching entries were updated.")

# ---------------------------------------------------------------------------
# Preset mode
# ---------------------------------------------------------------------------
def run_preset_mode(systems):
    system = None; media = None; rom_dir = None; exts = []; rom_files = []
    step = 0
    while True:
        if step == 0:
            system = choose_system(systems)
            media = rom_dir = None; exts = []; rom_files = []; step = 1; continue
        if step == 1:
            try: rom_dir = choose_directory_interactive("Select ROM Directory"); step = 2
            except GoBack: step = 0; continue
        if step == 2:
            try: media = choose_media(systems[system], rom_dir=rom_dir); step = 3
            except GoBack: step = 1; continue
        if step == 3:
            try:
                while True:
                    exts = ask_file_filter(media.exts)
                    extra_dirs = ask_subdirs(rom_dir, exts)
                    rom_files = find_rom_files(rom_dir, exts, extra_dirs=extra_dirs)
                    if rom_files: break
                    action = back_exit_dialog("No Files Found", f"No ROM files found in:\n{rom_dir}")
                    if action == 'exit': raise UserQuit()
                rom_files = ask_file_selection(rom_files, rom_dir)
                if not rom_files:
                    ok_dialog("No Files Selected", "No files were selected.")
                else:
                    step = 4
            except GoBack: step = 2; continue
        # step 4: process
        template = build_default_template_preset(system, media)
        accept_all = False; created = []; i = 0
        while i < len(rom_files):
            name = rom_files[i]
            rom_path = os.path.join(rom_dir, name)
            cmd_line = apply_template(template, rom_path)
            cmd_path = os.path.join(rom_dir, os.path.splitext(name)[0] + '.cmd')
            # remaining = files after current one
            remaining_paths = [os.path.join(rom_dir, rom_files[j]) for j in range(i + 1, len(rom_files))]
            try:
                sel_cmd, accepted, accept_all = review_cmd(cmd_path, cmd_line, accept_all, remaining=remaining_paths)
            except GoBack:
                step = 3; break
            if accepted and sel_cmd:
                write_cmd_file(cmd_path, sel_cmd); created.append(name)
            i += 1
        else:
            maybe_update_gamelist(rom_dir, created)
            ok_dialog("Done", f"Created {len(created)} .cmd file(s).")
            step = 0

# ---------------------------------------------------------------------------
# Custom mode
# ---------------------------------------------------------------------------
def run_custom_mode(systems):
    """Custom mode with step-based back navigation, identical to preset mode."""
    system = None; media = None; rom_dir = None; exts = []; rom_files = []
    step = 0  # 0=system, 1=media, 2=dir, 3=filter, 4=edit_cmd, 5=process
    while True:
        if step == 0:
            try:
                system = choose_system(systems)
                media = rom_dir = None; exts = []; rom_files = []
                step = 1
            except GoBack:
                raise  # propagate to main menu

        elif step == 1:
            try:
                rom_dir = choose_directory_interactive("Select ROM Directory")
                step = 2
            except GoBack:
                step = 0

        elif step == 2:
            try:
                media = choose_media(systems[system], rom_dir=rom_dir)
                step = 3
            except GoBack:
                step = 1

        elif step == 3:
            try:
                while True:
                    exts = ask_file_filter(media.exts)
                    extra_dirs = ask_subdirs(rom_dir, exts)
                    rom_files = find_rom_files(rom_dir, exts, extra_dirs=extra_dirs)
                    if rom_files:
                        break
                    action = back_exit_dialog("No Files Found",
                        f"No ROM files found in:\n{rom_dir}")
                    if action == 'exit':
                        raise UserQuit()
                rom_files = ask_file_selection(rom_files, rom_dir)
                if not rom_files:
                    ok_dialog("No Files Selected", "No files were selected.")
                else:
                    step = 4
            except GoBack:
                step = 2

        elif step == 4:
            try:
                default_tpl = build_default_template_preset(system, media)
                template = edit_command_line(default_tpl)
                if template is None:
                    step = 3  # B in editor → back to filter
                else:
                    step = 5
            except GoBack:
                step = 3

        elif step == 5:
            accept_all = False; created = []
            go_back = False
            for i, name in enumerate(rom_files):
                rom_path = os.path.join(rom_dir, name)
                cmd_line = apply_template(template, rom_path)
                cmd_path = os.path.join(rom_dir, os.path.splitext(name)[0] + '.cmd')
                remaining_paths = [os.path.join(rom_dir, rom_files[j]) for j in range(i + 1, len(rom_files))]
                try:
                    sel_cmd, accepted, accept_all = review_cmd(cmd_path, cmd_line, accept_all, remaining=remaining_paths)
                except GoBack:
                    go_back = True; break
                if accepted and sel_cmd:
                    write_cmd_file(cmd_path, sel_cmd); created.append(name)
            if go_back:
                step = 4
            else:
                maybe_update_gamelist(rom_dir, created)
                ok_dialog("Done", f"Created {len(created)} .cmd file(s).")
                step = 0

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    # Load listmedia
    listmedia_path = DEFAULT_LISTMEDIA_FILE if os.path.isfile(DEFAULT_LISTMEDIA_FILE) else SYSTEM_LISTMEDIA_FILE
    try: systems = parse_listmedia(listmedia_path)
    except Exception as ex:
        print(f"ERROR loading listmedia: {ex}", file=sys.stderr); sys.exit(1)

    fb_open()
    try:
        init_controller()
        while True:
            try:
                idx = select_from_list(
                    "C M D  M A K E R",
                    ["Preset Mode (recommended)", "Custom Command Mode", "Quit"],
                    f"Loaded {len(systems)} MAME systems from {listmedia_path}"
                )
                if idx is None or idx == 2:
                    fb_fill(COL_BG); break
                elif idx == 0: run_preset_mode(systems)
                elif idx == 1: run_custom_mode(systems)
            except GoBack: continue
            except UserQuit: fb_fill(COL_BG); break
    finally:
        fb_close()

if __name__ == '__main__':
    main()