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
ROM_PLACEHOLDER = ""
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
            if ROM_PLACEHOLDER and ROM_PLACEHOLDER not in final:
                ok_dialog("Missing Placeholder", f"Command must contain {ROM_PLACEHOLDER}")
                continue
            return final
        elif key == 'b':
            return None



# ---------------------------------------------------------------------------
# OPTS MAKER - per-game .opts files for the Tsugaru FM Towns emulator
# The first line of "<game>.opts" is appended to the tsugaru command line by
# tsugarustart.sh. Later arguments override earlier ones, so options set here
# win over the launcher defaults (-GAMEPORT0 KEY, -CDSPEED 32, -AUTOSCALE).
# Setting -GAMEPORT0 here also bypasses tsugarustart.sh's gptokeyb remapping
# for this game entirely (native gameport mode takes over instead).
# Options taking file paths or multiple arguments (-FLIGHTMOUSE, -HDx,
# -VIRTKEY, -ALIAS, ...) go into the free-options editor.
# ---------------------------------------------------------------------------
ROM_DIRS  = ["/storage/roms/fmtowns", "/storage/roms/fmtownsux"]
ROM_EXTS  = (".cue", ".iso", ".mds", ".ccd", ".d77", ".d88", ".hdm", ".xdf", ".m3u")
DEFAULT_TXT = "(Default)"

_GAMEPORT_VALUES = [DEFAULT_TXT,
    "ANA0", "ANA1", "ANA2", "ANA3",
    "ANA0MOUSE", "ANA1MOUSE", "ANA2MOUSE", "ANA3MOUSE",
    "PHYS0", "PHYS1", "PHYS2", "PHYS3",
    "PHYS0MOUSE", "PHYS1MOUSE", "PHYS2MOUSE", "PHYS3MOUSE",
    "PHYS0CAPCOM", "PHYS1CAPCOM", "PHYS2CAPCOM", "PHYS3CAPCOM",
    "MOUSE", "KEY", "KEYMOUSE", "NUMPADMOUSE", "NONE"]

# (label, cli_prefix, values)  -  prefix None => the value itself is the flag
OPT_DEFS = [
    # --- Input ---
    ("Gameport 0",        "-GAMEPORT0",     list(_GAMEPORT_VALUES)),
    ("Gameport 1",        "-GAMEPORT1",     list(_GAMEPORT_VALUES)),
    ("App Preset",        "-APP",           [DEFAULT_TXT, "LEMMINGS", "LEMMINGS2",
                                             "STRIKECOMMANDER", "SUPERDAISEN",
                                             "WINGCOMMANDER1", "WINGCOMMANDER2",
                                             "AMARANTH3"]),
    ("Mouse Speed",       "-MOUSEINTEGSPD", [DEFAULT_TXT, "32", "64", "96", "128",
                                             "192", "256"]),
    ("Mouse VRAM Offset", "-MOUSEINTEGVRAMOFFSET", [DEFAULT_TXT, "1", "0"]),
    ("Keyboard Mode",     "-KEYBOARD",      [DEFAULT_TXT, "DIRECT", "TRANS1",
                                             "TRANS2", "TRANS3"]),
    # --- CPU / System ---
    ("CPU Fidelity",      None,             [DEFAULT_TXT, "-HIGHFIDELITY"]),
    ("CPU Clock (MHz)",   "-FREQ",          [DEFAULT_TXT, "8", "16", "20", "25",
                                             "33", "40", "50", "66"]),
    ("FPU",               None,             [DEFAULT_TXT, "-USEFPU", "-DONTUSEFPU"]),
    ("RAM (MB)",          "-MEMSIZE",       [DEFAULT_TXT, "2", "4", "6", "8",
                                             "16", "32", "64"]),
    ("Towns Model",       "-TOWNSTYPE",     [DEFAULT_TXT, "MODEL2", "2F", "20F",
                                             "UX", "CX", "UG", "HG", "HR", "UR",
                                             "MA", "MX", "ME", "MF", "HC"]),
    ("Pretend 386DX",     None,             [DEFAULT_TXT, "-PRETEND386DX"]),
    # --- Timing ---
    ("Wait Mode",         None,             [DEFAULT_TXT, "-NOWAIT", "-YESWAIT",
                                             "-NOWAITBOOT"]),
    ("Timer Catchup",     None,             [DEFAULT_TXT, "-NOCATCHUPREALTIME"]),
    ("SCSI Speed",        None,             [DEFAULT_TXT, "-FASTSCSI", "-NORMALSCSI"]),
    ("FDC Speed",         None,             [DEFAULT_TXT, "-FASTFD", "-NORMALFD"]),
    # --- Drives / Boot ---
    ("CD Speed",          "-CDSPEED",       [DEFAULT_TXT, "1", "2", "4", "8",
                                             "16", "24", "32"]),
    ("Remove Internal CD", None,            [DEFAULT_TXT, "-NOINTCD"]),
    ("Boot Key",          "-BOOTKEY",       [DEFAULT_TXT, "CD", "F0", "F1", "F2",
                                             "F3", "H0", "H1", "H2", "H3", "H4",
                                             "ICM", "DEBUG", "PADA", "PADB",
                                             "PADAB", "FAST", "SLOW"]),
    # --- Display ---
    ("Aspect Ratio",      None,             [DEFAULT_TXT, "-MAINTAINASPECT",
                                             "-FREEASPECT"]),
    ("Scale (%)",         "-SCALE",         [DEFAULT_TXT, "100", "150", "200",
                                             "250", "300"]),
    ("CRTC HighRes",      None,             [DEFAULT_TXT, "-NOHIGHRES"]),
    ("Scanlines 15kHz",   None,             [DEFAULT_TXT, "-SCANLINE15K"]),
    ("Damper Wire",       None,             [DEFAULT_TXT, "-DAMPERWIRELINE",
                                             "-NODAMPERWIRELINE"]),
    # --- Sound ---
    ("HighRes PCM",       None,             [DEFAULT_TXT, "-HIGHRESPCM",
                                             "-NOHIGHRESPCM"]),
    ("MIDI Cards",        "-MIDI",          [DEFAULT_TXT, "0", "1", "2", "3", "4"]),
    ("FM Volume",         "-FMVOL",         [DEFAULT_TXT, "1024", "2048", "4096",
                                             "6144", "8192"]),
    ("PCM Volume",        "-PCMVOL",        [DEFAULT_TXT, "1024", "2048", "4096",
                                             "6144", "8192"]),
    ("Sound Doublebuffer", None,            [DEFAULT_TXT, "-MAXSNDDBLBUF"]),
    # --- Misc ---
    ("Zero CMOS",         None,             [DEFAULT_TXT, "-ZEROCMOS"]),
    ("Do Not Save CMOS",  None,             [DEFAULT_TXT, "-DONTAUTOSAVECMOS"]),
    ("Quit on PowerOff",  None,             [DEFAULT_TXT, "-FORCEQUITONPOFF"]),
    ("Verbose Log",       None,             [DEFAULT_TXT, "-VERBOSE"]),
]

