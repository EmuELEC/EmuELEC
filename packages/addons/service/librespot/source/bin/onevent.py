#!/usr/bin/python
import json
import os
import socket

ADDRESS = ('127.0.0.1', 36963)
BUFFER_SIZE = 1024


def send_event(event):
    data = json.dumps(event).encode()
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.sendto(data, ADDRESS)


def receive_event():
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.settimeout(None)
        sock.bind(ADDRESS)
        while True:
            data, addr = sock.recvfrom(BUFFER_SIZE)
            event = json.loads(data.decode())
            if not event:
                break
            yield event


ARG_ALBUM = 'album'
ARG_ARTIST = 'artist'
ARG_ART = 'art'
ARG_TITLE = 'title'

KEY_ALBUM = 'ALBUM'
KEY_ARTISTS = 'ARTISTS'
KEY_COVERS = 'COVERS'
KEY_ITEM_TYPE = 'ITEM_TYPE'
KEY_NAME = 'NAME'
KEY_PLAYER_EVENT = 'PLAYER_EVENT'
KEY_SHOW_NAME = 'SHOW_NAME'

PLAYER_EVENT_STOPPED = 'stopped'
PLAYER_EVENT_TRACK_CHANGED = 'track_changed'

ITEM_TYPE_EPISODE = 'Episode'
ITEM_TYPE_TRACK = 'Track'


def get_env_value(key):
    return os.environ.get(key, '').partition('\n')[0]


if __name__ == '__main__':
    player_event = get_env_value(KEY_PLAYER_EVENT)
    event = {KEY_PLAYER_EVENT: player_event}
    if player_event == PLAYER_EVENT_STOPPED:
        send_event(event)
    elif player_event == PLAYER_EVENT_TRACK_CHANGED:
        event[ARG_ART] = get_env_value(KEY_COVERS)
        event[ARG_TITLE] = get_env_value(KEY_NAME)
        item_type = get_env_value(KEY_ITEM_TYPE)
        if item_type == ITEM_TYPE_EPISODE:
            event[ARG_ALBUM] = get_env_value(KEY_SHOW_NAME)
        elif item_type == ITEM_TYPE_TRACK:
            event[ARG_ALBUM] = get_env_value(KEY_ALBUM)
            event[ARG_ARTIST] = get_env_value(KEY_ARTISTS)
        send_event(event)
