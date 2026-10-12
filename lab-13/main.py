#!/usr/bin/env python3
"""Visible ten-second pynput lab, restricted to its isolated Linux X11 display."""
import json
import os
from pathlib import Path
import urllib.request

if not Path('/.dockerenv').exists() or os.environ.get('DISPLAY') != ':99':
    raise SystemExit('Run only in the lab Docker container with DISPLAY=:99.')

from pynput.keyboard import Key, Listener

LOG = Path('/tmp/lab13/log.txt')
LOG.parent.mkdir(parents=True, exist_ok=True)
saved_keys = []


def write_to_file():
    if not saved_keys:
        return
    word = ''.join(saved_keys)
    saved_keys.clear()
    with LOG.open('a') as file:
        file.write(word + '\n')
    request = urllib.request.Request(
        'http://127.0.0.1:8130/logs',
        data=json.dumps({'word': word}).encode(),
        headers={'Content-Type': 'application/json'},
    )
    with urllib.request.urlopen(request, timeout=2) as response:
        if response.status != 201:
            raise RuntimeError('Local API did not save the word.')
    print(f'SAVED locally and at loopback API: {word}', flush=True)


def on_key_press(key):
    print(f'Key Pressed: {key}', flush=True)


def on_key_release(key):
    if key == Key.esc:
        write_to_file()
        return False
    if key in (Key.space, Key.enter):
        write_to_file()
    elif getattr(key, 'char', None) is not None:
        saved_keys.append(key.char)


if __name__ == '__main__':
    with Listener(on_press=on_key_press, on_release=on_key_release) as listener:
        print('ACTIVE: educational X11 listener, isolated display, maximum 10 seconds.', flush=True)
        listener.join(timeout=10)
        listener.stop()
        # X11's record worker can wait for another event during shutdown.
        # It is a daemon thread; never let cleanup block process termination.
        listener.join(timeout=1)
    write_to_file()
    print('STOPPED: listener ended.', flush=True)
