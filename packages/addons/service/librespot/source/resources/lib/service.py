import PIL.Image
import urllib.request
import tempfile
import os
import xbmc
import xbmcaddon
import xbmcgui

_ADDON = xbmcaddon.Addon()
_ICON = _ADDON.getAddonInfo('icon')
_NAME = _ADDON.getAddonInfo('name')
_DIALOG = xbmcgui.Dialog()


def log(message, show=False):
    xbmc.log(f'{_NAME}: {message}', xbmc.LOGINFO if show else xbmc.LOGDEBUG)


def notification(message='', sound=False, heading=_NAME, icon=_ICON, time=5000):
    _DIALOG.notification(heading, message, icon, time, sound)


_FANART_DIR = os.path.join(tempfile.gettempdir(), 'librespot.fanart')


def get_fanart(url, max_fanarts):
    name = os.path.basename(url)
    target = os.path.join(_FANART_DIR, f'{name}_16x9')
    if not os.path.exists(target):
        if not os.path.exists(_FANART_DIR):
            os.makedirs(_FANART_DIR)
        files = os.listdir(_FANART_DIR)
        files = [os.path.join(_FANART_DIR, file) for file in files if os.path.isfile(
            os.path.join(_FANART_DIR, file))]
        files.sort(key=os.path.getmtime)
        for file in files[:-max_fanarts]:
            os.remove(file)
        source = os.path.join(_FANART_DIR, f'{name}_9x9')
        urllib.request.urlretrieve(url, source)
        image = PIL.Image.open(source)
        width, height = image.size
        new_width = int(height * 16 / 9)
        delta_w = new_width - width
        new_image = PIL.Image.new('RGB', (new_width, height), (0, 0, 0))
        new_image.paste(image, (delta_w // 2, 0))
        new_image.save(target, 'JPEG', optimize=True)
        os.remove(source)
    return target


_SETTINGS = {
    'alsa_device': 'hw:2,0',
    'backend': 'pulseaudio_rtp',
    'dnd_kodi': 'false',
    'name': f'{_NAME}@{{}}',
    'options': '',
}


def _get_setting(setting, default):
    value = _ADDON.getSetting(setting)
    return value if value else default


def _get_librespot():
    while True:
        settings = {k: _get_setting(k, v) for k, v in _SETTINGS.items()}
        backend = settings.pop('backend')
        librespot_class = __import__(f'librespot_{backend}').Librespot
        with librespot_class(**settings) as librespot:
            with librespot.get_player(librespot=librespot, **settings) as player:
                yield


class Monitor(xbmc.Monitor):

    def __init__(self):
        self._get_librespot = _get_librespot()
        self.onSettingsChanged()

    def onSettingsChanged(self):
        log('settings changed')
        next(self._get_librespot)

    def run(self):
        self.waitForAbort()
        log('abort requested')
        self._get_librespot.close()
