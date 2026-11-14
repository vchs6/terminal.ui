#!/usr/bin/env python3
"""Verify or restore a single TASK020 pinned intermediate from its addendum."""
import argparse
import base64
import hashlib
import json
import os
import pathlib
import stat
import tarfile
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
MAP = HERE / 'packed-build-targets-map.json'
ROOTS = (
    pathlib.Path('/workspace/work/session-lifecycle-formal-tests/source/tests/session_lifecycle/target'),
    pathlib.Path('/workspace/work/session-lifecycle-formal-tests/fix-r1/source/tests/session_lifecycle/target'),
)


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda: f.read(1024 * 1024), b''):
            h.update(b)
    return h.hexdigest()


def allowed(path):
    assert path.is_absolute() and any(path.is_relative_to(r) for r in ROOTS), path
    assert '..' not in path.parts and path.suffix in ('.a', '.cjo'), path
    for parent in path.parents:
        assert not parent.is_symlink(), parent


def load():
    data = json.loads(MAP.read_text())
    assert data['schema'] == 1 and len(data['mapping']) == 124 and data['uniqueMembers'] == 67
    archive = HERE / data['archive']['path']
    assert archive.name == 'packed-build-targets.tar.gz'
    assert archive.stat().st_size == data['archive']['bytes'] and digest(archive) == data['archive']['sha256']
    indices = {item['sha256']: item for item in data['indices']}
    assert len(indices) == 2
    indexed = {}
    for item in indices.values():
        p = pathlib.Path(item['path'])
        assert p.name == 'index.json' and p.parent.name == 'evidence'
        assert digest(p) == item['sha256']
        for entry in json.loads(p.read_text())['files']:
            if entry['path'].endswith(('.a', '.cjo')) and '/tests/session_lifecycle/target/' in entry['path']:
                indexed[entry['path']] = (entry, item['sha256'])
    assert len(indexed) == 124
    paths = set()
    for row in data['mapping']:
        p = pathlib.Path(row['original']); allowed(p)
        assert str(p) == row['original'] == row['resolvedPath'] and str(p) not in paths
        paths.add(str(p))
        entry, index_sha = indexed[str(p)]
        assert row['indexSha256'] == index_sha
        assert all(row[k] == entry[k] for k in ('bytes', 'sha256', 'role', 'resolvedPath'))
        assert row['member'] == 'objects/' + row['sha256']
    assert paths == set(indexed)
    return data, archive


def check_store(data, archive):
    wanted = {(r['member'], r['bytes'], r['sha256']) for r in data['mapping']}
    assert len(wanted) == 67
    with tarfile.open(archive, 'r:gz') as tar:
        members = tar.getmembers()
        assert len(members) == 67 and all(m.isfile() for m in members)
        assert {m.name for m in members} == {x[0] for x in wanted}
        for member, size, sha in wanted:
            stream = tar.extractfile(member)
            h, count = hashlib.sha256(), 0
            for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                h.update(chunk); count += len(chunk)
            assert count == size and h.hexdigest() == sha, member


def check_direct(data):
    for row in data['mapping']:
        p = pathlib.Path(row['original']); s = p.lstat()
        assert stat.S_ISREG(s.st_mode) and s.st_size == row['bytes'] and digest(p) == row['sha256'], p
        assert (stat.S_IMODE(s.st_mode), s.st_uid, s.st_gid, s.st_mtime_ns) == (row['mode'], row['uid'], row['gid'], row['mtime_ns']), p
        attrs = {n: base64.b64encode(os.getxattr(p, n, follow_symlinks=False)).decode('ascii') for n in os.listxattr(p, follow_symlinks=False)}
        assert attrs == row['xattrs'], p


def restore(row, archive):
    p = pathlib.Path(row['original']); allowed(p)
    assert not p.exists() and not p.is_symlink(), 'direct path already exists; refusing overwrite'
    assert p.parent.is_dir() and os.geteuid() == row['uid'] and os.getegid() == row['gid']
    with tarfile.open(archive, 'r:gz') as tar:
        member = tar.getmember(row['member'])
        assert member.isfile() and member.size == row['bytes']
        data = tar.extractfile(member).read()
    assert len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256']
    temp = None
    try:
        with tempfile.NamedTemporaryFile(mode='wb', prefix='.task020-restore-', dir=p.parent, delete=False) as f:
            temp = pathlib.Path(f.name)
            f.write(data); f.flush(); os.fsync(f.fileno())
        os.chmod(temp, row['mode'])
        for name, value in row['xattrs'].items():
            os.setxattr(temp, name, base64.b64decode(value), follow_symlinks=False)
        os.utime(temp, ns=(row['mtime_ns'], row['mtime_ns']))
        os.link(temp, p, follow_symlinks=False)  # Fails if a path appeared concurrently.
        assert digest(p) == row['sha256']
    finally:
        if temp is not None and temp.exists():
            temp.unlink()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=('verify-store', 'verify-direct', 'resolve', 'restore'))
    parser.add_argument('path', nargs='?')
    args = parser.parse_args()
    data, archive = load()
    if args.action in ('verify-store', 'verify-direct'):
        assert args.path is None
        check_store(data, archive)
        if args.action == 'verify-direct': check_direct(data)
        print(f'PASS {args.action}: 124 paths, 67 verified archive members')
        return
    assert args.path is not None
    rows = {r['original']: r for r in data['mapping']}
    assert args.path in rows, 'path absent from frozen addendum'
    row = rows[args.path]
    if args.action == 'resolve':
        print(json.dumps(dict(original=row['original'], directPresent=pathlib.Path(row['original']).is_file(),
                              archive=str(archive), member=row['member'], bytes=row['bytes'], sha256=row['sha256'])))
    else:
        check_store(data, archive)
        restore(row, archive)
        print('RESTORED ' + row['original'])


if __name__ == '__main__':
    main()
