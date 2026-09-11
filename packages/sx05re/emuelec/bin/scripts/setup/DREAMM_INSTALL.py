#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

import os, sys, time, subprocess, shutil, mmap
from typing import List, Optional, Tuple
from evdev import InputDevice, list_devices, ecodes as e

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
DREAMM_EXE   = "/usr/bin/dreamm"
DREAMM_ROMS  = "/storage/roms/dreamm"
DREAMM_INST  = os.path.join(DREAMM_ROMS, "install")
DREAMM_LOG   = "/emuelec/logs/dreamm-commander.log"

# Containers DREAMM can scan. Archives and CD/floppy images; for the paired
# formats it is the control file that identifies the image, so CUE, MDS and
# CCD are listed while their BIN/MDF companions are not. IMG is both a raw
# floppy format and the data half of a CCD pair, so it stays in the list.
CONTAINERS = (".zip", ".7z", ".iso", ".cue", ".mds", ".ccd",
              ".ima", ".img", ".vfd")
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
# Command line editor (fbdev version)
# ---------------------------------------------------------------------------
def select_multiple_from_list(title: str, items: List[str], info: str = "") -> Optional[List[int]]:
    """Checkbox list — A toggles, last item confirms."""
    if not items:
        return []
    checked = set(range(len(items)))
    cursor = 0
    while True:
        labels = [f"{'[x]' if i in checked else '[ ]'} {items[i]}" for i in range(len(items))]
        labels.append('--- CONFIRM SELECTION ---')
        n_chk = len(checked)
        full_info = info + f"\nSelected: {n_chk}/{len(items)}  A:Toggle  Last item:Confirm"
        choice = select_from_list(title, labels, full_info, initial_selected=cursor)
        if choice is None:
            raise GoBack()
        cursor = choice
        if choice == len(items):
            return sorted(checked)
        if choice in checked:
            checked.discard(choice)
        else:
            checked.add(choice)

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

# ---------------------------------------------------------------------------
# Log / run helper
# ---------------------------------------------------------------------------
def log(msg: str):
    try:
        with open(DREAMM_LOG, "a") as f:
            f.write(msg + "\n")
    except Exception:
        pass


def run_dreamm(args: List[str], timeout: int = 900) -> Tuple[int, str]:
    """Run DREAMM with our userpath, capturing output.

    DREAMM takes over the framebuffer while it runs; the dialog shown
    afterwards repaints it."""
    cmd = [DREAMM_EXE, "-userpath", DREAMM_ROMS] + args
    log("Running: " + " ".join(cmd))
    try:
        result = subprocess.run(cmd, timeout=timeout, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, text=True, errors="replace")
        out = result.stdout or ""
        if out:
            log(out.rstrip())
        return result.returncode, out
    except subprocess.TimeoutExpired as ex:
        out = (ex.stdout or "") if isinstance(ex.stdout, str) else ""
        if out:
            log(out.rstrip())
        log("Process timed out")
        return 124, out
    except Exception as ex:
        log(f"Exception: {ex}")
        return 1, ""


def list_installed_games() -> List[str]:
    """Folder names under the DREAMM install directory."""
    if not os.path.isdir(DREAMM_INST):
        return []
    return sorted(d for d in os.listdir(DREAMM_INST)
                  if os.path.isdir(os.path.join(DREAMM_INST, d)) and not d.startswith('.'))


def resolve_game_dir(path: str) -> str:
    """Descend while a folder holds nothing but a single subfolder.

    DREAMM installs variants below the game id (lec-mortimer/pc-en/,
    <game>/CD/ and so on) and -run expects the folder that actually
    holds the game files."""
    while True:
        try:
            entries = os.listdir(path)
        except OSError:
            return path
        if len(entries) != 1:
            return path
        child = os.path.join(path, entries[0])
        if not os.path.isdir(child):
            return path
        path = child


def list_dreamm_entries() -> List[str]:
    """Existing <game>.dreamm folders in the ROM directory."""
    if not os.path.isdir(DREAMM_ROMS):
        return []
    return sorted(d for d in os.listdir(DREAMM_ROMS)
                  if d.lower().endswith('.dreamm')
                  and os.path.isdir(os.path.join(DREAMM_ROMS, d)))


def find_executables(folder: str) -> List[str]:
    """Relative paths of .exe/.com/.bat files, for -makedreamm."""
    found: List[str] = []
    for root, _dirs, files in os.walk(folder):
        for f in files:
            if f.lower().endswith(('.exe', '.com', '.bat')):
                rel = os.path.relpath(os.path.join(root, f), folder)
                found.append(rel)
    return sorted(found)


