import librespot


class Librespot(librespot.Librespot):

    def __init__(self, alsa_device='hw:2,0', **kwargs):
        super().__init__(**kwargs)
        self.command += [
            '--backend', 'alsa',
            '--device', f'{alsa_device}',
        ]
