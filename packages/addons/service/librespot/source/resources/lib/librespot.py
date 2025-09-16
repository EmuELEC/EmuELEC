import shlex
import socket
import subprocess
import threading

import external_player
import internal_player
import service


class Librespot:

    def __init__(self,
                 bitrate='320',
                 device_type='tv',
                 max_retries='5',
                 name='Librespot@{}',
                 options='',
                 **kwargs):
        name = name.format(socket.gethostname())
        self.command = [
            'librespot',
            '--bitrate', f'{bitrate}',
            '--device-type', f'{device_type}',
            '--disable-audio-cache',
            '--disable-credential-cache',
            '--name', f'{name}',
            '--onevent', 'onevent.py',
            '--quiet',
        ] + shlex.split(options)
        service.log(self.command)
        self.file = ''
        self._is_started = threading.Event()
        self._is_stopped = threading.Event()
        self._librespot = None
        self._max_retries = int(max_retries)
        self._retries = 0
        self._thread = threading.Thread()

    def get_player(self, **kwargs):
        return (internal_player if self.file else external_player).Player(**kwargs)

    def restart(self):
        if self._thread.is_alive():
            self._librespot.terminate()
        else:
            self.start()

    def start(self):
        if not self._thread.is_alive() and self._retries < self._max_retries:
            self._thread = threading.Thread(daemon=True, target=self._run)
            self._thread.start()
            self._is_started.wait(1)

    def stop(self):
        if self._thread.is_alive():
            self._is_stopped.set()
            self._librespot.terminate()
            self._thread.join()

    def start_sink(self):
        pass

    def stop_sink(self):
        pass

    def _run(self):
        service.log('librespot thread started')
        self._is_started.clear()
        self._is_stopped.clear()
        while not self._is_stopped.is_set():
            with subprocess.Popen(self.command, stderr=subprocess.PIPE, text=True) as self._librespot:
                self._is_started.set()
                for line in self._librespot.stderr:
                    service.log(line.rstrip())
            self.stop_sink()
            if self._librespot.returncode <= 0:
                self._retries = 0
            else:
                self._retries += 1
                if self._retries < self._max_retries:
                    service.notification(
                        f'librespot failed {self._retries}/{self._max_retries}')
                else:
                    service.notification('librespot failed too many times')
                    break
        service.log('librespot thread stopped')

    def __enter__(self):
        subprocess.Popen('[ -f /proc/sys/abi/cp15_barrier ] && echo 2 >/proc/sys/abi/cp15_barrier', shell=True)
        return self

    def __exit__(self, *args):
        self.stop()
