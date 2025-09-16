import threading
import xbmc

import onevent
import service


class Player(xbmc.Player):

    def __init__(self, dnd_kodi='false', librespot=None, **kwargs):
        super().__init__()
        self._dnd_kodi = (dnd_kodi == 'true')
        self._thread = threading.Thread(daemon=True, target=self._run)
        self._thread.start()
        self.last_file = None
        self.librespot = librespot
        if not (self._dnd_kodi and self.isPlaying()):
            self.librespot.start()

    def onAVStarted(self):
        file = self.getPlayingFile()
        if file != self.librespot.file:
            if self._dnd_kodi:
                self.librespot.stop()
            elif self.last_file == self.librespot.file:
                self.librespot.restart()
        self.last_file = file

    def onLibrespotStopped(self):
        pass

    def onLibrespotTrackChanged(self, album='', art='', artist='', title=''):
        pass

    def onPlayBackEnded(self):
        if self.last_file == self.librespot.file:
            self.librespot.restart()
        else:
            self.librespot.start()
        self.last_file = None

    def onPlayBackError(self):
        self.onPlayBackEnded()

    def onPlayBackStopped(self):
        self.onPlayBackEnded()

    # fixes unexpected behaviour of Player.stop()
    def stop(self):
        xbmc.executebuiltin('PlayerControl(Stop)')

    def _run(self):
        service.log('onevent dispatcher started')
        for event in onevent.receive_event():
            try:
                player_event = event.pop(onevent.KEY_PLAYER_EVENT)
                if player_event == onevent.PLAYER_EVENT_STOPPED:
                    self.onLibrespotStopped()
                elif player_event == onevent.PLAYER_EVENT_TRACK_CHANGED:
                    self.onLibrespotTrackChanged(**event)
            except Exception as e:
                service.log(e, True)
        service.log('onevent dispatcher stopped')

    def __enter__(self):
        return self

    def __exit__(self, *args):
        onevent.send_event({})
        self._thread.join()
        self.onLibrespotStopped()