ACTIONS = ["Edit free options", "Save", "Delete .opts", "Back"]

def find_games():
    games = []
    for root_dir in ROM_DIRS:
        if not os.path.isdir(root_dir):
            continue
        for dirpath, dirnames, filenames in os.walk(root_dir):
            dirnames[:] = [d for d in dirnames if not d.startswith('.')]
            for fn in sorted(filenames):
                if fn.lower().endswith(ROM_EXTS):
                    games.append(os.path.join(dirpath, fn))
    games.sort(key=lambda p: os.path.basename(p).lower())
    return games

def opts_path_for(rom_path):
    return os.path.splitext(rom_path)[0] + ".opts"

def parse_opts_line(line):
    """Split an existing opts line into known option states + free remainder."""
    state = [0] * len(OPT_DEFS)
    tokens = line.split()
    free = []
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        matched = False
        for oi, (_label, prefix, values) in enumerate(OPT_DEFS):
            if prefix is not None and tok.upper() == prefix and i + 1 < len(tokens):
                val = tokens[i + 1].upper()
                if val in values:
                    state[oi] = values.index(val)
                    i += 2
                    matched = True
                break
            if prefix is None and tok.upper() in values:
                state[oi] = values.index(tok.upper())
                i += 1
                matched = True
                break
        if not matched:
            free.append(tok)
            i += 1
    return state, ' '.join(free)

def compose_opts_line(state, free):
    parts = []
    for oi, (_label, prefix, values) in enumerate(OPT_DEFS):
        val = values[state[oi]]
        if val == DEFAULT_TXT:
            continue
        if prefix is None:
            parts.append(val)
        else:
            parts.append(prefix)
            parts.append(val)
    if free:
        parts.append(free)
    return ' '.join(parts)