# ---------------------------------------------------------------------------
# 1) Install games
# ---------------------------------------------------------------------------
def install_games():
    paths: List[str] = []

    while True:
        folder = choose_directory_interactive(
            "Select Game Folder / Disk Images", '/storage/roms')

        images = sorted(f for f in os.listdir(folder)
                        if f.lower().endswith(CONTAINERS)
                        and os.path.isfile(os.path.join(folder, f)))

        if images and confirm_dialog(
                "Disk Images Found",
                f"{len(images)} image file(s) in this folder.\n\n"
                "Pick individual images instead of the whole folder?\n"
                "(Select several at once for a multi-disk game.)"):
            picks = select_multiple_from_list(
                "Select Disk Images", images,
                "ZIP, 7z, ISO, CUE, MDS, CCD, IMA, IMG, VFD.\n"
                "For CUE/BIN, MDS/MDF and CCD/IMG pick the control file.")
            if not picks:
                continue
            paths.extend(os.path.join(folder, images[i]) for i in picks)
        else:
            paths.append(folder)

        if not confirm_dialog(
                "Multi-Disk Install",
                f"Paths so far: {len(paths)}\n\n"
                "Add another disk or folder?\n"
                "(Choose No to start the installation.)",
                default_yes=False):
            break

    if not confirm_dialog(
            "Start Installation",
            f"Paths to scan: {len(paths)}\n\n"
            "Games that ship their own installer are run by DREAMM\n"
            "in fullscreen. Most are scripted and finish on their\n"
            "own; a few may need input on a keyboard.\n\nContinue?"):
        raise GoBack()

    progress_screen("Installing", "DREAMM is scanning:\n\n" +
                    "\n".join(p[:COLS - 6] for p in paths))

    before = len(list_installed_games())
    ret, out = run_dreamm(["-autoinstall"] + paths)

    tail = "\n".join(out.strip().splitlines()[-12:]) if out.strip() else "(no output)"

    # DREAMM exits 0 even when it recognised nothing, so judge by the output:
    # only LucasArts titles are identified automatically.
    unknown = "failed to identify" in out.lower()
    installed = len(list_installed_games()) - before

    if unknown and installed <= 0:
        ok_dialog(
            "No Games Recognised",
            f"{tail}\n\n"
            "DREAMM installs the LucasArts and Lucas-adjacent games\n"
            "on its compatibility list, including versions it does not\n"
            "know exactly. Nothing matching was found here.\n\n"
            "For other games use option 3, 'Make a .dreamm file\n"
            "manually', and pick the game's executable there.")
    elif ret == 0:
        ok_dialog("Installation Finished",
                  f"{tail}\n\nNewly installed: {max(installed, 0)}\n\n"
                  "Use 'Create .dreamm entries' next to make the\n"
                  "games visible in EmulationStation.")
    else:
        ok_dialog("Installation Failed", f"Exit code {ret}\n\n{tail}\n\n"
                  f"See {DREAMM_LOG}")


# ---------------------------------------------------------------------------
# 2) Create .dreamm entries (rename install folders)
# ---------------------------------------------------------------------------
def create_dreamm_entries():
    games = list_installed_games()
    if not games:
        ok_dialog("No Games Found",
                  f"Nothing in:\n{DREAMM_INST}\n\n"
                  "Install games first.")
        return

    picks = select_multiple_from_list(
        "Create .dreamm Entries", games,
        "Selected games are MOVED out of the install folder to\n"
        f"{DREAMM_ROMS} and renamed <game>.dreamm so\n"
        "EmulationStation lists them. DREAMM runs them from there.")
    if not picks:
        return

    created, skipped, failed = [], [], []
    for i in picks:
        name = games[i]
        top = os.path.join(DREAMM_INST, name)
        src = resolve_game_dir(top)
        dst = os.path.join(DREAMM_ROMS, f"{name}.dreamm")
        if os.path.exists(dst):
            skipped.append(name)
            continue
        try:
            shutil.move(src, dst)
            created.append(name)
            log(f"Renamed: {src} -> {dst}")
            while top != DREAMM_INST and not os.listdir(top):
                os.rmdir(top)
                top = os.path.dirname(top)
        except Exception as ex:
            failed.append(f"{name}: {ex}")
            log(f"Rename failed: {name}: {ex}")

    msg = f"Created: {len(created)}"
    if skipped:
        msg += f"\nAlready present: {len(skipped)}"
    if failed:
        msg += "\n\nFailed:\n" + "\n".join(failed[:5])
    ok_dialog("Done", msg)


