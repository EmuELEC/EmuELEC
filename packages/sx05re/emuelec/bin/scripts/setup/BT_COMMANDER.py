#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

import os, time, subprocess, mmap
from typing import List, Optional, Tuple
from evdev import InputDevice, list_devices, ecodes as e

# ---------------------------------------------------------------------------
# Exceptions
# ---------------------------------------------------------------------------
class UserQuit(Exception): pass
class GoBack(Exception):   pass

def wait_for_controller(preferred_path=None):
    log("Waiting for controller...")
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

# ---------------------------------------------------------------------------
# Font: rendered at runtime from a system TTF via FreeType (no embedded blob)
# ---------------------------------------------------------------------------
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
                ('size', ctypes.c_void_p),
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

    FT_LOAD_RENDER = 4
    # Pass 1: widest advance sets the cell width, tallest glyph the height
    adv, ch_w, asc, desc = {}, 1, 1, 0
    for code in range(32, 127):
        if ft.FT_Load_Char(face, code, FT_LOAD_RENDER):
            continue
        g = face.contents.glyph.contents
        a = g.advance.x >> 6
        adv[code] = a
        ch_w = max(ch_w, a)
        asc  = max(asc, g.bitmap_top)
        desc = max(desc, g.bitmap.rows - g.bitmap_top)
    ch_h = asc + desc

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

def unblank_framebuffer():
    for p in ("/sys/class/graphics/fb0/blank", "/sys/class/graphics/fb1/blank"):
        try:
            with open(p, "w") as f: f.write("0")
        except Exception: pass

def progress_screen(title: str, message: str = ""):
    """Show a status screen during long operations."""
    fb_fill(COL_BG)
    fb_fill_row(TITLE_ROW, COL_SEL_BG)
    fb_text_centered(TITLE_ROW, f"  {title}  ", COL_SEL_FG, COL_SEL_BG)
    fb_hline(SEP1_ROW)
    if message:
        for i, line in enumerate(message.split('\n')[:ROWS - 8]):
            fb_text(2, INFO_START + i, line[:COLS - 4], COL_FG, COL_BG)
    fb_text_centered(ROWS - 2, "Please wait...", COL_DIM, COL_BG)
    fb_flip()

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

