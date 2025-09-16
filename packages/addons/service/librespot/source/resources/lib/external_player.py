import player
import service


class Player(player.Player):

    def onLibrespotTrackChanged(self, art, artist, title, **kwargs):
        service.notification(heading=title, message=artist, icon=art)
