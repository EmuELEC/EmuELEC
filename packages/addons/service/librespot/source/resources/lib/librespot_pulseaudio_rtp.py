import socket
import subprocess

import librespot
import service


class Librespot(librespot.Librespot):

    def __init__(self,
                 codec='pcm_sb16be',
                 pa_rtp_address='127.0.0.1',
                 pa_rtp_device='librespot',
                 pa_rtp_port='24642',
                 **kwargs):
        service.log('pulseaudio backend started')
        sap_cmd = f'nc -l -u -s {pa_rtp_address} -p 9875'.split()
        self._sap_server = subprocess.Popen(sap_cmd,
                                            stdout=subprocess.DEVNULL,
                                            stderr=subprocess.STDOUT)
        service.log(f'sap server started')
        if not pa_rtp_port:
            with socket.socket() as s:
                s.bind((pa_rtp_address, 0))
                pa_rtp_port = s.getsockname()[1]
        modules = [
            [
                f'module-null-sink',
                f'sink_name={pa_rtp_device}',
            ],
            [
                f'module-rtp-send',
                f'destination_ip={pa_rtp_address}',
                f'inhibit_auto_suspend=always',
                f'port={pa_rtp_port}',
                f'source={pa_rtp_device}.monitor',
            ],
        ]
        self._modules = [self._pactl('load-module', *m) for m in modules]
        self._sink_name = f'{pa_rtp_device}'
        self.stop_sink()
        service.log(f'pulseaudio modules loaded: {self._modules}')
        super().__init__(**kwargs)
        self.command += [
            '--backend', 'pulseaudio',
            '--device', f'{pa_rtp_device}',
        ]
        self.file = f'rtp://{pa_rtp_address}:{pa_rtp_port}'

    def start_sink(self):
        self._pactl('suspend-sink', self._sink_name, '0')

    def stop_sink(self):
        self._pactl('suspend-sink', self._sink_name, '1')

    def _pactl(self, command, *args):
        out = subprocess.run(['pactl', command, *args],
                             stdout=subprocess.PIPE,
                             text=True
                             ).stdout.rstrip()
        service.log(f'pactl {command} {args}: {out}')
        return out

    def __exit__(self, *args):
        super().__exit__(*args)
        for module in reversed(self._modules):
            if module:
                self._pactl('unload-module', module)
        service.log('pulseaudio backend stopped')
        if self._sap_server.poll() is None:
            self._sap_server.terminate()
            self._sap_server.wait()
        service.log('sap server stopped')
