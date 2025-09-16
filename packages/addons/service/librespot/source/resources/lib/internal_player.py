import xbmc
import xbmcgui

import player
import service


class Player(player.Player):

    def __init__(self, codec='pcm_sb16be', max_fanarts='10', **kwargs):
        super().__init__(**kwargs)
        self._max_fanarts = int(max_fanarts)
        self._list_item = xbmcgui.ListItem(path=self.librespot.file)
        self._list_item.getVideoInfoTag().addAudioStream(xbmc.AudioStreamDetail(2, codec))
        self._music_info_tag = self._list_item.getMusicInfoTag()

    def onLibrespotTrackChanged(self, album='', art='', artist='', title=''):
        fanart = service.get_fanart(art, self._max_fanarts) if art else art
        self._list_item.setArt({'fanart': fanart, 'thumb': art})
        self._music_info_tag.setAlbum(album)
        self._music_info_tag.setArtist(artist)
        self._music_info_tag.setTitle(title)
        if self.isPlaying() and self.getPlayingFile() == self.librespot.file:
            self.updateInfoTag(self._list_item)
        else:
            self.stop()  # fixes unepxected behaviour of Player.play()
            self.librespot.start_sink()
            self.play(self.librespot.file, listitem=self._list_item)

    def onLibrespotStopped(self):
        self.librespot.stop_sink()
        if self.isPlaying() and self.getPlayingFile() == self.librespot.file:
            self.last_file = None
            self.stop()
