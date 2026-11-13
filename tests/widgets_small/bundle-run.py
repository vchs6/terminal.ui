#!/usr/bin/env python3
"""Consume an actual source .cjp in a clean temporary tree; no repo internals."""
import argparse, hashlib, pathlib, shutil, subprocess, tarfile, tempfile
p = argparse.ArgumentParser()
p.add_argument('archive', type=pathlib.Path)
p.add_argument('--output', type=pathlib.Path, required=True)
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=False)
print('bundle_sha256=' + hashlib.sha256(a.archive.read_bytes()).hexdigest(), flush=True)
with tarfile.open(a.archive, 'r:gz') as archive:
    members = archive.getmembers()
    assert all(m.isfile() or m.isdir() for m in members), 'regular source archive only'
    assert all(not pathlib.PurePosixPath(m.name).is_absolute() and '..' not in pathlib.PurePosixPath(m.name).parts for m in members)
    archive.extractall(a.output)
manifests = list(a.output.glob('cjpm.toml')) + list(a.output.glob('*/cjpm.toml'))
assert len(manifests) == 1
product = manifests[0].parent
suite = product / 'tests/widgets_small'
shutil.copytree(pathlib.Path(__file__).parent, suite, ignore=shutil.ignore_patterns('target', 'build-script-cache', 'cjpm.lock', 'cangjie-repo.toml', '__pycache__'))
config = '[repository.cache]\npath = "/workspace/work/viewport-tests/cache"\n[repository.home]\nregistry = "https://pkg.cangjie-lang.cn/registry"\n'
(product / 'cangjie-repo.toml').write_text(config)
for manifest in suite.rglob('cjpm.toml'):
    (manifest.parent / 'cangjie-repo.toml').write_text(config)
print('clean_consumer=' + str(suite), flush=True)
raise SystemExit(subprocess.run(['bash', str(suite / 'run.sh')], cwd=product).returncode)
