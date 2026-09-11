#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present worstcase_scenario (https://github.com/worstcase-scenario)
# THIS FILE HAS BEEN CREATED BY CLAUDE.AI

import os, glob, sys, time, subprocess, shutil, re, mmap, zlib, base64, json, select as _select
from typing import List, Optional, Tuple
from evdev import InputDevice, list_devices, ecodes as e

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
EKA_EXE        = "/usr/bin/eka2l1/eka2l1_sdl2"
EKA_CONFIG     = "/storage/.config/eka2l1"
EKA_BIOS_DIR   = "/storage/roms/bios/eka2l1"
EKA_ROMS_DIR   = "/storage/roms/ngage"
EKA_LOG        = "/emuelec/logs/eka2l1-install.log"
EKA_CONFIG_YML = os.path.join(EKA_CONFIG, "config.yml")

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
# Embedded font (DejaVuSansMono 28pt, CELL 19x24, base64+zlib+json)
# ---------------------------------------------------------------------------
_FONT_B64 = "eNrtfc2uJS2y3au0etwDgn/8KpblgWX5Du7AkgeWdXXf3UVAAkGSJOQ+darO3iHR5+uqOsTODSQEESvW+o9//o//+e///t//7z//yz8g/Osf6U//9utPyv360//69//3v//t//z603/8U8lf//mv4l//4MaNGzdu3LhxW23/7Zc/oRQ7Ee/fpI4/jPn1AyR35+6L3ZU6ugvzoHu8v2B3CE8WbfzM1N3Z/e74mam7hQfdXfl07Xhz+Fu7c/scV0Wzq/K2LdhjFzDlpFHk7yzb+GAb3Lhx4/bXOieGnZMfct1p7xz1Zgii3nVvbcQbYfpd7f/1D19sWH3cGVW4vWAKX27H7eVayuNUdP7Whi03bFWP1nKhMr8eB26NSHkYcboc2bJcym7vzkqXz1PxkcrDmWNEwVyMgG6dgJd+CP0dhumw2dM8+eLVwG3MQDr6OeXhdVlE5nbuLj5QimP+wv061CXQYcov44o41pFeCNWUqRZlvdjyQkVnD8aXf/9VE2W/w24zaOUL11+Ig6aPd0nD+qDVSSobiIzv89wE4BxD7qDqLlQWJsaw5g9RNhCp2ugL+GN1AtzagLKBgCuPHL9IGSSjN6J1UP6ybCAyrlHNpxe3C+/Lsvf1o3ywuNmA/Amd4/bs44aIe2T1KzC/YXNuAn05JWc+VpvPWPmhJikP8L7dGJMnCeXLmRReceo4p8TVk2niJ0ENwG8MU3UVTf7gfRPkMWq6ZcNEOXfzoRzn48GEoyvezEL0fkGqfGVYNoMnMIir+cXFEKLTbpP7PLfm4hTb4jBc+rbHsy59UX34GHH+wKvjuUarYeOVwhVVX5N4DTIPXss05nVJ2Cc2xMWy2rHh6k1PNje9unRdfh0hjmjaFdBxq+9i7Ah0ri6m6frekpb3xb/ijQEuNi+Lo+mOOQZFUm5oV4rsxhq7t5XaV/Zh80pn/Upn9bwzO1u/nC3HztYbNo9X0rhzYXRLHQEI6RdPlOvz7rheqtsTJcWuxHGaxVMvOlm407gSL3MLwbVyJSUXcdzuXD7rYL7dQTnGvOv9L7F2y69jAqodRl8eI25k84NJwTEkcbMGgZG1X3994GKSed+dsiqFpXzoH0hNJ0knw3mnxC1at6EuCGdvxcsj4IRRl1imANakB48RBnzQOq8yP7eTtwGOOOvRA0NHOz2hRLdJrCxL/CQTR1nbEgyNY6LuYglx1qLTL+t5jN8qzrZyxd8ED9kvwB+4QLUfIIlkGb2QnN3yS1Ye79vw1LfpN8i3UucPiXMqoSx4POLjM8c/lJcy/nHuitV4bTD9gj8e0c7fmfqOatW/TSUkOV/v1a05P0WJuM4Xjmqj6HQ8VBnruDxv11Czbi+8MrfoJUffKl0i0UVGly1+H2P48OHWeFeevau3bZCDSRhl0OVgxwtY3Oz17WYg2/Pk+oe+DSoEQQMmkFIIPl22MYCyYCUf7Oa4Wfbexn0Gs8b9nXowoDVhAmG/Ox2EbZSxzXOXD1hIOZmNpz/iL91ELHZHdDbULLKj4Ru7+AQSdJunhfasxpRun0WSwp2zfYIcrtFx13XBhjaIouUwCeZte3xrGHkL+KSNMxifNVS4uT/l7BQJmfTxDRXaYAgEQA8p5dVkfjmLeU0Qa+78arhjvPJYqjagQyHsacTFOe9K02pyEANS56/Rbgi//tnrcczY0piRH68nZQh6AD9P4TDEFzyuTnzcLliI7tYgU4iDBovJWA3HfaNEc8EON4WQ8RrJL1VH9BPDjYA7LJqB7h7XrTNuH+5qBXa1PiDXKOo+K7n7x3Tnxo0bt7/M6dCCnY6fFrURsi1R3bviu5woT3ePXQwj1OsYAka2+h4hnHSP3v7oklFIwerdI7hGRi4ucbNgOZAb2+5HA1h6u9yu/S4BC/ngtljxL5go3Gq6xXlcBAamH00v+buF74rCqFZzv5efvztzBOAET8oCK2cBpue23/WSwZLbX36w8txrC/8B5Ll97Z6wJkBos4+gtsevxX2HB8wJUEknADa3vJw0rkEsb55s9+Lxds8ezi8PB9jD+etdGp0xDSle/mCfaaLT8S3Z3idk6xe9uE/IB6+pfs3FEDnJ8cJJ05yVsFKn1yefSLrHu+3hI9kK/SB71uaenpyVNWGl5JOTOrSA6v3MIUk+mG/+9OBbHMr+yIfHI59yT88n3hIX0W9/vLTtwG0ve1mRfdsvLS138Nt7Vs1vyt0tL224x6TvT5o0bZ79hY+2jDd60b1h2uUPaAWVYezv7mxlRgZWiPDAQIF4qHFGvNR1IDIVaxx6Q/HQgJLaRyitdZcHVL6+J1BvTKcjNKUeGsl9TDl7mT5N3AKZwdISJnxYDC8tHkPJiGyPsGxErRiJxw1GRfLXMsXaAX/JX+sIgIXZFDfjrQfjjbAuY+/H26ovWAF/bgFz48btR/s0zALN7T0CW15PEI7c/au6yy+hWEKY+TeY5Yn+e7pz4/b7HBnmiObGjRu372rKnvwv/80GzvXzbisd6uWJqgL2oHaUbxJgdxAlkEqqraeX5JuH3XxeKInwGBxlksVXvA8mgebGjdtXHa33hf5L4JOvssONG7c/62Iw0zE3bty4fVcrZI8Ny7X8MAPcPsrJYIbfD2sIyq+sS9s1CQ3PaKJ82ivFOGhUnyWVE9lTucaqLXR8IPW62+h4EG6bqL7ey4/apWflDIGUMNntAm3xvIjE0Wj7bsy5kVmI5Qxbq8WQAQ/7hTu+re3e6q5pefJ2SXyFGic+4a3vnaixCwRbbo95JbDTRHBsbcKObukV3R51Gdpit739BSmgS5IH7D4dgGo57fRWjsMQ+uvtlU61b03gw+ZP+zbMr/vWzR2vKRZW5jIPm4/2JbJtuOT7puFyuCFH6LggUH8l7j0hn2HCtrvSZcY60bhAy4lg+p25MlxG/gW14KiE0R5NfmNcqgKecI0OhqBLhY932zQ56YnNlWuka3nx+WOokAH4a5lOmFTaKqC4UZVXwEFMrAs3cnaZoBUA6785ZfLNi82f4Q3Zw+2of+3I2eitYQETHir6WNQ6G1OTeubx9xz5hLMv2I+5ejTm3fTrR9O/thTdwlLsXgwfBi8GFav31x4StGxNpn+LG2YTd13Ee9o3ZFoM/qgqM0v7xrGZwf1mprJ81drmisEkTCnqQ04FqWZYyYDb2OVint13rbaBXLyK5cIOiQbE2rlM78W3VR+LhtAvCyrrLcWd88nzkDOEu3N37v53d/fiUa3YZSToq+1x+0jHxzDX71t6PSHd6hOXCgrYYOhElyug8DkldiPu3EUA7rYXnxVlFswJyLzFMW7ukxuEfGsUC3pJ34VBMDsMV2OwSddqCfGA/c/SYMU+LbJ4Xi4isqxNc6PfQ+UW8c5DtMbv+czUI1VbOYEkZliLRfQWRyuys4JrU7VmK1UKTT5DbdEm6lY2NYtHbeQqc4xhV9+K3gxaZmO3t95oUFNthTq6+NFJGnM9e/UoPS4HBVbLlfRSf5NJbh/rJTFf8Du2rI2LpJnJMUmuBxwE4YD6cjrpy0033x0nCVXrEOpwuRvLfK3EmHdMxWUp4LgxoaI2JSEBte2eaJIDiWmIfSJ1mv8x26AomvLZo3lFF6X6CUqt+TjxiUPiIq7gInSL7x2F7oBu3V6XdUbNg4O+00+EmNU0W35HXC6YwwMyodthjUCya/EU315X1GveR+nRdNg2lsWf0lJ7T0/dALP72aie3oDOxDibG1FZSPEYw9Goyx5yTCldd2Tnf4+HYW/PqcZgwoSJDyNKpBzfEHXojCYAZNoTXZpqPkO4nb0lph/+nECTp8wWQu8d4oPU/4YJeRDhJvLwgg7fsVGv/EkKuTKwrxqpsBaRVB52baDMQkKPqnL27xpBcfJ8/y6Rgy0jFQaEFMZm30hCehVpnfbw3zBSoijQQ8AWjVT8dFwR+oGRJNEjJu71kpUag5B6eOouWTH2KwgH+2qq32R2tsz3Xy3uzu1DnCbmN37Hph+RxV5m6X+ruW2hnDfqLhFiKw+fQaLKpNBHaE993SQjTnZmTOZgZMxjoe5Edh1MrZAislzbxUbeEIGL7fI2kaMITXYSHj1Czbdsv1ZUBFTbF/vv4oIpHR/AdqWbfSF0muStZLtyYVyRhksnXo1il/jfONcur7GKjy4Rw3GYG7YDTfEKMKtTNcdzpSpLdLQTlh5yqQjEywNglQO7S9yGHhMTKb97dg6BKKnMKV3Gj8Q+eJ/RGTfbAx6Vcu18Bn2Haqna07iDxm0/Po1L0RITMvbhGj8AVFPSp614Y+un+RGxfW7XS78K+5KSEmqZ8bbXQTQdZSJyxQL15HuhE4UZBoSmoT7yZfVWx2Ur13Bqca7G9c1UalUW3dNUvaaw8g1LNIGwUKSqRnlRhd/lXfwg/Nlly9RKkke7YQV4XZsijONZHUxvHMAjumejUKVrQ1o3EdWUBRt8iiKZ00dPAhJuaC3MERwubtJVEq0E+py5naRLzXXQXQWjTG+3SYk9dGbapSMmanCoZRcWnS2RRNlvEquY1LNZ5C3n8yCDQxH+BayUwe3sZTFh9Ns1+aKCEZ61X21zW8cxuQgP79B6ocB/5szAC0DfrjBcDF2I2fQF4kq5fWF74j65rQu2bMlmZLS09fFOP80eHYEnQkmxh3KWhvAThe1ktyTeWNijCKKkA2ETk2/9axDrzp3YA9tJQbPr28sd6Lsu3PbFo8PabQ1d55cxCQC3W7eHSazf2P8JBzZDmEKJAjkgg0yDINXthcgrkta/uaRlHPcYlBxoJP4AfsfT0af6OEj8Saq1N94F+2uoMPe/ohau8dLegX3HRUM9zuTsbViKdh0Pu7N3ka+2AgpSDOYiBgZtLg5ipkSlABWGFpNbKA+g/g0sHqssr2NPKkd+rL2DPQN6J3LKhYPIXOGu83VgSQEcasSLHIAwiXc0e3/FC8LU0GV95dRN7EMjA7bIDlF3SaTV8A7J8ftBAysXXnUgLIrdo3T3jcv1EWjl5gDi1szIpZNcv5GyY5+KUmudhyZQl88O/XQnSDJXI7rbpvdMp4WNm1m7v5g0pOOou88+1tKuZq8qcEkpLqRsui17raR7rd6l4+X2IV4Ys3y/b8PDFrP+UE4J3KOlyMQF95fUQHe252SYibIZ2rgGnuwW85Do6NDDzvkFRDycsVeY8KqHCAzLAFM9tZwTzAA9QAbxLyMWgi0dJeSgYqtz88ZJCxr/GyVSOszNytPIgUeR0ChyzvDYFxZIO54q6jHKaYlhSdmKCw9WtZ8Wnyuua58AWk1dXR0pZed1EXCfsaasAzOcGt4q0BdHHxOPeBVyMs6b3oEST+5VJVsJ23wZdHXsc6bXSwQGiLY+Hm9yNaCq3OxzdI4DIhzPp1WC+dQOmgcwp0+HYBeD7fY2QIwXWnmQqkhlCK1wDBDjZsanDreRl8V849y47TeW3eLGK4tXFrcvcEKYgZsbNz4q+Kj4mwK03bT4bzZwzkO5LegPrdPD+NSepB10WkGwHROryCU5BMPf4tVKTGxb2K3iG/0pG8ptxzuxTJPN7V23eZ3RUDtl0DphoIHWkoNd4mAUBz22HGTu9F2qTiYwUFLQM4NKq5g8CHay02M5jjy25FE9DY6HmnwZTAMkxqUuSyNy9su5BWh0x+OZavHBbiHCexsRZwFYQ7eOEU5fR5+/DmY2bCZKXXwmTDogRlwOUhzS50o3tXgWyjSWGY52Nd8uZQbF8vqDkxJQiwnbexOQrtXuvwnDN9E9ITTgxu0L3R3mu+bG7e8Erwv9Fbx9/fn0m8zywPLAcuP2nc4L009z+4ENBSQSq4l67fQ6jNkt0F+S86Dx7ho+TlxsiyHo1EFkLp+hSFyMOGzQBho4CpLUIGaUwia5/mkpL/Cvf4SKd6UHNKrWR5qgjRprLKxKIa3HxzaqlEsKD1+04TLAkwJZm69jxfzrJG5JR/h9+uGFyfAiZB9gOuHmlqoSA5BDOH9aUDZ90P67AIk5a+NdQJUMKZ+9i9y4fafDw9TRb90w24H0HY2GqziqJ2PU291m0SH4tcsmVheHWQGEb2WJkFYspIolKwhtW/qd2SYbY/D2grq2oVqR6+d6tdFx5m3TpTg6LFv9jaI8M1sPjxWytXg4psM21Dg1LaaOh79dz/yjB1OTIkh8uCfo0hAjid3OqfZdP6a4oVMedjlmLFm5QX5v9z8AHDuTaP6o/tw+yslhtmduYy8i18umsydxXdiD+hUponMd7mwvMhdolNEPyCKi48fp2PLjk8WjKAuUygOXJwlew94gF5EU54J0sbD5nXh8sJNSKyoLoXor3bnZkN4JMcWAQClaRhe1/HVb80zgm+HgJkkEAP4A36ANQb5aGe5K8hOrXDX5bCGm00Y0vapHV8iIwVMPEtqi76MKV1ahODX2ECu9YiPCDqblGe5BrNRpbkzpugBKl0rkN6jVh4NEoTM04t6rRAVjHnGMupyeqCyUClF69ESVY7tSJDwbpfKq0LXbyOyWCYT0zswnUBIJ3Drwiat8vsYC4RVtN53K+07pQkNhwKniM3FLMz4LA0oxMudV+x7IbSb3tgA9iW1sR5xDpjCoY692g2VI+lFRYjjecdpQXiYx60ebIeSQ3OxxkDMbxhixkQT3PcQO6REk5AFKm5g2RQgXigQ2n8PLbhzTSb+9QybOL5x1e1GEEdXJuonkTlSOHT2ngRl7hKGlhqFyV2YxkVA5d5FkBQhDypI0eqVMa84NMG7CjzOIH5L9MIucUAbrex5laJhNAvG6SsbwDjVLELeULRIpjiqadxbkIfkpQquIrk3lXZzt71DTXHF4249UsFp006qhjP5V3MrYa/EIEIQMN2PVDAmPIUZjJqVKXHRBtSSOuHTKVaqLKiZ9ewtpNNHUuV6p21UuuVRDmO07zc4SXQ8zAWJfbT10c0HY98wrkWMOqi74dZNlBEqRapjJh1typ5im+i1dKO/v2AyT4j2Gt+JuNfMm7qyNThib4iIr9mrgXqUbK7pOTWlNJEuTW4bEObKQWOX8MzOO3ArH0Y57K0BPBR+emaH0whdsc9MxtvmYq7EwvIt/weQjBgkPN/kliwnBRzGOc1laOP2iJgepgCY0Hy4moOyLcugA3JsRRzh2So29YsbJOydgyUwnCqgemuk4M2EkI3drR5+IrfXG4Mi0ip2kXN7XQIIHW1sR44NHFtWRWUC4YeTTtI6PLG4nz4ypq9+9pbthKPkrcYSHERDldc7IzdBU7nS3u9u45HUZcss8bXI+1Ga1JDgw1BqKhtLlEd9hmMfwIyxWHoe+kTO5agjEMMlWYgCPnlfkonB/b6Jbu9wnLQZKbxLnSoIo3weu0ZJ5sU2E7F7r/+LjC5L/2h68DkJmHqSUAChd+bZYmQQaPTabq1dkH+xWWBrZiC5VdN2JIhrz09YkRzYkyuwUyNR3iswJvB++YqOpbmeJCqf3XR7AC3kE2lKalQ8Kbq1jxGzTb9eUnGQqMDiBWxniYW7yeEpu3+Vm+HBq7iilClnxS7eZp5osHFsbm5odPWP4872d7hqqh1RES2a6S/QgzbdkphP3CPqZGdFmM6VWz61IMZHoWrYC1PNWD81Qb7U/0B9+p/B0fMWr4yvViV3p0dLzd2HOxRfBDrLXu+8lDbmOIzZjOz4BnVDOpWOThEsl2gebmJmo2s63V1VKgeIYa+aJ4HblejHH9js2L55zywj/JyzCdlyB+39l/72zSfwRizzHvEZ3ObK+wyS3T3WfHJOAv2kbstYs/hhDm36rxSd3PO7+Fd238NT+++3x1HL3b+rO7TOdIKYGf2/oOWT8TUITYS17KkrWectAbsQYr57cjRCSKt3LIQGRS+8qKyXW5MYkXXwel/GiiDK2c1MQCDNSTIWN9dcjXNnrMazDP+f4MccYpo9Xy3IauXuXWtxly+nqpwC2MVUU0+K3GbUos2hf3A/znElfDUZJIp19yVj3zdzlNxBTM4LC7y416G/sGAr6MfaZGUvIPC9r1G+sEBKKNNbmmRnMITcVC/riw+7slKgOtKQTCWoUKmOAI2/7ta28ffS/OwWA40Pqef1x5suVBQ8nDu5axITGmVEcXOLWeVfMXf7m4KgZjkS3JXNsha08/PEnbPL8sZWfY4XbJztZzJf+js2+oLP1PQZPN+JyGxYP1Lm5O3fn7n9z9x+3I3H7HCeI+dTfG9K0euX/RkunUnXL/bn/D+5PS9y2M6q0OnObpKIW6qnrrO+vR3TDGIn2pwK0i7yvbIWM4v9irswl5QWksLplw1rKyo5QAdrMkQpYwWsK6RQyieMXS0QEKrMeOI4AcbtyhJiR/GNTblYScYoIdiJcQUt2kJG6aknEbL/art5GSs+KfUCihO367VQO7AmLstsdH+RxqUAlLa4A6TM7+BCKlPobtztfiqjb4DzdwJ4GdpIor24rpu8J+zo7QZ3K81EnUe/ZuT7m7nnpR5YiBgrZKxrSb5jM1tiSTAIqJbqgW+KjsDxG5IjtsF7TY3y2FnslSD2ZvJt3wxIWcvQUxnT1C3QCpqMTUA/tSOLEIfbsIbOGteTboSrLQx6KRjansMg9sqPIizcUqOL2sV4XE5e/JXq8I6zT3J/7c3/u/0f6P6j3H1TC/Q6b3D7W8WFe8PfLtXWav0jM68aBop5fxM9NXWiQdTU5t7ZKUOikV0ULVEoYa2IsaWgl0U6Z6JJp3V/hKm7U7mbmdFv2A4SxGkix3bo9I9vYTVOA5w/2c7VjThzSribLr+QywRz60F2edMFck1XJ8hdguwK0LXu66ueFxPae5hKZoWHfHv1LCOeeu+agCcId5mpsYdeaoodyDFo+fjKCFqbRnAemZgl0NvKjjHD7ZEeNecrfz1E74yfBXOiviVbE4t5Oljr7AkNXUrpblnTNdIiTBseOpSSpro/j1qkXTKEciCEu4ku2mjyM6jK327ZEdp0yW7V/0Vaorrdr0mhPTLk2HxvcK6ZEVovsMcwPbSWVnOObGvOKLZExSITe4rktS7iN4h3lheciUs/ypecShI1casIq/sAWfdfp/9szdU79vWBJmy8yJLLcwNwOt0921JjV/I09tnTkJTkUvKklddqQ4bsu3KYE5IHgWaH7nYt91RMq+44qRSIiFsieAcEqLBUGnXRiZBZ0yL8irhTswFJtjIHwMdV/kYNI4kFLM6EJAnLOj2qfejBQuIyUGnIud8PSqT3DGnC6l4jrZBAv1f/AEaU50/1z6ERqL2mh6Gz2ELUQnpnpvnwvp/LwS9F/nQ2xmw2x0ic53QfzTTGPa2tv/Et05QxEYly3JoZP68SUY01SRb6I87xWtZancc6EdUmrj+Y59Uy93dDdYL5/+TuxQpUJ8gBlyNM8ioNEK86j50OH28jP8kx//o7tRiJBH9KeqHYVkyM2PDY2U7/ak42BVK+VOErlAjXmvTiFpAyd8ZvrJ3YwyEKPWYBndrpTRP9ZM1391rNvJY/yhua4hq15j8lIFIXr59185Yr0yfV4ZBAzr7EoDn26WfEZS758dn9uH+tNMY86R63ePWqlviZq5b8kanVbTvnNUSv5V0Wt4GuiVl8UijNPh5hGreYlcCtRq/hRboCY3Fx7YTx2bjNqNan9W41aqeEbNya0uIlamVnUStGPne5f0YvydxtqjlpBuT50muT+BHNYqBYwdxvNvIVcCNy6gI9q1SucEa/Zu1/Eurx9sQO654Qx3fr7lSDKxXjWAUay8NjYpUMGCDe/swdVROWIZ5kT0wBKnWxYouCKBicthw7ZvR1xUuUAYZ/ZoUiOkae5ZkbeIlmWvlXnD4gnj5PK3G3r9kq/ZScuRHR/BB0dUF+zIiGvq9cXuPS5PgOWrDVf0yavA1Yr4xbGnWKVnH1oRmb6rPwNYSRrtbaaBFVoAvnMjqHMXiYtkG0zZx9ewTMzuhS/FIiZfmAmPpBa9h+5fZQfxozsb+yQqbwbniAHKl+fMIgQ9ESiS2RZNLlTi315GVKGAE807mI5FAUiZZjwSoWfiaG7S1vNHTKeZmNwqtI57HZRlVAqkNz2FZbePs129pfcpMWTWGd37sU53ELoOnW6zeOJjI6v91fgt8F3sdThHXkwqL1mUhryZmT14eygXT1L9vnFa7dOtJtJXzN05cCQ1vje9ANNNDv3YAJBtWXC26+3I1UY292bSomLcLGcDIwVR1VuuniF8Tcs6P34adEvylUZ8R9SObCn8PmQYuMzW8s/om1nL8sPfy2fcLjGAoo0YimUjbcUjB0D8qzygcLt7EAxm/t7tfCyYBv5UffP32b4wrUphwM84GDm7tydu3N3btw6h4dZ298SONVgJi5/p0mWSzbCRthINiJ2jIwxSU2ca8nIMDSHQMdZvR4Nevrxk4ibysAOEzbOktNw4ICpHQRJbYfhRyVdGdFSegCGajTm67B2Dkn4K++9FCfgWA1aySP6vRLF9klOYRZDizFFzBnil0ngNMgThZAp1AECPl+4nT0pZmJ/Mx+KhsTDZO8Asg9hXoSE5n0LHoKrrbwT+7AnnAHJUfjrXIabSWFos4CK6jDA4gyeEESVAvxVUkxXmqoxQRj91uqcuOtAy2NQp+sgSKMjjMLGh7PgKHdrGCyK8rigl0oF8OQko9am6WB2JFHgCYF5BJihzk/wtfp5kuaEyFmsbt6HsadRpYUuSgfpIiZp3nyUajJ7/jZ7psnA5MJAaBA0sAjhldJ11Zyo05Lf+MUkcgOhgoTRqhkwALNmhGLCKUuFCms2Qssw18AfYSsdCbRsJI/OVhgJxDk6bhlSze3Kd2Iy9zfznVTZV8PS79czpLK0N36TvN2KDcUvNJtzIJjieQ1JB8GBemzRavU5PITWcvnymZ4WZ813ZYrxriKGW2dlc9wa1VykbRsrQVryPADuRBGo6kjaq+moZ02DnApnTlYz8C7By97xhLNmGoJcK0d59vIqVTnUc7xnVq0DVuM91Y2rkY3Ge2m81j4y08CT85mY3I5SzeZbjFQGpjSnoJnWgrqmDO3gdW3rGH4NIR1VO2CFqIumxDPSNPs8lMcjepWFDwsAa+Q+HgOPdVGlUD/T/ZbSNCxtgFrwdxHREqot8MoCe+ao8lCalKFpO3csa9Fk9Vl639QdnqbXc5XI1jMNw3rNpuC2Mu+7SwTdxP0BcX43xhh+3YHbRBd+0vJUljO+IAVyCxhcZhvKFun4DONGPTRmcX9DQLlciKyILBJS4zS9ZK8n0vU6n3mjiJImIN1x/W0bARvsrNRDU9dwcqJ2S8jpkxouqRT2sxhgk6ZpI3vQOEt6HoNpD0riVmho803XwTiK9KUJlEAoEVCQdwU/nJC6vo1cNCGVdQQyDGoJwG6FC1KIiszsHgS6iWM9Er3rQoyU+8GvnIZpTSkyC5IEUdU4iHoKh5JhyNQK6S+LW6znT2ToXYjMZfWp8DcuNa5xSVCX2/XlEoo4e2phcTQee+MLmbvCfy1blyvFIc/rmQRn8cWy16wqcOVwiZTdbH1y+rR0qeh1UL+ZU5hx+yh/isnW36sZmmaZHRo2R1AakkOyt1J9w8uKly7P10RxjpgIIdiJV3M9dnAatKgb1m2DuN3Fu5TM0BlSxM/Akuz2w9JjQCcHuLJF63H8CJMhCm5cB9de6nONnO3Yn26TOCnOUMMR6YiS9bSIs+GX3ClxklVqxnXxZm6JS974RFt1kY5Ca+KBqXazOO294YHgCHf/zO7cPsYVCsyH/pbRJa1f1HsfeD6/xegsSHKmExJmaxToKZzqj9c/niCo8Bqu1nvDSfMLcRk7MA7qYfq9sYMWTJVu5GHr472+ke9ej7d5tXd4tVrfyT/exNDQR98aOH9mddzhAaBYRH9OEt7F0ojXF7YGzukXaBRidKwCshKEYMt1aJLEGLgLuz6LFK+W8srvMcrtY70l5jv/KQ6Qm1EEKPmHrDyhtuXu3J27c/cP6/7Ht21uxe1hhvG3a5S4z+ze1gwp33HhwateGftQpU5t9ydId/vgrYZa4o0qEdv9Q1trDto8eIQKCUF1it2BVDRtJ59MREVrqSe6DZpQX8ITzptGsyPGS3bH0fj76ve7mayl6mpfg4NqEz15G2qyclrrevk2w0y9eSnSKuVVTcCDaKXePftDi4FeKGUcvcz6RiXgbg2S8gb9hEW0oeO1CQOwtwgswb+zo/Idvg2zdv/1zc6Ew2EVFfE1VmjBj+Tu3J27c3fu/nO2bXZ7frk9zLX99qBoyuWGt6v1Sw3GNuQA8CPECKU82DBONWdg/L7OByo+nXAoHZ/QDU7CGcrCE1qQTgNBzjoK4yuybgHdJ6a+g6Ousr8Mwt9EaRP8EBMOpPgHAyNwWW+FujOXiiyBUDtIBoJy48btx7kqzJLNjRs3bty4/Yb2hVJK9f7z201/vyPCJNPfE7jIl+MKI4PtZC7WDtkhi8ROGUrD3/ZA5zmx8bjMMmMeEHuZUoOEYBvWmubGjRu3Nw53MB0zt89ricFWHiy3WI6K/hNmsJC/zetMfxNmYNbtC4VOHGdjcwd5DxIZY1lBQCoZk/5fFlASLe3wLnYxkGuS3a6bpWw8ws29ScA8GBIBpceeKTjBGI8cEbJGPWIAGGehgCYaEY2LkGDVUmCrO0uq5cWDWPetx1mxuZVuQMeSJ7cPo8VC8T/qzMztpKkqiUd3Xl7WnObxapw7jk8kFXJITZ7kv8QBaJcr5hAyDO7+FfOJ7PDWoEh16ICodpxvfPsRlRsvYBDnJgmFrVnj9pk+FBMm/82lR+Tl1dz9D3aPshJIy5PwQbjdInoFTwG9aioLHcDsFIgHzSXHcugqNlU+WRykExCJloUh2p7XbMudNaxQ8vPnX/mSg6cHqsQG91a8vnME1LAIi1oZ05KApNJV9m4FjK0A8ZEGkKgnz2Iejotoq3rCy1M09o9XFgz11MbVzZfLOKG/0HVBSqtmFZtL1YhuiUqisTt8xcwEwTZ4+d1ReldJ5vFFw+/P1Ufczp4VUydz++TcpD+0uDDShLx6WOsZtZXQQZlfReF8C7/+gVz7dg1ffZDVRamjGLDySd8ilbhjafkl+LtR1Upn6PAjo69wyQLYRAHix2wVZXQRGb177lgyaGE3y0oFN73+3k/vv7zaX5KvjL04yWFdzH50EC6/nKKCxWQpaowuYXRXHq4VzOoQMAbsFqEj4l4PUCR1mMTlDUVjOL20JotKcPyIG3V0QDAz8s9stGDQau7+G7pHboqUSsKrNeYn8O/iph832EVT+Gt6usfHC20XTBibSzIQ5ZoecwXeHxmFzOybqsnUvbFWU0OfwVtGrNiBBTHequp5ZUV1ehhuHLTRN2asvWfJoSK5AyOdUvrQV3B3Rqju6sMnUeZLRkXQnOHDKRJU3EunwOr+ghFZRbYmD3EV5zI/OCRj0yqWa2+Yu3/D7EksbPruq/LuG/ru+613n9uHelbMosztY71TfbD8YzxflyhSDPaghPf8OuszPdrK7RjElRps8k3AdToNJp1bPkmThUBK3vGPw8RCJ/KhT7+XGAaPozgMrTRyXfpSfKBRrg8XkP0FAYRG5kufQUI9JEct4bZ6sjZnzpkgUzM4qvwg0nW9LLmbPdrDH326jsrWhyelEiAX1VHHA+nbib8UXPBwKR8viY+G7kz06VCwHTAkpg4MlhSVf8JOg7RqR9jG3OqrpI/UGU+YME014xa/teHdkdvAXWL25Z91wtvMoZq1y9U+YZWXt8jcJTuN/E2MfEeL6/tzJ1AvdlMTlO1nW32ZBgnsCnORf65PdjGeX2/xxa/I3bn7J3fn9lm+D7Mzc/vIhhVv6AI2QXaRgz8xKLMYZDehpbUfh//VSSr1IjUBxak9khThQLVCrthKSbiwki+BWd1byqbIlexN4WgYA1QwDjRPJdG40fgiD3D3MB0UaOxQim9JsK08yWaCbayOAqD2psiPp8ivLBgyAT2nhzarC0a2WVlcxSDEAc7OM5CWsVjLsEmitTsEZvuTRIad3KewGC9l2Cx9+VWCYtEVYHZLTn24gebfQMYq+yq+xFt9bc4W3sv24McgbisKCOMfchkowsPqcMawoZ5woyTA5sK9LRq6UT+Jwbuo65xCflCSqzj/mKSNf1TqDXwvpoj+ixuNTGyr1XD3L+wuVamZEUf6Cnf8eNobtWqqAShdblB+otXWBavw/I4cWPHgCpmvIKXIyil5GdTrbYkzoXUn+K0W7IxQOvQoc+reyoDNSy/ksKgRI24q9oN9tHbYCBvh9tExK+ar/jkNqkCG/nHd//axlX7qy3yvmbeZde7+Id1BP88+X3zCbzDJ7XM9HSbE/lFNllJf8Pqndf+rk3XyFg209JW/ys47zTt35+5/onsRD/APiJAa3b1tiJPSVK1wPTsHOUsWVFt2cO+2wT1r7poY/dBQoUcJ5p18H6bp/sujD6GsRZDc/a/pnhJmlTLRXMnSTswgtLyCEHCvhs2nScwDumWLBrP5pZA7qNzqM0H55tikMrIq+CoXKHw6K5nAqYBsImpI7U0URWzlv5OJHXrHTql/T/CumpcTbqH2oDUE5cBIJOs7usFXcw429AnXJ1YoQXb8oso8eh0SLqV8u+iy2EcvVVPROCFxujdzInLy8GiDwDRzJVKPr6piPklu2Xdieu6/OkrkpwEI/61mqEnB3bk7d9/xxQt/gw8Puns75zZfzmAlDPNuCak78VNE9PPWk4C5JU1YqqWFgyoTbxvaPrPC7YPcHObK5vZRIbeav4qnljuOjRQiif6gTdJpKTiQFEdsDpwomNlLASNxwV13RYg0KjeCjtcA9RdMoorsu2NZ0KE6d10w05jEUpRaL1dPT9+cI7VYyF9bItJr9RwGr0hFnrsSKG4nw5BaqxLzIjV3DTFOz73UzesgnAKkOKrxWRSsmvK3piSbYlM76ShuH+JpAXN1c/v4AkAuQ+MyNDbCRrixT/TLJ2KWbW6f6RnlaAgEXfiKRMYjYPgE8ZFzDCYc0KQFoscAE+iQpZlQnUXMVaIlRvKZLsvhrkyFcOfEdKTF9iIlVA4OPQYsdcw/A9eRMN6Av9SoqygZMYjE0e99SfwMla5mkGOh1YHX8nFQhd70b3sWAilbGpYx11QVm9V6pHp7P0MD3NSAO7tfMMOv7Q4q+SpPHMMvKq3uQtLTLuFJplIpIll382rps8PfvxWZhCphkpJWzhFdxikIi2g4bh/nIjGzNrdPy9FRuc+4kcdITpYBL+obSIaHN8x1WxmEOlcol0kiasVelk/PglKQHybR6FX8RcyT+RVriBfvMlsUuAzCrnzNAdWczMGpiiW/NePGv1S1gfXw3Oqs6DFVoqLwlFszamxGuhuewEdPo18fGj+SbF2cJ0kUbb5m3fi95eyS2xLykutWc1h6124lArbetfi7VhXhAkfESZI+0dae8uqexP3fztliKm9un+lyueMMRDxQysvZQyT9HMIQV7dnvNzKML01I5d3WLCHz1P3nVK9q/AAQpkGOPtzl0cdrT/qwUiJc3nlazYBFi1G5VBwbwZaynMKmKpBDXVrhZ7xZog6pkmYkZml+BRNtw6fxn/N09AI1Xholma8CVFdzJNbWjiwsHDc9nrWIaspxrpQn3ybvJ7h6142eSp5v7aX5zANS+KNdvm7odOF2n5+2dY4sMj9/2j/v8jbYvJubp/pbXXw7nRzj5GMxL8HJXyEd1s7kFmd2cKeapq+EHrRXDxcEAkVT714FsuUvTQuV3utmpKozBKP0tP5Gf9q0QhGcOzzscYa/1fmyujX+u9fvIdrhfv/lP7cPjFrx/za3D6yuXwngSCPZF0BNiHEGk/QmCyb4B3QVQCxzvvr7Ky4mkKbopsVQ1shRb2iNxFcxmHMFIArmdM+X54k/EnmCVtfPYdibCSG5bYAI/6CLBnjK+iVOHfLDJVNuVt0DFY8ykXdrRhuikWQkNzE87QD7DptqI9WI03qCS9AF9HZNZHEtwr70sWSKoJcUZtQZ7CdTh8XXX4wXb7waiTkLmk2kijNqNOS5CIilKDEhdVBk4CXlbhk/C7ZAbdPcYKYepvbMGwtTxXsb9/fyOeiBmbMP/kbTH76LHH/xqPofDC5fxNofV73wAULrs2VhUzPtO5tJO4H+eKLkN82dHgE0bt9YIbbBzlAzL/N7eNL/rnCmY08MaLujThyCA/CanbBiCX+waAsrCOuHltJv6Ov3B1AyguzVA2fakIrVC7mYFXOuoacQ22Iq6e2jB4TQXYQbL9cp48gvFSI4Q8Adgz0QfoQLvnnNveJmFeb20dhfYCedJfXZYLrc24U3pdXlIUNINi3pEaDaqh68MprvIO+STgEAlA1548J5Hgag2YwwVcr9PX0YWcpIKhHOBZ999jcGoWYCVVR3Q1HnzS0KUSl5pm+Wr1l6bleq7puZaagSsdoOKoHFU0GiduQDD35s8gY1FxRPL6Xkms1G3twP1QgMzi1+iqQ6jjKiOpXw1KOFJXV7xLzdeveRqchsqraQtb4OeVmOATE7dL1Ya5tbh/T6m33ohDosqiqEZFAbt1Lcp5R3ZA8Uw9l6bFSDSM3jkxrW5TK6O8vqmVVKxIGpOyrlJoDKXqXpQ+QYwSdiAEDMV7EK+V242bQA5IQaFcubhX6w9mcWYPqIVkeOtfP0/q9PmpCUSvKZyBW+XBRKcGTN+GoMFv3bLqtCMu+U0rDxO6hULTb7DrJufIXFB51hGJp6ArfUoG5zhXwdV2O13HDQCBCLg9LayTktXB8Gn7J4vCOqTetJbEf9KPjV3fUAWwIsvBHuHSwKSE9pT3qUVwzcLPsyicpYTuN1iFl04Jne6okt2HTweX2aV6UZB5tbh+FlhLEZ4hA3oEMiSbQ2VTOf1E1rYfux+Fs1LDDJVmOyBGo6lMRUr6OKiToqctWD+MUN4HqhWm3XnUlaeAFR0kReZMIPl+5nltagS1lC5dWG0rnA6FxvzXzxR9qtG530DOnlFMeCLkWKJEZHV4dQE8UbkCvqLV1BE0ZqQ+wQEPeuQXqTJoElDNTJzf9um66clLGJJrp6t6TS1kknwfOo2mjeGlBnN8h40nMcVAsAF1c7pIAqWfJCLwhciueELNnc/ukFmiKTC5lCE55JaDUO+4ylSblTdU5VGgpwkEvMid+LiHSkb0M3Dbb0cGoyyu6mwmnG+LaXVfcC3uZ3APKzWNn574heUTiwdGJtPPwYBP/irPWxNKCWckOtl6doTGkvsRrxT1s8l7Zs4UmLQeLCrJ9Vjj2K8wu1/TqI9BRRSILEoRxG66qHaCZEXa0DrUeSBNuOMs5NCqpTs6uu1OLJBcyrP1rGAYLZOPpK4QqF5eK9TmEjltLLnaHy6q/1ctOZ0RlJxjjeaDezF9iKm1un5iI80+qw4z9JnviMnVRHZGkdbJlwBIpjb3yo25f3QOxJiCXvhX7uCy6bnkhzc4ZDJ4cobAK7ilJtpbYEpJXsjFo2rXniNs7/HtyzrB9duuKujJ77weBUwu1c3qLtLAfVmCO34kvN8jtc2NEzGj9sw5rc7AHYxIlXVBFzmOsnXuZnGO4RyxbER0jsEn8v3rj/C07ajzT9q9TFfn7hLylApSFftJd/tHuuk3VbC8hUK3q24Oab/mA7DCkwwcCwa9Yufq5gyLteJn3cuPZBzZixsRt+X4hhbyaOTRyoiR8PQskVWbUk4kUjydSHNihx8voT78Dr73Ale4KHuzC7eYld3a9i90TUuJ2w5N3s3sW2M3zBIPTRSfGwJ6Nt/KHmHP6B5VOBfkKZR535+7cnbtzd+7+13b/vd4O01D/7eEeOEg01KEPjbgTePHem26NfossLYEna01RAmfsXly7VDY84H1LAzKsUlrrLm7pche7++/vXlmmzZMFJZ+TVNNbu/T7F99A4arxCWLkcDPz50hZ96Nrb0onSfncSJCngqYYx9x4hFqhFRFBansiyztg9UvLSIcf9w68+gK7x9uHEvuIsAINR/JuKtq3un1ONvGwvIln0LnIQHekz8QiD/j0OrrkDTEfNTdu3Mpm7w90sSrHBlbOoay9GwfTe2QKJuv0HBIFGZQS02EI/NUHzFqNPLWU+40ZJEzhQNrAkbsgqZ6LKZ+fP9MTgBJDCQssc8KUMaYs9JE8TjJ0LHXFjdvvdEv+8z//Pz5piUA="