# ---------------------------------------------------------------------------
# 3) Make a .dreamm file manually (unrecognised games)
# ---------------------------------------------------------------------------
def make_dreamm_file():
    folder = choose_directory_interactive(
        "Select Game Folder", DREAMM_ROMS)

    exes = find_executables(folder)
    if not exes:
        ok_dialog("No Executable Found",
                  f"No .exe/.com/.bat in:\n{folder[:COLS - 6]}")
        return

    if len(exes) > 1:
        exes = sorted(exes, key=lambda p: (p.count(os.sep), p.lower()))

    idx = select_from_list(
        "Select Executable", exes,
        "DREAMM will build a .dreamm launcher for this program.\n"
        "Pick the game's main executable.")
    if idx is None:
        return
    exe = exes[idx]

    if not confirm_dialog(
            "Create .dreamm File",
            f"DREAMM writes a launch template for:\n\n{exe}\n\n"
            "It then starts the game to do so. The game is closed\n"
            "again once the file has been written.\n\nContinue?"):
        raise GoBack()

    # -makedreamm names the file to write; everything after -launch is treated
    # as the target's own command line, so -launch has to come last. DREAMM
    # mounts the executable's directory by itself, so no -mount is needed.
    name = os.path.basename(folder.rstrip('/')) or "game"
    if name.lower().endswith('.dreamm'):
        name = name[:-7]
    target = os.path.join(DREAMM_ROMS, f"{name}.dreamm")

    progress_screen("Creating .dreamm file", f"{exe}\n\nin {folder[:COLS - 6]}")
    ret, out = run_dreamm(["-makedreamm", target, "-nowait",
                           "-launch", os.path.join(folder, exe)], timeout=300)

    tail = "\n".join(out.strip().splitlines()[-10:]) if out.strip() else ""

    # DREAMM writes the template and exits without playing the game. Some
    # executables still make it fall over on the way out, so judge by whether
    # the file appeared rather than by the exit code.
    if os.path.isfile(target):
        ok_dialog("Created",
                  f"{os.path.basename(target)}\n\nin {DREAMM_ROMS}\n\n"
                  "Edit the file to adjust CPU speed, video or audio\n"
                  "hardware if the game misbehaves.")
    else:
        ok_dialog("Failed", f"Exit code {ret}\n\n{tail}\n\nSee {DREAMM_LOG}")


# ---------------------------------------------------------------------------
# 4) Show supported games
# ---------------------------------------------------------------------------
def show_supported_games():
    progress_screen("Supported Games", "Asking DREAMM for its game list...")
    ret, out = run_dreamm(["-list"], timeout=120)

    lines = [l.rstrip() for l in out.splitlines() if l.strip()]
    if ret != 0 or not lines:
        ok_dialog("Failed", f"Exit code {ret}\n\nSee {DREAMM_LOG}")
        return

    # -list prints the game name first, then its variants indented below it
    titles = [l for l in lines if l[:1] not in (' ', '\t')]

    select_from_list(
        "Supported Games", titles or lines,
        f"{len(titles)} titles known to this DREAMM build.\n"
        "B goes back. Variants and demos are listed per title\n"
        f"in {DREAMM_LOG}.")


# ---------------------------------------------------------------------------
def main():
    preferred = sys.argv[1] if len(sys.argv) > 1 else None
    init_controller(preferred)

    os.makedirs(DREAMM_ROMS, exist_ok=True)

    try:
        with open(DREAMM_LOG, "w") as f:
            f.write("EmuELEC DREAMM Commander Log\n")
    except Exception:
        pass

    fb_open()
    unblank_framebuffer()
    fb_fill(COL_BG)
    fb_flip()

    try:
        while True:
            try:
                n_inst = len(list_installed_games())
                n_ent  = len(list_dreamm_entries())
                idx = select_from_list(
                    "Main Menu",
                    [
                        "Install games (DREAMM-supported titles)",
                        "Create .dreamm entries from installed games",
                        "Make a .dreamm file manually (anything else)",
                        "Show supported games",
                        "Exit",
                    ],
                    f"Installed: {n_inst}   Entries in ROM folder: {n_ent}\n"
                    "Option 1 covers the LucasArts and Lucas-adjacent games\n"
                    "DREAMM knows; option 3 is for everything else.")

                if idx is None or idx == 4:
                    break
                if idx == 0:
                    install_games()
                elif idx == 1:
                    create_dreamm_entries()
                elif idx == 2:
                    make_dreamm_file()
                elif idx == 3:
                    show_supported_games()
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