def fb_text_centered(row: int, text: str, fg: bytes, bg: bytes):
    col = max(0, (COLS - len(text)) // 2)
    fb_text(col, row, text, fg, bg)

def fb_fill_row(row: int, color: bytes):
    fb_rect(0, row * CELL_H, FB_W, CELL_H, color)

def fb_hline(row: int, char: str = '─'):
    fb_text(0, row, char * COLS, COL_BORDER, COL_BG)

# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Paths / constants
# ---------------------------------------------------------------------------
BT_LOG    = "/emuelec/logs/bt-commander.log"
BT_LAST   = "/storage/.config/btaudio.last"
SCAN_SECS = 10

# System-wide routing. SDL2 and RetroArch are told to use PulseAudio, which
# reaches libpulse directly. asound.conf is deliberately left alone: EmuELEC
# ships no ALSA pulse plugin, so "type pulse" cannot be loaded there and only
# breaks the Master mixer control the frontend needs.
ES_ENV     = "/storage/.config/emulationstation/scripts/es_env.sh"
RA_CONF    = "/storage/.config/retroarch/retroarch.cfg"
ROUTED     = "/storage/.config/btaudio.routed"
BT_CACHE   = "/storage/.cache/bluetooth"

# ---------------------------------------------------------------------------
# Log / run helper
# ---------------------------------------------------------------------------
def log(msg: str):
    try:
        with open(BT_LOG, "a") as f:
            f.write(msg + "\n")
    except Exception:
        pass


def run(cmd: List[str], timeout: int = 60, quiet: bool = False) -> Tuple[int, str]:
    """Run a command. quiet keeps its output out of the log: status queries
    are repeated constantly and would bury everything else."""
    if not quiet:
        log("Running: " + " ".join(cmd))
    try:
        r = subprocess.run(cmd, timeout=timeout, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, text=True, errors="replace")
        out = r.stdout or ""
        if out.strip() and not quiet:
            log(out.rstrip())
        return r.returncode, out
    except subprocess.TimeoutExpired:
        log("Process timed out")
        return 124, ""
    except Exception as ex:
        log(f"Exception: {ex}")
        return 1, ""


def btctl(*args: str, timeout: int = 60, quiet: bool = False) -> Tuple[int, str]:
    return run(["bluetoothctl"] + list(args), timeout, quiet)


def pactl(*args: str) -> Tuple[int, str]:
    return run(["pactl"] + list(args), 20)

# ---------------------------------------------------------------------------
# Bluetooth
# ---------------------------------------------------------------------------
def ensure_pulseaudio():
    if run(["pgrep", "-f", "pulseaudio.*--system"], 10)[0] == 0:
        return
    log("Starting pulseaudio")
    subprocess.Popen(["pulseaudio", "--system", "--disallow-exit",
                      "--disable-shm", "--log-level=error"],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(2)


def adapter_init():
    btctl("power", "on")
    btctl("pairable", "on")
    btctl("agent", "NoInputNoOutput")


def is_audio(info: str) -> bool:
    low = info.lower()
    if "icon: audio-" in low:
        return True
    return any(k in low for k in ("a2dp", "audio sink", "headset", "handsfree"))


def is_paired(info: str) -> bool:
    return "Paired: yes" in info


def is_known(info: str) -> bool:
    """False once bluetoothctl remove dropped the device."""
    return bool(info.strip()) and "not available" not in info


_last_info = {}


def device_info(mac: str) -> str:
    """Device state, logged as one line and only when it changed."""
    info = btctl("info", mac, timeout=20, quiet=True)[1]
    if not is_known(info):
        state = "not available"
    else:
        state = (f"paired={'yes' if is_paired(info) else 'no'} "
                 f"connected={'yes' if 'Connected: yes' in info else 'no'} "
                 f"audio={'yes' if is_audio(info) else 'no'}")
    if _last_info.get(mac) != state:
        _last_info[mac] = state
        log(f"info {mac}: {state}")
    return info


def is_connected(mac: str) -> bool:
    return "Connected: yes" in device_info(mac)


def info_name(info: str, fallback: str) -> str:
    for line in info.splitlines():
        if line.strip().startswith("Name:"):
            return line.split(":", 1)[1].strip()
    return fallback


def device_name(mac: str) -> str:
    return info_name(device_info(mac), mac)


def audio_devices() -> List[Tuple[str, str, bool]]:
    """The audio devices bluez knows, as (mac, name, connected)."""
    found = []
    for line in btctl("devices")[1].splitlines():
        parts = line.split(None, 2)
        if len(parts) < 2 or parts[0] != "Device":
            continue
        mac = parts[1]
        info = device_info(mac)
        if not is_audio(info):
            continue
        name = info_name(info, parts[2] if len(parts) > 2 else mac)
        found.append((mac, name, "Connected: yes" in info))
    return found


def paired_audio_devices() -> List[Tuple[str, str, bool]]:
    """The audio devices bluez has on file, as (mac, name, connected).

    Reads the bluez cache directly so that devices paired earlier show up
    even when bluetoothctl does not list them in this session."""
    seen = {}
    try:
        for mac in sorted(os.listdir(BT_CACHE)):
            path = os.path.join(BT_CACHE, mac, "info")
            if not os.path.isfile(path):
                continue
            name = mac
            with open(path, errors="replace") as f:
                for line in f:
                    if line.startswith("Name="):
                        name = line.split("=", 1)[1].strip()
                        break
            seen[mac.upper()] = name
    except OSError as ex:
        log(f"Could not read {BT_CACHE}: {ex}")

    for line in btctl("devices")[1].splitlines():
        parts = line.split(None, 2)
        if len(parts) >= 2 and parts[0] == "Device":
            mac = parts[1].upper()
            if mac not in seen:
                seen[mac] = parts[2] if len(parts) > 2 else mac

    out = []
    for mac, name in sorted(seen.items(), key=lambda kv: kv[1].lower()):
        info = device_info(mac)
        # A removed device can leave its cache directory behind, so what
        # bluez still knows decides, not the presence of the directory.
        # Paired is not usable here: devices can be trusted but unbonded.
        if is_known(info) and is_audio(info):
            out.append((mac, info_name(info, name), "Connected: yes" in info))
    return out


def scan_audio_devices() -> List[Tuple[str, str, bool]]:
    """Scan for SCAN_SECS, then list what turned up."""
    subprocess.Popen(["bluetoothctl", "--timeout", str(SCAN_SECS), "scan", "on"],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(SCAN_SECS + 1)
    return audio_devices()


def pair_and_connect(mac: str) -> bool:
    """Pair if needed, then connect. Never removes an existing pairing:
    a device that is switched off must not cost its bonding."""
    if not is_paired(device_info(mac)):
        btctl("pair", mac, timeout=90)
        for _ in range(10):
            if is_paired(device_info(mac)):
                break
            time.sleep(1)
    btctl("trust", mac)

    for _ in range(6):
        btctl("connect", mac, timeout=30)
        if is_connected(mac):
            return True
        time.sleep(2)
    return False


def route_audio(mac: str) -> Optional[str]:
    """Switch the card to A2DP and make its sink the default one."""
    btid = mac.replace(":", "_")
    card = "bluez_card." + btid

    for _ in range(12):
        if card in pactl("list", "cards", "short")[1]:
            break
        time.sleep(1)
    pactl("set-card-profile", card, "a2dp_sink")

    sink = None
    for _ in range(12):
        for line in pactl("list", "short", "sinks")[1].splitlines():
            fields = line.split()
            if len(fields) > 1 and fields[1].startswith("bluez_sink." + btid):
                sink = fields[1]
                break
        if sink:
            break
        time.sleep(1)
    if not sink:
        return None

    pactl("set-default-sink", sink)
    pactl("set-sink-mute", sink, "0")
    # The sink volume is deliberately left alone: devices supporting AVRCP
    # absolute volume follow it, which would turn an amplifier up to maximum.
    for line in pactl("list", "short", "sink-inputs")[1].splitlines():
        fields = line.split()
        if fields:
            pactl("move-sink-input", fields[0], sink)
    if "module-switch-on-connect" not in pactl("list", "modules", "short")[1]:
        pactl("load-module", "module-switch-on-connect")
    return sink


def save_last(mac: str):
    try:
        os.makedirs(os.path.dirname(BT_LAST), exist_ok=True)
        with open(BT_LAST, "w") as f:
            f.write(mac + "\n")
    except Exception as ex:
        log(f"Could not store last device: {ex}")


def load_last() -> Optional[str]:
    try:
        with open(BT_LAST) as f:
            mac = f.read().strip().upper()
        return mac or None
    except Exception:
        return None

# ---------------------------------------------------------------------------
# System-wide audio routing
# ---------------------------------------------------------------------------
def _write(path: str, text: str) -> bool:
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            f.write(text)
        return True
    except Exception as ex:
        log(f"Could not write {path}: {ex}")
        return False


def _set_env_line(driver: Optional[str]):
    """Set, or comment out, SDL_AUDIODRIVER in the EmulationStation env file."""
    try:
        with open(ES_ENV) as f:
            lines = f.read().splitlines()
    except Exception as ex:
        log(f"Could not read {ES_ENV}: {ex}")
        return
    new = "SDL_AUDIODRIVER=" + driver if driver else "#SDL_AUDIODRIVER=alsa"
    kept = [l for l in lines if "SDL_AUDIODRIVER" not in l]
    kept.append(new)
    _write(ES_ENV, "\n".join(kept) + "\n")


def _set_retroarch_driver(driver: str):
    try:
        with open(RA_CONF) as f:
            text = f.read()
    except Exception as ex:
        log(f"Could not read {RA_CONF}: {ex}")
        return
    out = []
    for line in text.splitlines():
        if line.strip().startswith("audio_driver"):
            line = f'audio_driver = "{driver}"'
        out.append(line)
    _write(RA_CONF, "\n".join(out) + "\n")


def routing_active() -> bool:
    return os.path.exists(ROUTED)


def routing_enable():
    """Point SDL2 and RetroArch at PulseAudio."""
    _set_env_line("pulseaudio")
    _set_retroarch_driver("pulse")
    _write(ROUTED, "")
    log("System-wide routing enabled")


def routing_disable():
    """Put the analog/HDMI path back."""
    if not routing_active():
        return
    _set_env_line(None)
    _set_retroarch_driver("alsathread")
    try:
        os.remove(ROUTED)
    except OSError:
        pass
    log("System-wide routing disabled")

# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------
def activate(mac: str, name: str) -> bool:
    """Pair if needed, connect, and route audio to the device."""
    progress_screen("CONNECTING", f"{name}\n{mac}\n\nPairing and connecting, please wait.")
    if not pair_and_connect(mac):
        ok_dialog("ERROR", f"Could not connect to {name}.\n\n"
                           "Make sure the device is switched on and not\n"
                           f"connected to something else.\n\nSee {BT_LOG} for details.")
        return False

    progress_screen("CONNECTING", f"{name}\n{mac}\n\nSetting up A2DP audio.")
    sink = route_audio(mac)
    if not sink:
        ok_dialog("ERROR", f"Connected to {name}, but no A2DP sink appeared.\n\n"
                           f"See {BT_LOG} for details.")
        return False

    save_last(mac)
    routing_enable()
    ok_dialog("CONNECTED", f"{name}\n{mac}\n\nActive sink:\n{sink}\n\n"
                           "EmulationStation and RetroArch play through\n"
                           "this device after the next restart of\n"
                           "EmulationStation.")
    return True


def pick_and_connect(title: str, devices: List[Tuple[str, str, bool]]) -> bool:
    """Show a device list and connect the chosen one."""
    labels = [f"{name}   [{mac}]{'   (connected)' if conn else ''}"
              for mac, name, conn in devices]
    idx = select_from_list(title, labels, "A: connect   B: back   Select: exit")
    if idx is None:
        return False
    mac, name, _ = devices[idx]
    activate(mac, name)
    return True


def scan_and_connect():
    while True:
        progress_screen("SCANNING", f"Put the device in pairing mode.\n\n"
                                    f"Scanning for {SCAN_SECS} seconds, please wait.")
        devices = scan_audio_devices()

        if not devices:
            if not confirm_dialog("NO AUDIO DEVICES",
                                  "No Bluetooth audio device was found.\n\nScan again?"):
                return
            continue
        pick_and_connect("AUDIO DEVICES", devices)
        return


def remove_device(mac: str, name: str) -> bool:
    """Disconnect, drop the pairing, and forget a stored device."""
    if not confirm_dialog("REMOVE DEVICE",
                          f"Remove the pairing for\n{name}\n{mac}?", default_yes=False):
        return False
    progress_screen("REMOVING", f"{name}\n{mac}")
    btctl("disconnect", mac, timeout=30)
    btctl("remove", mac, timeout=30)
    if load_last() == mac:
        routing_disable()
        try:
            os.remove(BT_LAST)
        except OSError:
            pass
    ok_dialog("REMOVED", f"{name}\n{mac}\n\nThe pairing has been removed.")
    return True


def connect_paired():
    while True:
        progress_screen("PAIRED DEVICES", "Reading the list, please wait.")
        devices = paired_audio_devices()
        if not devices:
            ok_dialog("NO PAIRED DEVICES",
                      "No paired audio device found.\n\n"
                      "Use 'Scan for audio devices' to pair one.")
            return

        labels = [f"{name}   [{mac}]{'   (connected)' if conn else ''}"
                  for mac, name, conn in devices]
        idx = select_from_list("PAIRED AUDIO DEVICES", labels,
                               "A: options   B: back   Select: exit")
        if idx is None:
            return
        mac, name, _ = devices[idx]

        choice = _simple_dialog(name, f"{mac}\n\nWhat would you like to do?",
                                ["Connect", "Remove pairing", "Back"], 0)
        if choice == 0:
            activate(mac, name)
            return
        if choice == 1:
            remove_device(mac, name)


def connect_last():
    mac = load_last()
    if not mac:
        ok_dialog("NO DEVICE", "No device has been connected yet.\n\n"
                               "Use 'Scan for audio devices' first.")
        return
    activate(mac, device_name(mac))


def disconnect_current():
    mac = load_last()
    if not mac:
        ok_dialog("NO DEVICE", "No device has been connected yet.")
        return
    name = device_name(mac)
    progress_screen("DISCONNECTING", f"{name}\n{mac}")
    btctl("disconnect", mac, timeout=30)
    routing_disable()
    ok_dialog("DISCONNECTED", f"{name}\n{mac}\n\n"
                              "Audio is back on the analog/HDMI output after\n"
                              "the next restart of EmulationStation.")


def forget_device():
    mac = load_last()
    if not mac:
        ok_dialog("NO DEVICE", "No device has been connected yet.")
        return
    remove_device(mac, device_name(mac))


def status_text() -> str:
    mac = load_last()
    if not mac:
        return "No device stored."
    info = device_info(mac)
    state = "connected" if "Connected: yes" in info else "not connected"
    name = info_name(info, mac)
    route = "system audio routed to bluetooth" if routing_active() else "system audio on analog/HDMI"
    return f"Last device: {name}  [{mac}]  ({state})\n{route}"

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    log(f"--- EmuELEC BT Commander {time.strftime('%Y-%m-%d %H:%M:%S')} ---")
    controller = None
    try:
        controller = init_controller()
        fb_open()
        unblank_framebuffer()
        progress_screen("BLUETOOTH", "Starting audio stack, please wait.")
        ensure_pulseaudio()
        adapter_init()

        while True:
            try:
                idx = select_from_list(
                    "Main Menu",
                    [
                        "Scan for audio devices",
                        "List of paired audio devices",
                        "Connect last device",
                        "Disconnect current device",
                        "Remove pairing of current device",
                        "Exit",
                    ],
                    status_text())

                if idx is None or idx == 5:
                    break
                if idx == 0:
                    scan_and_connect()
                elif idx == 1:
                    connect_paired()
                elif idx == 2:
                    connect_last()
                elif idx == 3:
                    disconnect_current()
                elif idx == 4:
                    forget_device()
            except GoBack:
                continue

    except UserQuit:
        pass
    except KeyboardInterrupt:
        pass
    finally:
        fb_fill(COL_BG)
        fb_flip()
        fb_close()
        if controller:
            controller.close()


if __name__ == "__main__":
    main()