def _load_font():
    raw = zlib.decompress(base64.b64decode(_FONT_B64))
    data = json.loads(raw)
    cw, ch = data['cell_w'], data['cell_h']
    glyphs = {int(k): bytes(v) for k, v in data['glyphs'].items()}
    return cw, ch, glyphs

CELL_W, CELL_H, GLYPHS = _load_font()  # 19x37 for size=28

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
        with open(EKA_LOG, "a") as f:
            f.write(msg + "\n")
    except Exception:
        pass


def run_eka(args: List[str], timeout: int = 120) -> int:
    cmd = [EKA_EXE] + args
    log("Running: " + " ".join(cmd))
    try:
        result = subprocess.run(cmd, cwd=EKA_CONFIG, timeout=timeout)
        return result.returncode
    except subprocess.TimeoutExpired:
        log("Process timed out")
        return 0
    except Exception as ex:
        log(f"Exception: {ex}")
        return 1


def run_eka_capture(args: List[str], timeout: int = 120) -> Tuple[int, str]:
    cmd = [EKA_EXE] + args
    log("Running (capture): " + " ".join(cmd))

    try:
        result = subprocess.run(
            cmd,
            cwd=EKA_CONFIG,
            timeout=timeout,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            errors="replace",
        )
        output = result.stdout or ""
        if output:
            log(output.rstrip())
        return result.returncode, output
    except subprocess.TimeoutExpired as ex:
        output = (ex.stdout or "") if isinstance(ex.stdout, str) else ""
        if output:
            log(output.rstrip())
        log("Process timed out")
        return 124, output
    except Exception as ex:
        log(f"Exception: {ex}")
        return 1, ""


