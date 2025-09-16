import os
import sys
import xbmcaddon
import xbmcvfs


def _set_home():
    home = xbmcvfs.translatePath(xbmcaddon.Addon().getAddonInfo('profile'))
    os.makedirs(home, exist_ok=True)
    os.chdir(home)


def _set_paths():
    path = xbmcaddon.Addon().getAddonInfo('path')
    os.environ['PATH'] += os.pathsep + os.path.join(path, 'bin')
    os.environ['LD_LIBRARY_PATH'] += os.pathsep + os.path.join(path, 'lib')
    sys.path.append(os.path.join(path, 'bin'))
    sys.path.append(os.path.join(path, 'resources', 'lib'))


if __name__ == '__main__':
    _set_home()
    _set_paths()
    import service
    service.Monitor().run()
