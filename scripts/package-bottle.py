"""Package the verified upstream binary as a fixed-prefix Homebrew bottle."""
import hashlib
import re
import json
import shutil
import subprocess
import tarfile
import time
from pathlib import Path

root = Path(__file__).resolve().parents[1]
version = '0.0.1-alpha'
archive = root / f'../rust-playout/target/packages/rust-playout-{version}-macos-arm64.tar.gz'
expected = re.search(r'sha256 "([a-f0-9]{64})"', (root / 'Formula/rust-playout.rb').read_text()).group(1)
assert hashlib.sha256(archive.read_bytes()).hexdigest() == expected, 'Upstream archive checksum mismatch'
stage = root / 'target/bottle' 
stage.mkdir(parents=True, exist_ok=True)
keg = stage / f'rust-playout/{version}'
(keg / 'bin').mkdir(parents=True, exist_ok=True)
(keg / '.brew').mkdir(exist_ok=True)
with tarfile.open(archive) as source:
    for entry in source.getmembers():
        if entry.isfile():
            name = Path(entry.name).name
            destination = keg / ('bin/rust-playout' if name == 'rust-playout' else name)
            destination.write_bytes(source.extractfile(entry).read())
(keg / 'bin/rust-playout').chmod(0o755)
shutil.copy(root / 'Formula/rust-playout.rb', keg / '.brew/rust-playout.rb')
ffmpeg = json.loads(subprocess.check_output(['brew', 'info', '--json=v2', 'ffmpeg']))['formulae'][0]
installed = ffmpeg['installed'][0]
receipt = {
    'homebrew_version': subprocess.check_output(['brew', '--version']).decode().split()[1],
    'used_options': [], 'unused_options': [], 'built_as_bottle': True,
    'poured_from_bottle': False, 'installed_on_request': True, 'installed_as_dependency': False,
    'loaded_from_api': False, 'time': int(time.time()), 'source_modified_time': int(time.time()),
    'compiler': 'clang', 'arch': 'arm64',
    'runtime_dependencies': [{'full_name': 'ffmpeg', 'version': ffmpeg['versions']['stable'],
                              'revision': ffmpeg['revision'], 'pkg_version': installed['version'],
                              'declared_directly': True}],
    'source': {'path': str(root / 'Formula/rust-playout.rb'), 'tap': 'thinkelution/tap',
               'spec': 'stable', 'versions': {'stable': version, 'version_scheme': 0}},
    'built_on': {'os': 'Macintosh', 'os_version': 'macOS 26.5.1', 'cpu_family': 'arm',
                 'xcode': None, 'clt': '26.3.0.0.1.1771626560'},
}
(keg / 'INSTALL_RECEIPT.json').write_text(json.dumps(receipt, indent=2)+'\n')
output = root / f'target/rust-playout-{version}.arm64_tahoe.bottle.tar.gz'
with tarfile.open(output, 'w:gz') as tar:
    tar.add(keg, arcname=f'rust-playout/{version}')
print(output)