def eka_success(ret: int) -> bool:
    """eka2l1 often segfaults (exit -11 / 245) after install - treat as success."""
    return ret in (0, -11, 245)

# ---------------------------------------------------------------------------
# Device handling
# ---------------------------------------------------------------------------
def parse_listdevices_output(output: str) -> List[Tuple[int, str]]:
    devices: List[Tuple[int, str]] = []
    for raw_line in output.splitlines():
        line = raw_line.strip()
        match = re.match(r'^(\d+)\s*:\s*(.+)$', line)
        if match:
            devices.append((int(match.group(1)), match.group(2).strip()))
    return devices


def get_current_device_index() -> Optional[int]:
    if not os.path.exists(EKA_CONFIG_YML):
        return None

    try:
        with open(EKA_CONFIG_YML, "r", encoding="utf-8") as f:
            for line in f:
                match = re.match(r'^\s*device\s*:\s*([0-9]+)\s*$', line)
                if match:
                    return int(match.group(1))
    except Exception as ex:
        log(f"Failed to read config.yml: {ex}")

    return None


def set_device_index(index: int) -> None:
    os.makedirs(EKA_CONFIG, exist_ok=True)

    lines: List[str] = []
    if os.path.exists(EKA_CONFIG_YML):
        try:
            with open(EKA_CONFIG_YML, "r", encoding="utf-8") as f:
                lines = f.readlines()
        except Exception as ex:
            log(f"Failed to read existing config.yml: {ex}")
            lines = []

    replaced = False
    new_lines: List[str] = []

    for line in lines:
        if re.match(r'^\s*device\s*:\s*[0-9]+\s*$', line):
            new_lines.append(f"device: {index}\n")
            replaced = True
        else:
            new_lines.append(line)

    if not replaced:
        if new_lines and not new_lines[-1].endswith("\n"):
            new_lines[-1] += "\n"
        new_lines.append(f"device: {index}\n")

    with open(EKA_CONFIG_YML, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    log(f"Set device to {index} in {EKA_CONFIG_YML}")


def change_device():
    progress_screen("Loading Device List", "Querying eka2l1...")

    ret, output = run_eka_capture(["--listdevices"])
    devices = parse_listdevices_output(output)

    if ret != 0 and not devices:
        ok_dialog("Error", f"Could not get device list.\n\nSee log: {EKA_LOG}")
        return

    if not devices:
        ok_dialog("Error", "No devices found.")
        return

    current_device = get_current_device_index()
    options: List[str] = []

    for device_num, device_name in devices:
        label = f"{device_num} : {device_name}"
        if current_device is not None and device_num == current_device:
            label += "  [CURRENT]"
        options.append(label)

    info = "Select device to write into config.yml"

    try:
        idx = select_from_list("Change Device", options, info)
    except GoBack:
        return

    if idx is None:
        return

    device_num, device_name = devices[idx]

    warning = ""
    if "Don't Select this Rom" in device_name or "brick EKA2L1" in device_name:
        warning = "\n\nWARNING:\nThis device is marked as unsafe in EKA2L1."

    if not confirm_dialog(
        "Confirm Device",
        f"Set this device?\n\n{device_num} : {device_name}{warning}"
    ):
        return

    try:
        set_device_index(device_num)
        ok_dialog("Done", f"Device changed successfully.\n\ndevice: {device_num}")
    except Exception as ex:
        log(f"Failed to write config.yml: {ex}")
        ok_dialog("Error", f"Could not write config.yml\n\nSee log: {EKA_LOG}")

# ---------------------------------------------------------------------------
# Uppercase-to-lowercase converter for device trees
# ---------------------------------------------------------------------------
def is_within_path(path: str, base: str) -> bool:
    try:
        return os.path.commonpath([os.path.abspath(path), os.path.abspath(base)]) == os.path.abspath(base)
    except Exception:
        return False


def compute_lowercase_path(path: str) -> str:
    parent = os.path.dirname(path)
    base = os.path.basename(path)
    return os.path.join(parent, base.lower())


def collect_lowercase_rename_ops(root: str) -> Tuple[List[Tuple[str, str]], List[str]]:
    ops: List[Tuple[str, str]] = []
    errors: List[str] = []

    for current_root, dirs, files in os.walk(root, topdown=False):
        for name in sorted(files):
            if name != name.lower():
                old_path = os.path.join(current_root, name)
                new_path = os.path.join(current_root, name.lower())
                ops.append((old_path, new_path))

        for name in sorted(dirs):
            if name != name.lower():
                old_path = os.path.join(current_root, name)
                new_path = os.path.join(current_root, name.lower())
                ops.append((old_path, new_path))

    root_base = os.path.basename(root)
    if root_base and root_base != root_base.lower():
        ops.append((root, compute_lowercase_path(root)))

    target_to_source: dict = {}
    for old_path, new_path in ops:
        if new_path in target_to_source and target_to_source[new_path] != old_path:
            errors.append(
                f'Collision: both\n{target_to_source[new_path]}\nand\n{old_path}\nwould become\n{new_path}'
            )
            continue

        target_to_source[new_path] = old_path

        if os.path.exists(new_path) and os.path.abspath(new_path) != os.path.abspath(old_path):
            errors.append(f'Collision: target already exists\n{new_path}')

    return ops, errors


def convert_tree_to_lowercase(root_path):
    renamed = []
    errors = []

    root_path = os.path.abspath(root_path)
    final_root = root_path

    def unique_temp_name(path):
        base = path + ".__tmp_lowercase__"
        candidate = base
        idx = 1
        while os.path.exists(candidate):
            candidate = f"{base}{idx}"
            idx += 1
        return candidate

    def safe_case_rename(src, dst):
        if src == dst:
            return src

        src_abs = os.path.abspath(src)
        dst_abs = os.path.abspath(dst)

        if src_abs.lower() == dst_abs.lower():
            tmp = unique_temp_name(src_abs)
            os.rename(src_abs, tmp)
            os.rename(tmp, dst_abs)
            return dst_abs

        if os.path.exists(dst_abs):
            raise FileExistsError(f"Target already exists: {dst_abs}")

        os.rename(src_abs, dst_abs)
        return dst_abs

    for current_root, dirs, files in os.walk(root_path, topdown=False):
        for name in files:
            src = os.path.join(current_root, name)
            dst = os.path.join(current_root, name.lower())

            if src == dst:
                continue

            try:
                new_path = safe_case_rename(src, dst)
                renamed.append((src, new_path))
                log(f"Renamed file: {src} -> {new_path}")
            except Exception as ex:
                errors.append(f"Failed to rename\n{src}\n->\n{dst}\n{ex}")
                log(f"ERROR renaming file: {src} -> {dst} ({ex})")

        for name in dirs:
            src = os.path.join(current_root, name)
            dst = os.path.join(current_root, name.lower())

            if src == dst:
                continue

            try:
                new_path = safe_case_rename(src, dst)
                renamed.append((src, new_path))
                log(f"Renamed dir: {src} -> {new_path}")
            except Exception as ex:
                errors.append(f"Failed to rename\n{src}\n->\n{dst}\n{ex}")
                log(f"ERROR renaming dir: {src} -> {dst} ({ex})")

    parent = os.path.dirname(root_path)
    base = os.path.basename(root_path)
    lower_base = base.lower()

    if base != lower_base:
        src = root_path
        dst = os.path.join(parent, lower_base)
        try:
            final_root = safe_case_rename(src, dst)
            renamed.append((src, final_root))
            log(f"Renamed root dir: {src} -> {final_root}")
        except Exception as ex:
            errors.append(f"Failed to rename\n{src}\n->\n{dst}\n{ex}")
            log(f"ERROR renaming root dir: {src} -> {dst} ({ex})")

    return renamed, errors, final_root


def convert_device_paths_to_lowercase():
    start_dir = "/storage/.config/eka2l1/data"

    try:
        target_dir = choose_directory_interactive(
            "Lowercase Converter: Select Folder",
            start_dir
        )
    except GoBack:
        return

    warning = ""
    abs_target = os.path.abspath(target_dir)

    if abs_target == "/":
        warning = "\n\nWARNING:\nThis will rename files and folders recursively from the root directory."
    elif abs_target == "/storage":
        warning = "\n\nWARNING:\nThis will rename the complete contents of /storage recursively."

    if not confirm_dialog(
        "Confirm Lowercase Conversion",
        "Convert folder names and file names to lowercase recursively?\n\n"
        f"Selected folder:\n{target_dir}{warning}"
    ):
        return

    progress_screen("Lowercase Converter", "Renaming files...")

    renamed, errors, final_root = convert_tree_to_lowercase(target_dir)

    if errors:
        preview = "\n\n".join(errors[:3])
        more = ""
        if len(errors) > 3:
            more = f"\n\n... and {len(errors) - 3} more error(s)."
        ok_dialog(
            "Conversion Result",
            f"Conversion stopped with errors.\n\n"
            f"Renamed: {len(renamed)}\n"
            f"Errors: {len(errors)}\n\n"
            f"{preview}{more}\n\nSee log: {EKA_LOG}"
        )
        return

    if not renamed:
        ok_dialog(
            "Conversion Result",
            f"Nothing to rename.\n\nAll names are already lowercase in:\n{target_dir}"
        )
        return

    renamed_sorted = sorted(renamed, key=lambda item: item[1].lower())
    options = [f"{os.path.basename(new)}  <=  {os.path.basename(old)}" for old, new in renamed_sorted]
    try:
        select_from_list(
            "Lowercase Conversion Result",
            options,
            f"Converted: {len(renamed)}\nFinal folder: {final_root}\n\nPress A or B to return."
        )
    except (GoBack, UserQuit):
        pass

# ---------------------------------------------------------------------------
# Mode 1: Install firmware
# ---------------------------------------------------------------------------
def install_firmware():
    try:
        bios_dir = choose_directory_interactive(
            "Firmware: Select Directory", EKA_BIOS_DIR)
    except GoBack:
        return

    rpkg_files = sorted(glob.glob(os.path.join(bios_dir, "*.rpkg")) +
                        glob.glob(os.path.join(bios_dir, "*.RPKG")))
    rom_files = sorted(glob.glob(os.path.join(bios_dir, "*.rom")) +
                       glob.glob(os.path.join(bios_dir, "*.ROM")))

    if not rpkg_files:
        ok_dialog("Error", f"No .rpkg file found in:\n{bios_dir}")
        return
    if not rom_files:
        ok_dialog("Error", f"No .rom file found in:\n{bios_dir}")
        return

    rpkg = rpkg_files[0]
    if len(rpkg_files) > 1:
        try:
            idx = select_from_list("Select RPKG", [os.path.basename(f) for f in rpkg_files])
            if idx is None:
                return
            rpkg = rpkg_files[idx]
        except GoBack:
            return

    rom = rom_files[0]
    if len(rom_files) > 1:
        try:
            idx = select_from_list("Select ROM", [os.path.basename(f) for f in rom_files])
            if idx is None:
                return
            rom = rom_files[idx]
        except GoBack:
            return

    info = (
        f"RPKG: {os.path.basename(rpkg)}\n"
        f"ROM:  {os.path.basename(rom)}\n\n"
        f"Install firmware?"
    )
    if not confirm_dialog("Install Firmware", info):
        return

    seed_dir = os.path.join(EKA_CONFIG, "data", "roms", "rm-409")
    os.makedirs(seed_dir, exist_ok=True)
    try:
        shutil.copy2(rom, os.path.join(seed_dir, os.path.basename(rom)))
    except Exception:
        pass

    progress_screen("Installing Firmware",
        f"{os.path.basename(rpkg)}\n{os.path.basename(rom)}\n\nThis may take a few minutes...")

    ret = run_eka(["--installdevice", rpkg, rom])

    if eka_success(ret):
        ok_dialog("Done", "Firmware installed successfully!\n\n(Non-zero exit after install is normal)")
    else:
        ok_dialog("Error", f"Installation failed (code {ret})\n\nSee log: {EKA_LOG}")

# ---------------------------------------------------------------------------
# Mode 2: Install SIS games
# ---------------------------------------------------------------------------
def find_sis_files_recursive(root_dir: str) -> List[str]:
    sis_files: List[str] = []
    valid_exts = (".sis", ".sisx")
    for current_root, _, files in os.walk(root_dir):
        for name in files:
            if name.lower().endswith(valid_exts):
                sis_files.append(os.path.join(current_root, name))
    return sorted(sis_files, key=lambda p: p.lower())


def get_relative_path(path: str, base: str) -> str:
    try:
        rel = os.path.relpath(path, base)
        return rel.replace("\\", "/")
    except Exception:
        return os.path.basename(path)


def parse_listapp_to_map(output: str) -> dict:
    app_map = {}
    for name, uid in parse_listapp_output(output):
        app_map[uid.lower()] = name.strip()
    return app_map


def get_installed_apps_map() -> dict:
    ret, output = run_eka_capture(["--listapp"])
    if ret != 0 and not output.strip():
        return {}
    return parse_listapp_to_map(output)


def find_new_app_after_install(before_apps: dict, after_apps: dict) -> Optional[Tuple[str, str]]:
    new_uids = [uid for uid in after_apps if uid not in before_apps]
    if len(new_uids) == 1:
        uid = new_uids[0]
        return after_apps[uid], uid

    candidates = []
    for uid in new_uids:
        name = after_apps[uid]
        if not is_system_app(name):
            candidates.append((name, uid))

    if len(candidates) == 1:
        return candidates[0]

    if candidates:
        return candidates[0]

    return None


def find_graphic_in_same_folder(folder: str) -> Optional[str]:
    exts = (".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp")
    candidates = []

    try:
        for name in os.listdir(folder):
            full = os.path.join(folder, name)
            if os.path.isfile(full) and name.lower().endswith(exts):
                candidates.append(full)
    except Exception:
        return None

    if not candidates:
        return None

    return sorted(candidates, key=lambda p: os.path.basename(p).lower())[0]


def copy_matching_image_for_uid(source_folder: str, app_name: str, uid_output_dir: str) -> Optional[str]:
    image_src = find_graphic_in_same_folder(source_folder)
    if not image_src:
        return None

    os.makedirs(uid_output_dir, exist_ok=True)

    safe_name = sanitize_uid_name(app_name)
    ext = os.path.splitext(image_src)[1].lower()
    target_name = f"{safe_name}{ext}"
    target_path = os.path.join(uid_output_dir, target_name)

    try:
        shutil.copy2(image_src, target_path)
        log(f"Copied artwork: {image_src} -> {target_path}")
        return target_name
    except Exception as ex:
        log(f"Failed to copy artwork {image_src} -> {target_path}: {ex}")
        return None


def install_sis():
    try:
        sis_dir = choose_directory_interactive(
            "SIS/SISX: Select Directory", EKA_ROMS_DIR)
    except GoBack:
        return

    sis_files = find_sis_files_recursive(sis_dir)

    if not sis_files:
        ok_dialog("Error", f"No .sis or .sisx files found in:\n{sis_dir}")
        return

    image_out_dir = os.path.join(sis_dir, "media", "images")

    try:
        mode_idx = select_from_list(
            "SIS/SISX Installer Mode",
            [
                "Install all SIS/SISX files (recursive)",
                "Select SIS/SISX files individually (recursive)",
            ],
            f"{len(sis_files)} file(s) found recursively in:\n{sis_dir}"
        )
    except GoBack:
        return

    if mode_idx is None:
        return

    selected_files = []

    if mode_idx == 0:
        if not confirm_dialog(
            "Install All",
            f"Install all {len(sis_files)} SIS/SISX files recursively?\n\nDirectory:\n{sis_dir}"
        ):
            return
        selected_files = sis_files
    else:
        sis_options = [get_relative_path(f, sis_dir) for f in sis_files]

        try:
            selected_indexes = select_multiple_from_list(
                "Select SIS/SISX Files",
                sis_options,
                f"Directory:\n{sis_dir}\n\nToggle files with A, press Y to install."
            )
        except GoBack:
            return

        if not selected_indexes:
            ok_dialog("SIS/SISX Installer", "No SIS/SISX files selected.")
            return

        selected_files = [sis_files[i] for i in selected_indexes]

        if not confirm_dialog(
            "Install Selected",
            f"Install {len(selected_files)} selected SIS/SISX file(s)?"
        ):
            return

    success = 0
    fail = 0
    failed_files = []
    artwork_copied = 0
    artwork_failed = 0

    for pos, sis_file in enumerate(selected_files, start=1):
        rel_name = get_relative_path(sis_file, sis_dir)
        progress_screen(f"Installing {pos}/{len(selected_files)}", rel_name)

        before_apps = get_installed_apps_map()
        ret = run_eka(["--install", sis_file])
        after_apps = get_installed_apps_map()

        if eka_success(ret):
            success += 1
            log(f"SIS/SISX installed successfully: {sis_file}")

            new_app = find_new_app_after_install(before_apps, after_apps)
            if new_app:
                app_name, uid = new_app
                copied_name = copy_matching_image_for_uid(
                    os.path.dirname(sis_file),
                    app_name,
                    image_out_dir
                )
                if copied_name:
                    artwork_copied += 1
                    log(f"Matched artwork for app '{app_name}' ({uid}): {copied_name}")
                else:
                    artwork_failed += 1
                    log(f"No artwork copied for app '{app_name}' ({uid}) from folder {os.path.dirname(sis_file)}")
            else:
                artwork_failed += 1
                log(f"Could not determine new app UID/name after install: {sis_file}")
        else:
            fail += 1
            failed_files.append(rel_name)
            log(f"SIS/SISX install failed ({ret}): {sis_file}")

    if fail == 0:
        ok_dialog(
            "Done",
            f"Installation completed successfully.\n\n"
            f"Installed: {success}\n"
            f"Failed: {fail}\n"
            f"Artwork copied: {artwork_copied}\n"
            f"Artwork unresolved: {artwork_failed}\n\n"
            f"Artwork target:\n{image_out_dir}"
        )
    else:
        preview = "\n".join(failed_files[:8])
        more = ""
        if len(failed_files) > 8:
            more = f"\n... and {len(failed_files) - 8} more"

        ok_dialog(
            "Installation Result",
            f"Completed.\n\n"
            f"Installed: {success}\n"
            f"Failed: {fail}\n"
            f"Artwork copied: {artwork_copied}\n"
            f"Artwork unresolved: {artwork_failed}\n\n"
            f"Failed files:\n{preview}{more}\n\nSee log:\n{EKA_LOG}"
        )

# ---------------------------------------------------------------------------
# UID launcher creator
# ---------------------------------------------------------------------------
def parse_listapp_output(output: str) -> List[Tuple[str, str]]:
    apps: List[Tuple[str, str]] = []
    for raw_line in output.splitlines():
        line = raw_line.strip()
        match = re.match(r'^\d+\s*:\s*(.*?)\s*\(UID:\s*(0x[0-9a-fA-F]+)\)\s*$', line)
        if match:
            name = match.group(1).strip()
            uid = match.group(2).strip().lower()
            apps.append((name, uid))
    return apps


def sanitize_uid_name(name: str) -> str:
    name = re.sub(r'[\\/:*?"<>|]', '_', name)
    name = name.replace("'", "_")
    name = re.sub(r'\s+', ' ', name).strip()
    while name.startswith('.'):
        name = '_' + name[1:]
    if not name:
        name = 'unnamed'
    return name


def is_system_app(name: str) -> bool:
    name_lc = name.lower().strip()
    system_names = {
        '', 'installer', 'applications', 'help', 'screensaver', 'telephone', 'app. manager',
        'messaging', 'recorder', 'multimedia', 'settings', 'call divert', 'sysap', 'startup',
        'voice mailbox', 'profiles', 'to-do', 'calendar', 'calculator', 'clock', 'notes',
        'speed dial', 'favourites', 'bluetooth', 'ussd', 'composer', 'fixed dialling',
        'autolock', 'save certificate', 'info message', 'bounce', 'about product',
        'services', 'pushviewer', 'download', 'realone player', 'screen shot',
        'memory card', 'converter', 'videoui', 'contacts', 'images', 'menu',
        'cell broadcast', 'log', 'e-mail', 'sim services', 'service nos.',
        'sim directory', 'radio', 'music player', 'unlockmmc'
    }
    return name_lc in system_names


def build_uid_candidates(apps: List[Tuple[str, str]]) -> Tuple[List[Tuple[str, str]], int, int, int]:
    candidates: List[Tuple[str, str]] = []
    seen_uids = set()
    skipped_system = 0
    skipped_blank = 0
    skipped_dup = 0

    for name, uid in apps:
        name = name.strip()
        uid = uid.strip().lower()

        if not name:
            skipped_blank += 1
            continue
        if uid in seen_uids:
            skipped_dup += 1
            continue
        if is_system_app(name):
            seen_uids.add(uid)
            skipped_system += 1
            continue

        seen_uids.add(uid)
        candidates.append((name, uid))

    return candidates, skipped_system, skipped_blank, skipped_dup


def show_available_uid_apps(candidates: List[Tuple[str, str]]) -> None:
    if not candidates:
        ok_dialog('Available Apps', 'No launchable non-system apps found.')
        return

    options = [f'{name} ({uid})' for name, uid in candidates]
    try:
        select_from_list(
            'Available Apps',
            options,
            f'Available launchable apps: {len(candidates)}\n\nPress A to continue or B to go back.'
        )
    except GoBack:
        raise
    except UserQuit:
        raise


def show_generated_uid_list(created_entries: List[Tuple[str, str, str]], out_dir: str) -> None:
    if not created_entries:
        ok_dialog('Generated UID Files', f'No UID files were created.\n\nOutput: {out_dir}')
        return

    options = [f"{name} -> {uid} [{filename}]" for name, uid, filename in created_entries]
    try:
        select_from_list(
            'Generated UID Files',
            options,
            f'Output: {out_dir}\nCreated: {len(created_entries)}\n\nPress A or B to return.'
        )
    except (GoBack, UserQuit):
        pass


def write_uid_files(selected_apps: List[Tuple[str, str]], out_dir: str) -> List[Tuple[str, str, str]]:
    created_entries: List[Tuple[str, str, str]] = []
    os.makedirs(out_dir, exist_ok=True)

    for name, uid in selected_apps:
        safe_name = sanitize_uid_name(name)
        target = os.path.join(out_dir, f'{safe_name}.uid')
        if os.path.exists(target):
            target = os.path.join(out_dir, f'{safe_name}_{uid}.uid')

        try:
            with open(target, 'w', encoding='utf-8') as f:
                f.write(uid + '\n')
            log(f'Created UID launcher: {target} -> {uid}')
            created_entries.append((name, uid, os.path.basename(target)))
        except Exception as ex:
            log(f'Failed to create UID launcher {target}: {ex}')

    return created_entries


def xml_escape(text: str) -> str:
    return (text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace('"', "&quot;")
                .replace("'", "&apos;"))


def create_uid_gamelist():
    try:
        uid_dir = choose_directory_interactive(
            "Gamelist: Select UID Directory", EKA_ROMS_DIR)
    except GoBack:
        return

    uid_files = sorted(glob.glob(os.path.join(uid_dir, "*.uid")) +
                       glob.glob(os.path.join(uid_dir, "*.UID")))

    if not uid_files:
        ok_dialog("Error", f"No .uid files found in:\n{uid_dir}")
        return

    out_file = os.path.join(uid_dir, "gamelist.xml")
    image_dir = os.path.join(uid_dir, "media", "images")

    if os.path.exists(out_file):
        if not confirm_dialog(
            "Overwrite?",
            f"gamelist.xml already exists in:\n{uid_dir}\n\nOverwrite it?"
        ):
            return

    lines = ['<?xml version="1.0"?>', '<gameList>']

    for uid_file in uid_files:
        base = os.path.basename(uid_file)
        name = os.path.splitext(base)[0]

        image_tag = "./media/images/ngage.png"
        for ext in (".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp"):
            candidate = os.path.join(image_dir, name + ext)
            if os.path.exists(candidate):
                image_tag = f"./media/images/{xml_escape(name + ext)}"
                break

        lines.append('\t<game>')
        lines.append(f'\t\t<path>./{xml_escape(base)}</path>')
        lines.append(f'\t\t<name>{xml_escape(name)}</name>')
        lines.append(f'\t\t<desc>{xml_escape(name)}</desc>')
        lines.append(f'\t\t<image>{image_tag}</image>')
        lines.append('\t\t<video>./media/videos/ngage.mp4</video>')
        lines.append('\t</game>')

    lines.append('</gameList>')

    try:
        with open(out_file, "w", encoding="utf-8", newline="\n") as f:
            f.write("\n".join(lines) + "\n")
    except Exception as ex:
        log(f"Failed to write gamelist.xml {out_file}: {ex}")
        ok_dialog("Error", f"Failed to write gamelist.xml:\n{ex}")
        return

    ok_dialog(
        "Done",
        f"gamelist.xml created successfully.\n\n"
        f"UID files: {len(uid_files)}\n"
        f"Output:\n{out_file}"
    )


def create_uid_launchers():
    try:
        out_dir = choose_directory_interactive(
            'UID Creator: Select Output Directory', '/storage/roms')
    except GoBack:
        return

    progress_screen("Loading App List", "Querying eka2l1...")

    ret, output = run_eka_capture(['--listapp'])
    apps = parse_listapp_output(output)

    if ret != 0 and not apps:
        ok_dialog('Error', f'Could not get app list.\n\nSee log: {EKA_LOG}')
        return

    if not apps:
        ok_dialog('Error', 'No installed apps found.')
        return

    candidates, skipped_system, skipped_blank, skipped_dup = build_uid_candidates(apps)
    candidates = sorted(candidates, key=lambda item: (item[0].lower(), item[1]))

    if not candidates:
        ok_dialog('Error', 'No launchable non-system apps found.')
        return

    try:
        show_available_uid_apps(candidates)
        mode_idx = select_from_list(
            'UID Creator Mode',
            ['Create all UID launcher files', 'Select apps individually'],
            f'Output: {out_dir}\n\nAvailable apps: {len(candidates)}'
        )
    except GoBack:
        return

    if mode_idx is None:
        return

    selected_apps: List[Tuple[str, str]] = []

    if mode_idx == 0:
        if not confirm_dialog(
            'Create All UID Files',
            f'Create {len(candidates)} UID launcher files in:\n\n{out_dir}'
        ):
            return
        selected_apps = candidates
    else:
        app_options = [f'{name} ({uid})' for name, uid in candidates]
        try:
            selected_indexes = select_multiple_from_list(
                'Select Apps For UID',
                app_options,
                f'Output: {out_dir}\n\nToggle apps with A, then press Y to create.'
            )
        except GoBack:
            return

        if not selected_indexes:
            ok_dialog('UID Creator', 'No apps selected.')
            return

        selected_apps = [candidates[i] for i in selected_indexes]

        if not confirm_dialog(
            'Create Selected UID Files',
            f'Create {len(selected_apps)} selected UID launcher files in:\n\n{out_dir}'
        ):
            return

    created_entries = write_uid_files(selected_apps, out_dir)

    ok_dialog(
        'Done',
        f'UID launcher creation finished.\n\n'
        f'Output: {out_dir}\n\n'
        f'Requested: {len(selected_apps)}\n'
        f'Created: {len(created_entries)}\n'
        f'Skipped system apps: {skipped_system}\n'
        f'Skipped blank names: {skipped_blank}\n'
        f'Skipped duplicate UIDs: {skipped_dup}'
    )

    show_generated_uid_list(created_entries, out_dir)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
DEFAULT_CONFIG_YML = """bkg-path: ""
font: ""
log-read: false
log-write: false
log-ipc: false
log-svc: false
log-passed: false
log-exports: false
cpu: dynarmic
device: 0
language: 1
emulator-language: -1
enable-gdb-stub: false
data-storage: data
gdb-port: 24689
internet-bluetooth-port: 35689
enable-srv-rights: true
enable-srv-sa: true
enable-srv-drm: true
fbs-enable-compression-queue: false
enable-btrace: false
stop-warn-touchscreen-disabled: false
dump-imb-range-code: false
hide-mouse-in-screen-space: false
enable-nearest-neighbor-filter: true
integer-scaling: true
cpu-load-save: true
mime-detection: true
rtos-level: ""
ui-new-style: true
svg-icon-cache-reset: true
imei: 540806859904945
mmc-id: 00000000-00000000-00000000-00000000
audio-master-volume: 100
current-keybind-profile: default
screen-buffer-sync: preferred
report-mmfdev-underflow: false
disable-display-content-scale: false
device-display-name: EKA2L1
midi-backend: tsf
hsb-bank-path: resources/defaultbank.hsb
sf2-bank-path: resources/defaultbank.sf2
bt-central-server-url: btnetplay.12z1.com
background-image: ""
background-image-opacity: 255
enable-hw-gles1: true
log-filter: "*:trace"
hide-system-apps: true
btnet-port-offset: 15000
btnet-password: ""
btnet-discovery-mode: 0
enable-upnp: true
extensive-logging: false
internet-bluetooth-friends:
  []
"""


def _create_default_config():
    cfg_path = os.path.join(EKA_CONFIG, "config.yml")
    if not os.path.exists(cfg_path):
        try:
            with open(cfg_path, "w") as f:
                f.write(DEFAULT_CONFIG_YML)
            log("Created default config.yml")
            return True
        except Exception as ex:
            log(f"Failed to create config.yml: {ex}")
    return False


def _seed_bundled_files():
    install_dir = "/usr/bin/eka2l1"
    if not os.path.isdir(install_dir):
        ok_dialog("Error", f"eka2l1 install directory not found:\n{install_dir}")
        return

    progress_screen("Setup", "Seeding bundled data...")
    seeded = []

    for item in os.listdir(install_dir):
        src = os.path.join(install_dir, item)
        dst = os.path.join(EKA_CONFIG, item)
        if not os.path.exists(dst):
            try:
                if os.path.isdir(src):
                    shutil.copytree(src, dst)
                else:
                    shutil.copy2(src, dst)
                seeded.append(item)
                log(f"Seeded: {item}")
                log(f"Seeded: {item}")
            except Exception as ex:
                log(f"Seed failed for {item}: {ex}")

    cfg_created = _create_default_config()
    if cfg_created:
        seeded.append("config.yml (default)")
        log("Seeded: config.yml (default)")

    if seeded:
        ok_dialog("Seed Bundled Files", f"Done!\n\nCopied {len(seeded)} item(s) into:\n{EKA_CONFIG}\n\nYou can now install firmware and games.")
    else:
        ok_dialog("Seed Bundled Files", "Nothing to seed - all files already present.")


def _autoset_device_from_zdrive():
    devices_yml = os.path.join(EKA_CONFIG, "data", "devices.yml")
    z_drives_dir = os.path.join(EKA_CONFIG, "data", "drives", "z")
    cfg_path = os.path.join(EKA_CONFIG, "config.yml")

    if not os.path.isfile(devices_yml) or not os.path.isdir(z_drives_dir):
        return

    device_keys = []
    try:
        with open(devices_yml, "r") as f:
            for line in f:
                stripped = line.rstrip()
                if stripped and not stripped.startswith(" ") and stripped.endswith(":"):
                    device_keys.append(stripped[:-1])
    except Exception as ex:
        log(f"_autoset_device_from_zdrive: could not read devices.yml: {ex}")
        return

    available_z = {
        d.lower(): d for d in os.listdir(z_drives_dir)
        if os.path.isdir(os.path.join(z_drives_dir, d))
    }

    match_index = None
    for i, key in enumerate(device_keys):
        if key.lower() in available_z:
            match_index = i
            log(f"_autoset_device_from_zdrive: matched device {key} at index {i}")
            break

    if match_index is None:
        log("_autoset_device_from_zdrive: no matching Z-drive found")
        return

    if not os.path.isfile(cfg_path):
        _create_default_config()

    try:
        with open(cfg_path, "r") as f:
            lines = f.readlines()

        new_lines = []
        for line in lines:
            if line.startswith("device:"):
                new_lines.append(f"device: {match_index}\n")
            else:
                new_lines.append(line)

        with open(cfg_path, "w") as f:
            f.writelines(new_lines)

        log(f"_autoset_device_from_zdrive: set device: {match_index}")
    except Exception as ex:
        log(f"_autoset_device_from_zdrive: failed to update config.yml: {ex}")


def _import_preconfigured():
    try:
        src_dir = choose_directory_interactive(
            "Select source directory (must contain a 'data' folder)",
            "/storage/roms/bios/eka2l1"
        )
    except GoBack:
        return

    data_src = os.path.join(src_dir, "data")
    if not os.path.isdir(data_src):
        ok_dialog("Error", f"No 'data' folder found in:\n{src_dir}\n\nPlease select a directory that contains a pre-configured eka2l1 'data' folder.")
        return

    data_dst = os.path.join(EKA_CONFIG, "data")
    os.makedirs(data_dst, exist_ok=True)

    progress_screen("Importing Data", f"From: {data_src}\n\nOnly adding new files.")
    log(f"Importing pre-configured data from: {data_src}")

    added = 0
    skipped = 0

    for root, dirs, files in os.walk(data_src):
        rel = os.path.relpath(root, data_src)
        dst_root = os.path.join(data_dst, rel) if rel != "." else data_dst
        os.makedirs(dst_root, exist_ok=True)

        for fname in files:
            src_file = os.path.join(root, fname)
            dst_file = os.path.join(dst_root, fname)

            if fname == "devices.yml" and os.path.exists(dst_file):
                backup = dst_file + ".bak"
                try:
                    shutil.copy2(dst_file, backup)
                    shutil.copy2(src_file, dst_file)
                    log(f"Overwritten with backup: {dst_file}")
                    added += 1
                except Exception as ex:
                    log(f"Failed to overwrite devices.yml: {ex}")
                    skipped += 1
                continue

            if not os.path.exists(dst_file):
                try:
                    shutil.copy2(src_file, dst_file)
                    log(f"Added: {dst_file}")
                    added += 1
                except Exception as ex:
                    log(f"Failed to copy {src_file}: {ex}")
                    skipped += 1
            else:
                skipped += 1

    _autoset_device_from_zdrive()

    ok_dialog("Import Complete",
              f"Import finished!\n\n"
              f"Added: {added} file(s)\n"
              f"Skipped (already exist): {skipped} file(s)\n\n"
              f"devices.yml overwritten (backup: devices.yml.bak)\n"
              f"Device index auto-set to match available firmware.")


def first_run_setup():
    _seed_bundled_files()


def main():
    preferred = sys.argv[1] if len(sys.argv) > 1 else None
    init_controller(preferred)

    os.makedirs(EKA_CONFIG, exist_ok=True)

    try:
        with open(EKA_LOG, "w") as f:
            f.write("EmuELEC eka2l1 Commander Log\n")
    except Exception:
        pass

    fb_open()
    unblank_framebuffer()
    fb_fill(COL_BG)
    fb_flip()

    try:
        while True:
            try:
                idx = select_from_list(
                    "Main Menu",
                    [
                        "[ RUN THIS FIRST ! ] : Setup eka2l1 (copy needed files to EmuELEC)",
                        "Import pre-configured devices-collection",
                        "Install firmware (.rpkg + .rom)",
                        "Install games and apps (.sis/.sisx)",
                        "Create UID launcher-files from installed games and apps (.uid)",
                        "Create gamelist.xml from .uid launcher-files",
                        "Show / change current device",
                        "Convert uppercase device paths and files to lowercase",
                        "Exit",
                    ],
                    "What would you like to do?"
                )

                if idx is None or idx == 8:
                    break
                if idx == 0:
                    try:
                        first_run_setup()
                    except GoBack:
                        continue
                elif idx == 1:
                    try:
                        _import_preconfigured()
                    except GoBack:
                        continue
                elif idx == 2:
                    try:
                        install_firmware()
                    except GoBack:
                        continue
                elif idx == 3:
                    try:
                        install_sis()
                    except GoBack:
                        continue
                elif idx == 4:
                    try:
                        create_uid_launchers()
                    except GoBack:
                        continue
                elif idx == 5:
                    try:
                        create_uid_gamelist()
                    except GoBack:
                        continue
                elif idx == 6:
                    try:
                        change_device()
                    except GoBack:
                        continue
                elif idx == 7:
                    try:
                        convert_device_paths_to_lowercase()
                    except GoBack:
                        continue
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