def options_screen(rom_path):
    """Scrollable toggle screen for one game. Returns after save/delete/back."""
    opath = opts_path_for(rom_path)
    state = [0] * len(OPT_DEFS)
    free = ""
    if os.path.isfile(opath):
        try:
            with open(opath) as f:
                state, free = parse_opts_line(f.readline().strip())
        except Exception:
            pass

    n_opts = len(OPT_DEFS)
    items_total = n_opts + len(ACTIONS)
    selected = 0
    offset = 0
    view_top = LIST_START
    view_rows = (SEP2_ROW - 3) - view_top   # keep one line for the preview

    while True:
        fb_fill(COL_BG)
        fb_fill_row(TITLE_ROW, COL_SEL_BG)
        name = os.path.basename(rom_path)
        if len(name) > COLS - 4:
            name = name[:COLS - 7] + "..."
        fb_text_centered(TITLE_ROW, "  " + name + "  ", COL_SEL_FG, COL_SEL_BG)
        fb_hline(SEP1_ROW)
        status = "present" if os.path.isfile(opath) else "none"
        fb_text(2, INFO_START, f".opts: {status}    Options: {n_opts} toggles + free options",
                COL_DIM, COL_BG)

        # scroll window
        if selected < offset:
            offset = selected
        elif selected >= offset + view_rows:
            offset = selected - view_rows + 1

        shown_free = free if free else "(none)"
        if len(shown_free) > 40:
            shown_free = shown_free[:37] + "..."

        for vis in range(view_rows):
            idx = offset + vis
            if idx >= items_total:
                break
            row = view_top + vis
            if idx < n_opts:
                label, _prefix, values = OPT_DEFS[idx]
                val = values[state[idx]]
                changed = "*" if state[idx] != 0 else " "
                line = f"{changed}{label:<22} < {val} >"
            else:
                action = ACTIONS[idx - n_opts]
                line = action + (f":  {shown_free}" if idx == n_opts else "")
            if idx == selected:
                fb_fill_row(row, COL_SEL_BG)
                fb_text(1, row, "> " + line, COL_SEL_FG, COL_SEL_BG, max_cols=COLS - 2)
            else:
                fb_text(3, row, line, COL_FG, COL_BG, max_cols=COLS - 4)

        up_ind = "^" if offset > 0 else " "
        dn_ind = "v" if offset + view_rows < items_total else " "
        fb_text(COLS - 2, view_top, up_ind, COL_DIM, COL_BG)
        fb_text(COLS - 2, view_top + view_rows - 1, dn_ind, COL_DIM, COL_BG)

        preview = compose_opts_line(state, free)
        if len(preview) > COLS - 14:
            preview = preview[:COLS - 17] + "..."
        fb_text(2, SEP2_ROW - 2, "Preview: " + (preview if preview else "(empty)"),
                COL_TITLE, COL_BG)
        fb_hline(SEP2_ROW)
        fb_text_centered(HINT_ROW,
                         "L/R:Value  L1/R1:Page  A:OK  B:Back  Select:Quit",
                         COL_DIM, COL_BG)
        fb_flip()

        key = controller.wait_for_input()
        if key == 'select':
            raise UserQuit()
        elif key == 'up':
            selected = (selected - 1) % items_total
        elif key == 'down':
            selected = (selected + 1) % items_total
        elif key == 'l1':
            selected = max(selected - view_rows, 0)
        elif key == 'r1':
            selected = min(selected + view_rows, items_total - 1)
        elif key in ('left', 'right') and selected < n_opts:
            values = OPT_DEFS[selected][2]
            step = 1 if key == 'right' else -1
            state[selected] = (state[selected] + step) % len(values)
        elif key == 'a':
            if selected < n_opts:
                values = OPT_DEFS[selected][2]
                state[selected] = (state[selected] + 1) % len(values)
            else:
                action = selected - n_opts
                if action == 0:      # free options editor
                    result = edit_command_line(free)
                    if result is not None:
                        free = result
                elif action == 1:    # save
                    line = compose_opts_line(state, free)
                    if not line:
                        if os.path.isfile(opath) and confirm_dialog(
                                "Empty Options",
                                "No options set - delete the existing .opts file?"):
                            os.remove(opath)
                            ok_dialog("Deleted", os.path.basename(opath))
                            return
                        ok_dialog("Nothing to save", "No options are set.")
                        continue
                    with open(opath, "w") as f:
                        f.write(line + "\n")
                    ok_dialog("Saved", os.path.basename(opath))
                    return
                elif action == 2:    # delete
                    if os.path.isfile(opath):
                        if confirm_dialog("Delete .opts", os.path.basename(opath) + " ?"):
                            os.remove(opath)
                            ok_dialog("Deleted", os.path.basename(opath))
                            return
                    else:
                        ok_dialog("No File", "No .opts file exists for this game.")
                else:                # back
                    return
        elif key == 'b':
            return

def run_opts_maker():
    while True:
        games = find_games()
        if not games:
            ok_dialog("No Games", "No FM Towns images found in " + ", ".join(ROM_DIRS))
            return
        labels = []
        for g in games:
            mark = "[opts] " if os.path.isfile(opts_path_for(g)) else "       "
            labels.append(mark + os.path.basename(g))
        idx = select_from_list("O P T S  M A K E R  (FM Towns / Tsugaru)", labels,
                               f"{len(games)} games - [opts] = file present")
        if idx is None:
            return
        try:
            options_screen(games[idx])
        except GoBack:
            continue

def main():
    fb_open()
    try:
        init_controller()
        while True:
            try:
                run_opts_maker()
                break
            except GoBack:
                continue
            except UserQuit:
                break
        fb_fill(COL_BG)
        fb_flip()
    finally:
        fb_close()

if __name__ == '__main__':
    main()