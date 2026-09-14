"""Verify the installed bottle without requiring Xcode's Homebrew test harness."""
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import tempfile
import time
import urllib.error
import urllib.request

binary = shutil.which('rust-playout')
assert binary, 'Install rust-playout first'
assert subprocess.check_output([binary, '--version']).decode().strip() == 'rust-playout 0.0.1-alpha'
with tempfile.TemporaryDirectory() as folder:
    with socket.socket() as sock:
        sock.bind(('127.0.0.1', 0))
        port = sock.getsockname()[1]
    with open(Path(folder) / 'server.log', 'w') as log:
        process = subprocess.Popen([binary, '--demo'], cwd=folder,
                                   env=dict(os.environ, PLAYOUT_PORT=str(port), PLAYOUT_DATA=folder),
                                   stdout=log, stderr=log)
        try:
            base = f'http://127.0.0.1:{port}'
            for _ in range(160):
                assert process.poll() is None, 'Installed executable exited'
                try:
                    state = json.load(urllib.request.urlopen(base + '/api/state', timeout=2))
                    if state['status'] == 'live' and state['program_ms'] > 2500:
                        break
                except urllib.error.URLError:
                    pass
                time.sleep(.1)
            else:
                raise AssertionError('HLS startup timed out')
            assert len(state['assets']) == 3
            assert b'root' in urllib.request.urlopen(base + '/').read()
            media = state['output_url'].replace('master.m3u8', 'media.m3u8')
            assert b'#EXTINF' in urllib.request.urlopen(base + media).read()
            urllib.request.urlopen(urllib.request.Request(base + '/api/channel/stop', method='POST')).read()
            time.sleep(.5)
            assert json.load(urllib.request.urlopen(base + '/api/state'))['status'] == 'stopped'
            print('PASS: Homebrew-installed binary, embedded UI, demo generation, HLS and channel stop')
        finally:
            process.send_signal(signal.SIGINT)
            process.wait(timeout=8)
            assert process.returncode == 0
